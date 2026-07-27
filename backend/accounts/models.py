from django.contrib.auth.models import AbstractUser
from django.db import models
from .managers import CustomUserManager

class CustomUser(AbstractUser):
    #Etkinlik takip uygulamasında kullanılacak özel kullanıcı modelidir.

    class Role(models.TextChoices):
        # Veritabanında İngilizce rol değerleri saklanır.
        PARTICIPANT = "participant", "Participant"
        ORGANIZER = "organizer", "Organizer"

    username = None

    email = models.EmailField(
        unique=True,
        verbose_name="Email address",
    )

    first_name = models.CharField(
        max_length=100,
        verbose_name="First name",
    )

    last_name = models.CharField(
        max_length=100,
        verbose_name="Last name",
    )

    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.PARTICIPANT,
        verbose_name="User role",
    )

    profile_image = models.ImageField(
        upload_to="profile_images/",
        null=True,
        blank=True,
        verbose_name="Profile image",
    )

    city = models.CharField(
        max_length=100,
        blank=True,
        verbose_name="City",
    )

    bio = models.TextField(
        blank=True,
        verbose_name="Biography",
    )
    USERNAME_FIELD = "email"

    # Superuser oluşturulurken e-postaya ek olarak bu alanlar istenir.
    REQUIRED_FIELDS = [
        "first_name",
        "last_name",
    ]

    # Kullanıcı oluşturma işlemleri özel manager sınıfıyla yönetilir.
    objects = CustomUserManager()

    def __str__(self):
        return (
            f"{self.first_name} {self.last_name} "
            f"({self.email})"
        )

    @property
    def full_name(self):
        return (
            f"{self.first_name} {self.last_name}"
        ).strip()