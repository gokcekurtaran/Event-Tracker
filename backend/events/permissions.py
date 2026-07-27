from rest_framework.permissions import BasePermission


class IsOrganizer(BasePermission):
    """
    Yalnızca organizatör rolündeki kullanıcıların işlem
    yapmasına izin verir.
    """

    message = "Only organizers can perform this action."

    def has_permission(self, request, view):
        # Kullanıcının giriş yapmış ve organizatör olması gerekir.
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == "organizer"
        )


class IsEventOwner(BasePermission):
    """
    Organizatörün yalnızca kendisine ait etkinliği
    değiştirmesine izin verir.
    """

    message = "You can only manage your own events."

    def has_object_permission(
        self,
        request,
        view,
        obj,
    ):
        # Etkinliğin organizatörü ile giriş yapan kullanıcıyı karşılaştırır.
        return obj.organizer_id == request.user.id
