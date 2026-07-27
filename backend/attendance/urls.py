from django.urls import path

from .organizer_views import (
    OrganizerEventReportView,
    OrganizerParticipantListView,
)
from .views import (
    FavoriteEventView,
    JoinEventView,
    LeaveEventView,
    MyAttendanceListView,
    MyFavoriteListView,
)


app_name = "attendance"


urlpatterns = [
    # Kullanıcının katıldığı etkinlikleri listeler.
    path(
        "me/attendances/",
        MyAttendanceListView.as_view(),
        name="my-attendances",
    ),

    # Kullanıcının favori etkinliklerini listeler.
    path(
        "me/favorites/",
        MyFavoriteListView.as_view(),
        name="my-favorites",
    ),

    # Kullanıcının etkinliğe katılmasını sağlar.
    path(
        "events/<int:event_id>/join/",
        JoinEventView.as_view(),
        name="join-event",
    ),

    # Kullanıcının katılımını iptal etmesini sağlar.
    path(
        "events/<int:event_id>/leave/",
        LeaveEventView.as_view(),
        name="leave-event",
    ),

    # Etkinliği favoriye ekler veya favoriden çıkarır.
    path(
        "events/<int:event_id>/favorite/",
        FavoriteEventView.as_view(),
        name="favorite-event",
    ),

    # Organizatörün kendi etkinliğinin katılımcılarını listeler.
    path(
        "organizer/events/<int:event_id>/participants/",
        OrganizerParticipantListView.as_view(),
        name="organizer-event-participants",
    ),

    # Organizatörün kendi etkinliğinin raporunu gösterir.
    path(
        "organizer/events/<int:event_id>/report/",
        OrganizerEventReportView.as_view(),
        name="organizer-event-report",
    ),
]