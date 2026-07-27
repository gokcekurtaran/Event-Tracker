from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView

from events.models import Event
from .models import Attendance, Favorite
from .permissions import IsParticipant
from .serializers import (
    AttendanceSerializer,
    FavoriteSerializer,
)


class JoinEventView(APIView):
    """
    Katılımcının etkinliğe güvenli şekilde kayıt olmasını sağlar.
    """

    permission_classes = [
        IsAuthenticated,
        IsParticipant,
    ]
    
    throttle_classes = [ 
        ScopedRateThrottle,
    ]

    throttle_scope = "attendance"

    def post(self, request, event_id):
        # İşlemin tamamını tek bir veritabanı transaction'ında yürütür.
        with transaction.atomic():
            try:
                # Etkinlik satırını kilitleyerek aynı anda gelen
                # katılım isteklerinin kontenjanı aşmasını engeller.
                event = (
                    Event.objects.select_for_update()
                    .select_related("category", "organizer")
                    .get(
                        id=event_id,
                    )
                )

            except Event.DoesNotExist:
                return Response(
                    {
                        "detail": "Event not found.",
                    },
                    status=status.HTTP_404_NOT_FOUND,
                )

            # Yalnızca yayınlanmış etkinliklere katılım yapılabilir.
            if event.status != Event.Status.PUBLISHED:
                return Response(
                    {
                        "detail": (
                            "This event is not available "
                            "for registration."
                        )
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Başlangıç zamanı geçmiş etkinliklere katılımı engeller.
            if event.start_date <= timezone.now():
                return Response(
                    {
                        "detail": (
                            "Registration for this event has closed."
                        )
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Kullanıcının mevcut katılım kaydını kilitleyerek getirir.
            attendance = (
                Attendance.objects.select_for_update()
                .filter(
                    event=event,
                    user=request.user,
                )
                .first()
            )

            if (
                attendance
                and attendance.status
                == Attendance.Status.REGISTERED
            ):
                return Response(
                    {
                        "detail": (
                            "You have already joined this event."
                        )
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Yalnızca aktif katılımları kontenjana dahil eder.
            participant_count = Attendance.objects.filter(
                event=event,
                status=Attendance.Status.REGISTERED,
            ).count()

            if participant_count >= event.capacity:
                return Response(
                    {
                        "detail": "The event capacity is full.",
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if attendance:
                # Daha önce iptal edilen kaydı yeniden aktif hâle getirir.
                attendance.status = Attendance.Status.REGISTERED
                attendance.checked_in_at = None

                attendance.save(
                    update_fields=[
                        "status",
                        "checked_in_at",
                        "updated_at",
                    ]
                )

                response_status = status.HTTP_200_OK

            else:
                # Kullanıcının ilk katılım kaydını oluşturur.
                attendance = Attendance.objects.create(
                    event=event,
                    user=request.user,
                    status=Attendance.Status.REGISTERED,
                )

                response_status = status.HTTP_201_CREATED

            return Response(
                {
                    "message": (
                        "You have joined the event successfully."
                    ),
                    "participant_count": participant_count + 1,
                    "attendance": AttendanceSerializer(
                        attendance,
                        context={
                            "request": request,
                        },
                    ).data,
                },
                status=response_status,
            )


class LeaveEventView(APIView):
    """
    Katılımcının etkinlik kaydını iptal etmesini sağlar.
    """

    permission_classes = [
        IsAuthenticated,
        IsParticipant,
    ]

    throttle_classes = [
        ScopedRateThrottle,
    ]

    throttle_scope = "attendance"

    def post(self, request, event_id):
        # İptal işlemini güvenli bir transaction içinde yürütür.
        with transaction.atomic():
            try:
                event = Event.objects.select_for_update().get(
                    id=event_id,
                )

            except Event.DoesNotExist:
                return Response(
                    {
                        "detail": "Event not found.",
                    },
                    status=status.HTTP_404_NOT_FOUND,
                )

            try:
                attendance = (
                    Attendance.objects.select_for_update()
                    .get(
                        event=event,
                        user=request.user,
                    )
                )

            except Attendance.DoesNotExist:
                return Response(
                    {
                        "detail": (
                            "You have not joined this event."
                        )
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if attendance.status == Attendance.Status.CANCELLED:
                return Response(
                    {
                        "detail": (
                            "Your event registration "
                            "is already cancelled."
                        )
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Kaydı silmek yerine durumunu iptal edildi olarak değiştirir.
            attendance.status = Attendance.Status.CANCELLED
            attendance.checked_in_at = None

            attendance.save(
                update_fields=[
                    "status",
                    "checked_in_at",
                    "updated_at",
                ]
            )

            participant_count = Attendance.objects.filter(
                event=event,
                status=Attendance.Status.REGISTERED,
            ).count()

            return Response(
                {
                    "message": (
                        "Your event registration "
                        "has been cancelled successfully."
                    ),
                    "participant_count": participant_count,
                },
                status=status.HTTP_200_OK,
            )


class FavoriteEventView(APIView):
    """
    Etkinliği favoriye ekleme ve favoriden çıkarma
    işlemlerini yönetir.
    """

    permission_classes = [
        IsAuthenticated,
        IsParticipant,
    ]

    throttle_classes = [
        ScopedRateThrottle,
    ]

    throttle_scope = "favorite"

    def post(self, request, event_id):
        try:
            # Yalnızca yayınlanmış etkinlikler favoriye eklenebilir.
            event = Event.objects.get(
                id=event_id,
                status=Event.Status.PUBLISHED,
            )

        except Event.DoesNotExist:
            return Response(
                {
                    "detail": "Event not found.",
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        favorite, created = Favorite.objects.get_or_create(
            user=request.user,
            event=event,
        )

        if not created:
            return Response(
                {
                    "detail": (
                        "This event is already in your favorites."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {
                "message": (
                    "The event has been added to your favorites."
                ),
                "favorite": FavoriteSerializer(
                    favorite,
                    context={
                        "request": request,
                    },
                ).data,
            },
            status=status.HTTP_201_CREATED,
        )

    def delete(self, request, event_id):
        try:
            favorite = Favorite.objects.get(
                user=request.user,
                event_id=event_id,
            )

        except Favorite.DoesNotExist:
            return Response(
                {
                    "detail": (
                        "This event is not in your favorites."
                    )
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        favorite.delete()

        return Response(
            {
                "message": (
                    "The event has been removed from your favorites."
                )
            },
            status=status.HTTP_200_OK,
        )


class MyAttendanceListView(generics.ListAPIView):
    """
    Kullanıcının aktif katılım kayıtlarını listeler.
    """

    serializer_class = AttendanceSerializer

    permission_classes = [
        IsAuthenticated,
        IsParticipant,
    ]

    def get_queryset(self):
        # Yalnızca giriş yapan kullanıcının aktif katılımlarını getirir.
        return (
            Attendance.objects.filter(
                user=self.request.user,
                status=Attendance.Status.REGISTERED,
            )
            .select_related(
                "event",
                "event__category",
                "event__organizer",
            )
            .order_by(
                "event__start_date",
            )
        )


class MyFavoriteListView(generics.ListAPIView):
    """
    Kullanıcının favori etkinliklerini listeler.
    """

    serializer_class = FavoriteSerializer

    permission_classes = [
        IsAuthenticated,
        IsParticipant,
    ]

    def get_queryset(self):
        # Yalnızca giriş yapan kullanıcının favorilerini getirir.
        return (
            Favorite.objects.filter(
                user=self.request.user,
            )
            .select_related(
                "event",
                "event__category",
                "event__organizer",
            )
            .order_by(
                "-created_at",
            )
        )