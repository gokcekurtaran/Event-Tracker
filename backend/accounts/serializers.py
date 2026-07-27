from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.serializers import (
    TokenObtainPairSerializer,
)

from .models import CustomUser


class UserSerializer(serializers.ModelSerializer):
    """
    Kullanıcı bilgilerinin API üzerinden gösterilmesini sağlar.
    """

    full_name = serializers.CharField(
        read_only=True,
    )

    class Meta:
        model = CustomUser

        fields = (
            "id",
            "email",
            "first_name",
            "last_name",
            "full_name",
            "role",
            "profile_image",
            "city",
            "bio",
        )

        # Kullanıcı kendi e-posta adresini ve rolünü değiştiremez.
        read_only_fields = (
            "id",
            "email",
            "full_name",
            "role",
        )


class RegisterSerializer(serializers.ModelSerializer):
    """
    Yeni katılımcı hesabı oluşturmak için kullanılır.
    Organizatör hesabı kayıt API'sinden oluşturulamaz.
    """

    password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={
            "input_type": "password",
        },
    )

    confirm_password = serializers.CharField(
        write_only=True,
        style={
            "input_type": "password",
        },
    )

    class Meta:
        model = CustomUser

        fields = (
            "id",
            "email",
            "first_name",
            "last_name",
            "password",
            "confirm_password",
        )

        read_only_fields = (
            "id",
        )

    def validate_email(self, value):
        """
        Aynı e-posta adresiyle birden fazla hesap
        oluşturulmasını engeller.
        """

        normalized_email = value.strip().lower()

        if CustomUser.objects.filter(
            email__iexact=normalized_email,
        ).exists():
            raise serializers.ValidationError(
                "An account with this email address already exists."
            )

        return normalized_email

    def validate(self, attrs):
        """
        Şifrelerin aynı olduğunu ve Django'nun güvenlik
        kurallarını karşıladığını kontrol eder.
        """

        password = attrs.get("password")
        confirm_password = attrs.get("confirm_password")

        if password != confirm_password:
            raise serializers.ValidationError(
                {
                    "confirm_password": (
                        "The passwords do not match."
                    )
                }
            )

        # Django'nun standart şifre güvenliği kurallarını uygular.
        validate_password(password)

        return attrs

    def create(self, validated_data):
        """
        Doğrulanan bilgilerle katılımcı hesabı oluşturur.
        """

        # Yalnızca karşılaştırma için kullanılan alanı kaldırır.
        validated_data.pop("confirm_password")

        password = validated_data.pop("password")

        # Kayıt olan bütün kullanıcıları katılımcı yapar.
        validated_data["role"] = CustomUser.Role.PARTICIPANT

        return CustomUser.objects.create_user(
            password=password,
            **validated_data,
        )


class BaseLoginSerializer(TokenObtainPairSerializer):
    """
    Participant ve organizer girişlerinin ortak
    token üretme işlemlerini içerir.
    """

    allowed_roles = ()
    login_mode = None
    role_error_message = None

    def validate(self, attrs):
        # Önce e-posta ve şifreyi doğrular.
        data = super().validate(attrs)

        # Kullanıcının seçilen giriş türünü kullanıp
        # kullanamayacağını kontrol eder.
        if self.user.role not in self.allowed_roles:
            raise serializers.ValidationError(
                {
                    "detail": self.role_error_message,
                }
            )

        user_data = UserSerializer(
            self.user,
            context=self.context,
        ).data

        # Gerçek kullanıcı rolünden ayrı olarak
        # hangi bölümden giriş yapıldığını bildirir.
        user_data["login_mode"] = self.login_mode

        data["user"] = user_data

        return data


class ParticipantLoginSerializer(BaseLoginSerializer):
    """
    Katılımcıların ve organizatörlerin katılımcı
    modunda giriş yapmasını sağlar.
    """

    allowed_roles = (
        CustomUser.Role.PARTICIPANT,
        CustomUser.Role.ORGANIZER,
    )

    login_mode = "participant"

    role_error_message = (
        "This account cannot sign in from the participant login."
    )


class OrganizerLoginSerializer(BaseLoginSerializer):
    """
    Yalnızca organizatör rolündeki kullanıcıların
    organizatör modunda giriş yapmasını sağlar.
    """

    allowed_roles = (
        CustomUser.Role.ORGANIZER,
    )

    login_mode = "organizer"

    role_error_message = (
        "This account cannot sign in from the organizer login."
    )