from rest_framework.permissions import BasePermission


class IsParticipant(BasePermission):
    """
    Katılımcıların ve organizatörlerin katılımcı
    işlemlerini kullanmasına izin verir.
    """

    message = (
        "Only participants and organizers "
        "can perform this action."
    )

    def has_permission(self, request, view):
        # Organizatörler de etkinliğe katılabilir ve
        # etkinlikleri favorilerine ekleyebilir.
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role
            in (
                "participant",
                "organizer",
            )
        )