from django.db.models import Count, Q
from django.shortcuts import get_object_or_404
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from events.models import Event
from events.permissions import IsOrganizer
from .models import Attendance
from .organizer_serializers import (
    OrganizerParticipantSerializer,
)


class OrganizerParticipantListView(generics.ListAPIView):
    """
    Organizatörün kendi etkinliğine kayıt olan
    katılımcıları görüntülemesini sağlar.
    """

    serializer_class = OrganizerParticipantSerializer

    permission_classes = [
        IsAuthenticated,
        IsOrganizer,
    ]

    search_fields = (
        "user__email",
        "user__first_name",
        "user__last_name",
    )

    ordering_fields = (
        "created_at",
        "checked_in_at",
    )

    ordering = (
        "-created_at",
    )

    def get_event(self):
        """
        Etkinliğin giriş yapan organizatöre ait
        olup olmadığını kontrol eder.
        """

        return get_object_or_404(
            Event,
            id=self.kwargs["event_id"],
            organizer=self.request.user,
        )

    def get_queryset(self):
        event = self.get_event()

        # Yalnızca aktif katılımcıları listeler.
        return (
            Attendance.objects.filter(
                event=event,
                status=Attendance.Status.REGISTERED,
            )
            .select_related(
                "user",
                "event",
            )
            .order_by(
                "-created_at",
            )
        )


class OrganizerEventReportView(APIView):
    """
    Organizatörün kendi etkinliğine ait temel
    katılım raporunu görüntülemesini sağlar.
    """

    permission_classes = [
        IsAuthenticated,
        IsOrganizer,
    ]

    def get(self, request, event_id):
        # Organizatörün yalnızca kendi etkinlik raporunu
        # görüntülemesini sağlar.
        event = get_object_or_404(
            Event.objects.select_related(
                "category",
                "organizer",
            ),
            id=event_id,
            organizer=request.user,
        )

        report = Attendance.objects.filter(
            event=event,
        ).aggregate(
            registered_count=Count(
                "id",
                filter=Q(
                    status=Attendance.Status.REGISTERED,
                ),
            ),
            cancelled_count=Count(
                "id",
                filter=Q(
                    status=Attendance.Status.CANCELLED,
                ),
            ),
            checked_in_count=Count(
                "id",
                filter=Q(
                    status=Attendance.Status.REGISTERED,
                    checked_in_at__isnull=False,
                ),
            ),
        )

        registered_count = (
            report["registered_count"] or 0
        )

        cancelled_count = (
            report["cancelled_count"] or 0
        )

        checked_in_count = (
            report["checked_in_count"] or 0
        )

        remaining_capacity = max(
            event.capacity - registered_count,
            0,
        )

        not_checked_in_count = max(
            registered_count - checked_in_count,
            0,
        )

        # Etkinliğe giriş yapanların aktif kayıtlara oranını hesaplar.
        if registered_count > 0:
            attendance_rate = round(
                (
                    checked_in_count
                    / registered_count
                )
                * 100,
                2,
            )
        else:
            attendance_rate = 0

        return Response(
            {
                "event": {
                    "id": event.id,
                    "title": event.title,
                    "status": event.status,
                    "start_date": event.start_date,
                    "end_date": event.end_date,
                    "city": event.city,
                    "location_name": event.location_name,
                    "category": {
                        "id": event.category.id,
                        "name": event.category.name,
                        "icon": event.category.icon,
                        "color": event.category.color,
                    },
                },
                "report": {
                    "capacity": event.capacity,
                    "registered_count": registered_count,
                    "cancelled_count": cancelled_count,
                    "remaining_capacity": remaining_capacity,
                    "checked_in_count": checked_in_count,
                    "not_checked_in_count": (
                        not_checked_in_count
                    ),
                    "attendance_rate": attendance_rate,
                },
            }
        )