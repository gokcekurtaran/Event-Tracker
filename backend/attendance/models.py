from django.conf import settings
from django.db import models

from events.models import Event


class Attendance(models.Model):
    """
    Kullanıcının bir etkinliğe kayıt durumunu saklar.
    QR sistemi eklendiğinde gerçek giriş bilgisi de bu modelde tutulur.
    """

    class Status(models.TextChoices):
        REGISTERED = "registered", "Registered"
        CANCELLED = "cancelled", "Cancelled"

    event = models.ForeignKey(
        Event,
        on_delete=models.CASCADE,
        related_name="attendances",
        verbose_name="Event",
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="attendances",
        verbose_name="User",
    )

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.REGISTERED,
        db_index=True,
        verbose_name="Status",
    )

    checked_in_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Checked in at",
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created at",
    )

    updated_at = models.DateTimeField(
        auto_now=True,
        verbose_name="Updated at",
    )

    class Meta:
        verbose_name = "Attendance"
        verbose_name_plural = "Attendances"

        # En son oluşturulan katılım kayıtlarını önce gösterir.
        ordering = ["-created_at"]

        constraints = [
            # Bir kullanıcının aynı etkinlik için yalnızca
            # bir katılım kaydına sahip olmasını sağlar.
            models.UniqueConstraint(
                fields=[
                    "event",
                    "user",
                ],
                name="unique_event_user_attendance",
            ),
        ]

        indexes = [
            # Etkinlik ve katılım durumuna göre sorgulamayı hızlandırır.
            models.Index(
                fields=[
                    "event",
                    "status",
                ]
            ),

            # Kullanıcının aktif katılımlarını hızlı getirir.
            models.Index(
                fields=[
                    "user",
                    "status",
                ]
            ),
        ]

    @property
    def is_checked_in(self):
        """
        Kullanıcının etkinlik girişinde doğrulanıp
        doğrulanmadığını döndürür.
        """

        return self.checked_in_at is not None

    def __str__(self):
        return (
            f"{self.user.full_name} - "
            f"{self.event.title} - "
            f"{self.get_status_display()}"
        )


class Favorite(models.Model):
    """
    Kullanıcının favoriye eklediği etkinlikleri saklar.
    """

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="favorites",
        verbose_name="User",
    )

    event = models.ForeignKey(
        Event,
        on_delete=models.CASCADE,
        related_name="favorited_by",
        verbose_name="Event",
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created at",
    )

    class Meta:
        verbose_name = "Favorite"
        verbose_name_plural = "Favorites"

        # En son favoriye eklenen etkinlikleri önce gösterir.
        ordering = ["-created_at"]

        constraints = [
            # Aynı etkinliğin aynı kullanıcı tarafından
            # birden fazla kez favoriye alınmasını engeller.
            models.UniqueConstraint(
                fields=[
                    "user",
                    "event",
                ],
                name="unique_user_event_favorite",
            ),
        ]

        indexes = [
            # Kullanıcının favorilerini daha hızlı getirir.
            models.Index(
                fields=[
                    "user",
                    "created_at",
                ]
            ),
        ]

    def __str__(self):
        return (
            f"{self.user.full_name} - "
            f"{self.event.title}"
        )