from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.http import JsonResponse
from django.urls import include, path


def api_home(request):
    """
    Backend ana adresinde API'nin çalışma durumunu gösterir.
    """

    return JsonResponse(
        {
            "message": "Event Tracker API is running.",
            "version": "1.0.0",
            "endpoints": {
                "participant_register": (
                    "/api/auth/register/"
                ),
                "participant_login": (
                    "/api/auth/participant/login/"
                ),
                "organizer_login": (
                    "/api/auth/organizer/login/"
                ),
                "profile": (
                    "/api/auth/profile/"
                ),
                "categories": (
                    "/api/categories/"
                ),
                "events": (
                    "/api/events/"
                ),
                "my_attendances": (
                    "/api/me/attendances/"
                ),
                "my_favorites": (
                    "/api/me/favorites/"
                ),
                "admin": (
                    "/admin/"
                ),
            },
        }
    )


urlpatterns = [
    # Backend'in çalıştığını gösteren ana API sayfası
    path(
        "",
        api_home,
        name="api-home",
    ),

    # Django yönetim paneli
    path(
        "admin/",
        admin.site.urls,
    ),

    # Kullanıcı işlemleri
    path(
        "api/auth/",
        include("accounts.urls"),
    ),

    # Kategori ve etkinlik işlemleri
    path(
        "api/",
        include("events.urls"),
    ),

    # Katılım ve favori işlemleri
    path(
        "api/",
        include("attendance.urls"),
    ),
]


# Geliştirme aşamasında yüklenen medya dosyalarını sunar.
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT,
    )