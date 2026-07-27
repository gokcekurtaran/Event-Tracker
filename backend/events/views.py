from django.db.models import (
    BooleanField,
    Count,
    Exists,
    OuterRef,
    Q,
    Value,
)
from rest_framework import mixins, viewsets
from rest_framework.decorators import action
from rest_framework.parsers import (
    FormParser,
    JSONParser,
    MultiPartParser,
)
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from attendance.models import Attendance, Favorite
from .filters import EventFilter
from .models import Category, Event
from .permissions import IsEventOwner, IsOrganizer
from .serializers import (
    CategorySerializer,
    EventSerializer,
)


class CategoryViewSet(
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    """
    Aktif kategorileri Flutter uygulamasına gönderir.
    """

    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated]

    # Kategori sayısı az olduğu için sonucu sayfalara bölmez.
    pagination_class = None

    queryset = Category.objects.filter(
        is_active=True,
    ).order_by("name")


class EventViewSet(
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.CreateModelMixin,
    mixins.UpdateModelMixin,
    viewsets.GenericViewSet,
):
    """
    Etkinlik listeleme, görüntüleme, oluşturma
    ve güncelleme işlemlerini yönetir.
    """

    serializer_class = EventSerializer

    parser_classes = [
        JSONParser,
        MultiPartParser,
        FormParser,
    ]

    filterset_class = EventFilter

    search_fields = (
        "title",
        "description",
        "city",
        "location_name",
        "category__name",
    )

    ordering_fields = (
        "start_date",
        "created_at",
        "price",
        "capacity",
    )

    ordering = (
        "start_date",
    )

    def get_base_queryset(self):
        """
        Etkinlik sorgusuna katılımcı sayısı, katılım durumu
        ve favori durumunu tek sorguda ekler.
        """

        queryset = Event.objects.select_related(
            "category",
            "organizer",
        ).annotate(
            # Yalnızca aktif katılım kayıtlarını sayar.
            annotated_participant_count=Count(
                "attendances",
                filter=Q(
                    attendances__status=(
                        Attendance.Status.REGISTERED
                    )
                ),
                distinct=True,
            )
        )

        user = self.request.user

        if user.is_authenticated:
            # Kullanıcının etkinliğe katılım kaydını sorguya ekler.
            registered_attendance = Attendance.objects.filter(
                event_id=OuterRef("pk"),
                user=user,
                status=Attendance.Status.REGISTERED,
            )

            # Kullanıcının favori kaydını sorguya ekler.
            favorite = Favorite.objects.filter(
                event_id=OuterRef("pk"),
                user=user,
            )

            queryset = queryset.annotate(
                annotated_is_joined=Exists(
                    registered_attendance,
                ),
                annotated_is_favorite=Exists(
                    favorite,
                ),
            )

        else:
            # Organizatör için katılım ve favori alanlarını false döndürür.
            queryset = queryset.annotate(
                annotated_is_joined=Value(
                    False,
                    output_field=BooleanField(),
                ),
                annotated_is_favorite=Value(
                    False,
                    output_field=BooleanField(),
                ),
            )

        return queryset

    def get_queryset(self):
        """
        Yapılan işleme göre erişilebilecek etkinlikleri belirler.
        """

        queryset = self.get_base_queryset()

        # Genel listede yalnızca yayınlanmış etkinlikler görünür.
        if self.action == "list":
            return queryset.filter(
                status=Event.Status.PUBLISHED,
            )

        # Organizatörün kendi etkinliklerini bütün durumlarıyla getirir.
        if self.action == "my_events":
            return queryset.filter(
                organizer=self.request.user,
            )

        # Yayınlanan etkinlikler herkes tarafından görüntülenebilir.
        # Organizatör kendi taslak etkinliğini de görüntüleyebilir.
        if self.action == "retrieve":
            return queryset.filter(
                Q(status=Event.Status.PUBLISHED)
                | Q(organizer=self.request.user)
            )

        # Güncellemede yalnızca organizatörün kendi etkinliklerini döndürür.
        if self.action in (
            "update",
            "partial_update",
        ):
            return queryset.filter(
                organizer=self.request.user,
            )

        return queryset.none()

    def get_permissions(self):
        """
        Her işlem için gerekli kullanıcı yetkilerini belirler.
        """

        if self.action in (
            "list",
            "retrieve",
        ):
            permission_classes = [
                IsAuthenticated,
            ]

        elif self.action in (
            "create",
            "my_events",
        ):
            permission_classes = [
                IsAuthenticated,
                IsOrganizer,
            ]

        else:
            permission_classes = [
                IsAuthenticated,
                IsOrganizer,
                IsEventOwner,
            ]

        return [
            permission()
            for permission in permission_classes
        ]

    def perform_create(self, serializer):
        # Etkinliğin organizatörünü access token'dan belirler.
        serializer.save(
            organizer=self.request.user,
        )

    @action(
        detail=False,
        methods=["get"],
        url_path="my-events",
    )
    def my_events(self, request):
        """
        Organizatörün oluşturduğu bütün etkinlikleri listeler.
        """

        queryset = self.filter_queryset(
            self.get_queryset(),
        )

        page = self.paginate_queryset(queryset)

        if page is not None:
            serializer = self.get_serializer(
                page,
                many=True,
            )

            return self.get_paginated_response(
                serializer.data,
            )

        serializer = self.get_serializer(
            queryset,
            many=True,
        )

        return Response(serializer.data)
