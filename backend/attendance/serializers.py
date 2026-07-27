from rest_framework import serializers

from events.models import Event
from .models import Attendance, Favorite


class AttendanceEventSerializer(serializers.ModelSerializer):
    """
    Katılım listesinde gösterilecek temel etkinlik
    bilgilerini hazırlar.
    """

    category_name = serializers.CharField(
        source="category.name",
        read_only=True,
    )

    category_icon = serializers.CharField(
        source="category.icon",
        read_only=True,
    )

    is_free = serializers.BooleanField(
        read_only=True,
    )

    class Meta:
        model = Event

        fields = (
            "id",
            "title",
            "cover_image",
            "start_date",
            "end_date",
            "city",
            "location_name",
            "price",
            "is_free",
            "category_name",
            "category_icon",
            "status",
        )

        read_only_fields = fields


class AttendanceSerializer(serializers.ModelSerializer):
    """
    Kullanıcının katılım bilgilerini etkinlik
    bilgileriyle birlikte döndürür.
    """

    event = AttendanceEventSerializer(
        read_only=True,
    )

    is_checked_in = serializers.BooleanField(
        read_only=True,
    )

    class Meta:
        model = Attendance

        fields = (
            "id",
            "event",
            "status",
            "is_checked_in",
            "checked_in_at",
            "created_at",
            "updated_at",
        )

        read_only_fields = fields


class FavoriteSerializer(serializers.ModelSerializer):
    """
    Kullanıcının favoriye aldığı etkinlikleri döndürür.
    """

    event = AttendanceEventSerializer(
        read_only=True,
    )

    class Meta:
        model = Favorite

        fields = (
            "id",
            "event",
            "created_at",
        )

        read_only_fields = fields