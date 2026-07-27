from django.contrib import admin

from .models import Attendance, Favorite


@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    """
    Katılım kayıtlarının admin panelindeki görünümünü yönetir.
    """

    # Katılım listesinde gösterilecek sütunları belirler.
    list_display = (
        "user",
        "event",
        "status",
        "is_checked_in",
        "created_at",
        "updated_at",
    )

    # Katılımların durum ve tarihe göre filtrelenmesini sağlar.
    list_filter = (
        "status",
        "created_at",
        "checked_in_at",
    )

    # Kullanıcı ve etkinlik bilgilerine göre arama yapılmasını sağlar.
    search_fields = (
        "user__email",
        "user__first_name",
        "user__last_name",
        "event__title",
    )

    # Sistem tarafından oluşturulan tarihlerin değiştirilmesini engeller.
    readonly_fields = (
        "created_at",
        "updated_at",
    )

    # Katılım kayıtlarını oluşturulma tarihine göre sıralar.
    ordering = (
        "-created_at",
    )

    fieldsets = (
        (
            "Attendance information",
            {
                "fields": (
                    "user",
                    "event",
                    "status",
                    "checked_in_at",
                )
            },
        ),
        (
            "System information",
            {
                "fields": (
                    "created_at",
                    "updated_at",
                )
            },
        ),
    )

    @admin.display(
        boolean=True,
        description="Checked in",
    )
    def is_checked_in(self, obj):
        # QR ile giriş yapılıp yapılmadığını admin panelinde gösterir.
        return obj.checked_in_at is not None


@admin.register(Favorite)
class FavoriteAdmin(admin.ModelAdmin):
    """
    Favori kayıtlarının admin panelindeki görünümünü yönetir.
    """

    # Favori listesinde gösterilecek sütunları belirler.
    list_display = (
        "user",
        "event",
        "created_at",
    )

    list_filter = (
        "created_at",
    )

    # Kullanıcı ve etkinlik bilgilerine göre arama yapılmasını sağlar.
    search_fields = (
        "user__email",
        "user__first_name",
        "user__last_name",
        "event__title",
    )

    readonly_fields = (
        "created_at",
    )

    ordering = (
        "-created_at",
    )