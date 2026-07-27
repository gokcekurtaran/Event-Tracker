from rest_framework.routers import DefaultRouter

from .views import CategoryViewSet, EventViewSet


router = DefaultRouter()

# Dinamik kategori endpoint'lerini oluşturur.
router.register(
    "categories",
    CategoryViewSet,
    basename="category",
)

# Etkinlik endpoint'lerini oluşturur.
router.register(
    "events",
    EventViewSet,
    basename="event",
)


urlpatterns = router.urls