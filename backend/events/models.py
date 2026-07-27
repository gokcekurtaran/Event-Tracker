from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import (
    FileExtensionValidator,
    MinValueValidator,
    RegexValidator,
)
from django.db import models
from django.utils.text import slugify


def validate_image_size(image):
    max_size = 5 * 1024 * 1024

    if image.size > max_size:
        raise ValidationError(
            "The image size cannot exceed 5 MB."
        )


class Category(models.Model):
    """
    Etkinliklerin sınıflandırılmasında kullanılan kategori modelidir.
    Kategoriler backend üzerinden yönetilir ve Flutter'a API ile gönderilir.
    """
    name = models.CharField(
        max_length=100,
        unique=True,
        verbose_name="Category name",
    )

    slug = models.SlugField(
        max_length=120,
        unique=True,
        blank=True,
        verbose_name="Slug",
    )

    icon = models.CharField(
        max_length=20,
        blank=True,
        verbose_name="Icon",
        help_text="Enter an emoji such as 💻, 🎵 or ⚽.",
    )

    color = models.CharField(
        max_length=7,
        default="#6750A4",
        validators=[
            RegexValidator(
                regex=r"^#[0-9A-Fa-f]{6}$",
                message=(
                    "Enter a valid hexadecimal color code, "
                    "such as #6750A4."
                ),
            )
        ],
        verbose_name="Color",
        help_text="Enter a hexadecimal color code.",
    )

    is_active = models.BooleanField(
        default=True,
        verbose_name="Active",
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created at",
    )

    class Meta:
        verbose_name = "Category"
        verbose_name_plural = "Categories"
        ordering = ["name"]

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)

        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Event(models.Model):
    class Status(models.TextChoices):
        DRAFT = "draft", "Draft"
        PUBLISHED = "published", "Published"
        CANCELLED = "cancelled", "Cancelled"
        COMPLETED = "completed", "Completed"

    title = models.CharField(
        max_length=200,
        verbose_name="Title",
    )

    description = models.TextField(
        verbose_name="Description",
    )

    cover_image = models.ImageField(
        upload_to="event_covers/",
        validators=[
            FileExtensionValidator(
                allowed_extensions=[
                    "jpg",
                    "jpeg",
                    "png",
                ]
            ),
            validate_image_size,
        ],
        verbose_name="Cover image",
    )

    start_date = models.DateTimeField(
        verbose_name="Start date",
    )

    end_date = models.DateTimeField(
        verbose_name="End date",
    )

    city = models.CharField(
        max_length=100,
        db_index=True,
        verbose_name="City",
    )

    location_name = models.CharField(
        max_length=200,
        verbose_name="Location name",
    )

    address = models.TextField(
        verbose_name="Address",
    )

    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        verbose_name="Latitude",
    )

    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        verbose_name="Longitude",
    )

    capacity = models.PositiveIntegerField(
        validators=[
            MinValueValidator(
                1,
                message="Capacity must be at least 1.",
            )
        ],
        verbose_name="Capacity",
    )

    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0,
        validators=[
            MinValueValidator(
                0,
                message="Price cannot be negative.",
            )
        ],
        verbose_name="Ticket price",
    )

    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT,
        related_name="events",
        verbose_name="Category",
    )

    organizer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="organized_events",
        verbose_name="Organizer",
    )

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT,
        db_index=True,
        verbose_name="Status",
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
        verbose_name = "Event"
        verbose_name_plural = "Events"

        ordering = ["start_date"]

        indexes = [
            models.Index(
                fields=[
                    "status",
                    "start_date",
                ]
            ),

            models.Index(
                fields=[
                    "city",
                    "start_date",
                ]
            ),
        ]

    def clean(self):
        super().clean()

        # Bitiş tarihinin başlangıç tarihinden sonra olmasını zorunlu tutar.
        if (
            self.start_date
            and self.end_date
            and self.end_date <= self.start_date
        ):
            raise ValidationError(
                {
                    "end_date": (
                        "The end date must be later "
                        "than the start date."
                    )
                }
            )

        # Enlem değerinin geçerli aralıkta olmasını kontrol eder.
        if self.latitude is not None:
            if not -90 <= self.latitude <= 90:
                raise ValidationError(
                    {
                        "latitude": (
                            "Latitude must be between "
                            "-90 and 90."
                        )
                    }
                )

        # Boylam değerinin geçerli aralıkta olmasını kontrol eder.
        if self.longitude is not None:
            if not -180 <= self.longitude <= 180:
                raise ValidationError(
                    {
                        "longitude": (
                            "Longitude must be between "
                            "-180 and 180."
                        )
                    }
                )

    @property
    def is_free(self):
        return self.price == 0

    def __str__(self):
        return self.title


