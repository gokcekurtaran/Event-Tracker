from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    LogoutView,
    OrganizerLoginView,
    ParticipantLoginView,
    ProfileView,
    RegisterView,
)


app_name = "accounts"


urlpatterns = [
    # Yalnızca katılımcı hesabı oluşturur.
    path(
        "register/",
        RegisterView.as_view(),
        name="register",
    ),

    # Yalnızca katılımcı girişini gerçekleştirir.
    path(
        "participant/login/",
        ParticipantLoginView.as_view(),
        name="participant-login",
    ),

    # Yalnızca organizatör girişini gerçekleştirir.
    path(
        "organizer/login/",
        OrganizerLoginView.as_view(),
        name="organizer-login",
    ),

    # Refresh token ile yeni token üretir.
    path(
        "refresh/",
        TokenRefreshView.as_view(),
        name="token-refresh",
    ),

    # Giriş yapan kullanıcının profilini yönetir.
    path(
        "profile/",
        ProfileView.as_view(),
        name="profile",
    ),

    # Kullanıcının güvenli şekilde çıkış yapmasını sağlar.
    path(
        "logout/",
        LogoutView.as_view(),
        name="logout",
    ),
]