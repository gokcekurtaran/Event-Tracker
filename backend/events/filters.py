import django_filters
from django.utils import timezone

from .models import Event


class EventFilter(django_filters.FilterSet):
    """
    Etkinliklerin kategori, şehir, tarih ve fiyat
    bilgilerine göre filtrelenmesini sağlar.
    """

    category = django_filters.NumberFilter(
        field_name="category_id",
    )

    city = django_filters.CharFilter(
        field_name="city",
        lookup_expr="iexact",
    )

    start_date = django_filters.DateTimeFilter(
        field_name="start_date",
        lookup_expr="gte",
    )

    end_date = django_filters.DateTimeFilter(
        field_name="start_date",
        lookup_expr="lte",
    )

    is_free = django_filters.BooleanFilter(
        method="filter_is_free",
    )

    upcoming = django_filters.BooleanFilter(
        method="filter_upcoming",
    )

    def filter_is_free(
        self,
        queryset,
        name,
        value,
    ):
        # Ücretsiz etkinlikleri fiyatı sıfır olanlardan belirler.
        if value is True:
            return queryset.filter(
                price=0,
            )

        if value is False:
            return queryset.filter(
                price__gt=0,
            )

        return queryset

    def filter_upcoming(
        self,
        queryset,
        name,
        value,
    ):
        # Yalnızca başlangıç tarihi henüz gelmemiş etkinlikleri döndürür.
        if value is True:
            return queryset.filter(
                start_date__gte=timezone.now(),
            )

        return queryset

    class Meta:
        model = Event

        fields = (
            "category",
            "city",
            "start_date",
            "end_date",
            "is_free",
            "upcoming",
        )