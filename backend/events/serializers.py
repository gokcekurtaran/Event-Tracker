from django.utils import timezone
from rest_framework import serializers

from accounts.models import CustomUser
from attendance.models import Attendance, Favorite
from .models import Category, Event


class CategorySerializer(serializers.ModelSerializer):
    """
    Kategori bilgilerinin Flutter'a gönderilmesini sağlar.
    """

    class Meta:
        model = Category

        fields = (
            "id",
            "name",
            "slug",
            "icon",
            "color",
        )

        read_only_fields = fields


class OrganizerSerializer(serializers.ModelSerializer):
    """
    Etkinliği oluşturan organizatörün herkese açık
    temel bilgilerini döndürür.
    """

    full_name = serializers.CharField(
        read_only=True,
    )

    class Meta:
        model = CustomUser

        fields = (
            "id",
            "full_name",
            "profile_image",
        )

        read_only_fields = fields


class EventSerializer(serializers.ModelSerializer):
    """
    Etkinliklerin görüntülenmesi, oluşturulması ve
    güncellenmesi için kullanılır.
    """

    # Kategori bilgisini cevap içerisinde nesne olarak gösterir.
    category = CategorySerializer(
        read_only=True,
    )

    # Oluşturma ve güncelleme sırasında kategori kimliğini alır.
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.filter(
            is_active=True,
        ),
        source="category",
        write_only=True,
    )

    # Organizatör bilgisi access token'daki kullanıcıdan belirlenir.
    organizer = OrganizerSerializer(
        read_only=True,
    )

    # Etkinliğin ücretsiz olup olmadığını modelden alır.
    is_free = serializers.BooleanField(
        read_only=True,
    )

    participant_count = serializers.SerializerMethodField()
    remaining_capacity = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()
    is_favorite = serializers.SerializerMethodField()

    class Meta:
        model = Event

        fields = (
            "id",
            "title",
            "description",
            "cover_image",
            "start_date",
            "end_date",
            "city",
            "location_name",
            "address",
            "latitude",
            "longitude",
            "capacity",
            "participant_count",
            "remaining_capacity",
            "price",
            "is_free",
            "category",
            "category_id",
            "organizer",
            "status",
            "is_joined",
            "is_favorite",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "id",
            "organizer",
            "is_free",
            "participant_count",
            "remaining_capacity",
            "is_joined",
            "is_favorite",
            "created_at",
            "updated_at",
        )

    def get_participant_count(self, obj):
        """
        Etkinliğin aktif katılımcı sayısını döndürür.
        """

        # Liste sorgusunda önceden hesaplanan değer varsa onu kullanır.
        if hasattr(obj, "annotated_participant_count"):
            return obj.annotated_participant_count

        # Önceden hesaplanmamışsa veritabanından aktif kayıtları sayar.
        return obj.attendances.filter(
            status=Attendance.Status.REGISTERED,
        ).count()

    def get_remaining_capacity(self, obj):
        """
        Etkinlikte kalan kontenjanı hesaplar.
        """

        participant_count = self.get_participant_count(obj)

        # Kalan kontenjanın negatif görünmesini engeller.
        return max(
            obj.capacity - participant_count,
            0,
        )

    def get_is_joined(self, obj):
        """
        Giriş yapan kullanıcının etkinliğe katılıp
        katılmadığını döndürür.
        """

        # Liste sorgusunda önceden hesaplanan değeri kullanır.
        if hasattr(obj, "annotated_is_joined"):
            return obj.annotated_is_joined

        request = self.context.get("request")

        if (
            not request
            or not request.user.is_authenticated
            or request.user.role != "participant"
        ):
            return False

        return Attendance.objects.filter(
            event=obj,
            user=request.user,
            status=Attendance.Status.REGISTERED,
        ).exists()

    def get_is_favorite(self, obj):
        """
        Etkinliğin giriş yapan kullanıcının favorilerinde
        olup olmadığını döndürür.
        """

        # Liste sorgusunda önceden hesaplanan değeri kullanır.
        if hasattr(obj, "annotated_is_favorite"):
            return obj.annotated_is_favorite

        request = self.context.get("request")

        if (
            not request
            or not request.user.is_authenticated
            or request.user.role != "participant"
        ):
            return False

        return Favorite.objects.filter(
            event=obj,
            user=request.user,
        ).exists()

    def validate_start_date(self, value):
        """
        Yeni etkinliğin geçmiş bir tarihte
        başlatılmasını engeller.
        """

        # Güncellemede tarih değişmemişse mevcut değere izin verir.
        if self.instance is not None:
            if self.instance.start_date == value:
                return value

        if value <= timezone.now():
            raise serializers.ValidationError(
                "The start date must be in the future."
            )

        return value

    def validate(self, attrs):
        """
        Tarih ve kontenjan alanlarını birlikte doğrular.
        """

        # PATCH isteğinde gönderilmeyen alanları mevcut nesneden alır.
        start_date = attrs.get(
            "start_date",
            getattr(
                self.instance,
                "start_date",
                None,
            ),
        )

        end_date = attrs.get(
            "end_date",
            getattr(
                self.instance,
                "end_date",
                None,
            ),
        )

        if (
            start_date
            and end_date
            and end_date <= start_date
        ):
            raise serializers.ValidationError(
                {
                    "end_date": (
                        "The end date must be later "
                        "than the start date."
                    )
                }
            )

        new_capacity = attrs.get("capacity")

        # Organizatörün kontenjanı mevcut kayıt sayısının
        # altına düşürmesini engeller.
        if (
            self.instance is not None
            and new_capacity is not None
        ):
            participant_count = (
                self.instance.attendances.filter(
                    status=Attendance.Status.REGISTERED,
                ).count()
            )

            if new_capacity < participant_count:
                raise serializers.ValidationError(
                    {
                        "capacity": (
                            "Capacity cannot be lower than "
                            "the current participant count."
                        )
                    }
                )

        return attrs
