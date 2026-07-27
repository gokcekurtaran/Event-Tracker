from django.contrib import admin
from .models import Category, Event

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    # Kategori listesinde gösterilecek sütunları belirler.
    list_display = (
        "name",
        "slug",
        "icon",
        "color",
        "is_active",
        "created_at",
    )

    # Kategorilerin aktiflik durumuna göre filtrelenmesini sağlar.
    list_filter = (
        "is_active",
    )

    # Kategorilerin adına göre aranmasını sağlar.
    search_fields = (
        "name",
    )

    prepopulated_fields = {
        "slug": (
            "name",
        )
    }

    ordering = (
        "name",
    )

    # Oluşturulma tarihinin değiştirilmesini engeller.
    readonly_fields = (
        "created_at",
    )

    fieldsets = (
        (
            "Category information",
            {
                "fields": (
                    "name",
                    "slug",
                    "icon",
                    "color",
                    "is_active",
                )
            },
        ),
        (
            "System information",
            {
                "fields": (
                    "created_at",
                )
            },
        ),
    )


@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    # Etkinlik listesinde gösterilecek sütunları belirler.
    list_display = (
        "title",
        "category",
        "organizer",
        "city",
        "start_date",
        "capacity",
        "price",
        "status",
    )

    # Etkinliklerin belirtilen alanlara göre filtrelenmesini sağlar.
    list_filter = (
        "status",
        "category",
        "city",
        "start_date",
    )

    search_fields = (
        "title",
        "description",
        "city",
        "location_name",
        "organizer__email",
    )

    ordering = (
        "start_date",
    )

    date_hierarchy = "start_date"

    # Sistem tarafından oluşturulan tarihlerin değiştirilmesini engeller.
    readonly_fields = (
        "created_at",
        "updated_at",
    )

    # Etkinlik düzenleme formundaki alanları gruplandırır.
    fieldsets = (
        (
            "Event information",
            {
                "fields": (
                    "title",
                    "description",
                    "cover_image",
                    "category",
                    "status",
                )
            },
        ),
        (
            "Date and location",
            {
                "fields": (
                    "start_date",
                    "end_date",
                    "city",
                    "location_name",
                    "address",
                    "latitude",
                    "longitude",
                )
            },
        ),
        (
            "Capacity and pricing",
            {
                "fields": (
                    "capacity",
                    "price",
                )
            },
        ),
        (
            "Organizer",
            {
                "fields": (
                    "organizer",
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

    def formfield_for_foreignkey(
        self,
        db_field,
        request,
        **kwargs,
    ):
        """
        Organizatör alanında yalnızca organizatör rolündeki
        kullanıcıların gösterilmesini sağlar.
        """
        if db_field.name == "organizer":
            kwargs["queryset"] = (
                db_field.remote_field.model.objects.filter(
                    role="organizer",
                )
            )

        return super().formfield_for_foreignkey(
            db_field,
            request,
            **kwargs,
        )