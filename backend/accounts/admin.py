from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):

    model = CustomUser
    # Kullanıcı listesinde gösterilecek sütunları belirler.
    list_display = (
        "email",
        "first_name",
        "last_name",
        "role",
        "is_active",
        "is_staff",
    )

    # Kullanıcıların rol ve durumlarına göre filtrelenmesini sağlar.
    list_filter = (
        "role",
        "is_active",
        "is_staff",
    )

    # Kullanıcıların e-posta, ad ve soyadına göre aranmasını sağlar.
    search_fields = (
        "email",
        "first_name",
        "last_name",
    )
    # Kullanıcıları e-posta adresine göre sıralar.
    ordering = ("email",)

    # Mevcut bir kullanıcı düzenlenirken gösterilecek alanları belirler.
    fieldsets = (
        (
            None,
            {
                "fields": (
                    "email",
                    "password",
                )
            },
        ),
        (
            "Personal information",
            {
                "fields": (
                    "first_name",
                    "last_name",
                    "profile_image",
                    "city",
                    "bio",
                )
            },
        ),
        (
            "Roles and permissions",
            {
                "fields": (
                    "role",
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        (
            "Important dates",
            {
                "fields": (
                    "last_login",
                    "date_joined",
                )
            },
        ),
    )

    # Admin panelinden yeni kullanıcı oluşturulurken gösterilecek alanlardır.
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "email",
                    "first_name",
                    "last_name",
                    "password1",
                    "password2",
                    "role",
                    "is_active",
                    "is_staff",
                ),
            },
        ),
    )
