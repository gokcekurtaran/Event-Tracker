from rest_framework import serializers

from accounts.models import CustomUser
from .models import Attendance


class ParticipantUserSerializer(serializers.ModelSerializer):
    """
    Organizatöre gösterilecek temel katılımcı
    bilgilerini hazırlar.
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
            "profile_image",
            "city",
        )

        read_only_fields = fields


class OrganizerParticipantSerializer(
    serializers.ModelSerializer
):
    """
    Organizatörün etkinlik katılımcılarını
    görüntülemesini sağlar.
    """

    user = ParticipantUserSerializer(
        read_only=True,
    )

    is_checked_in = serializers.BooleanField(
        read_only=True,
    )

    registered_at = serializers.DateTimeField(
        source="created_at",
        read_only=True,
    )

    class Meta:
        model = Attendance

        fields = (
            "id",
            "user",
            "status",
            "is_checked_in",
            "checked_in_at",
            "registered_at",
            "updated_at",
        )

        read_only_fields = fields