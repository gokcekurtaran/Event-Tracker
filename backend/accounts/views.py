from rest_framework import generics, status
from rest_framework.parsers import (
    FormParser,
    JSONParser,
    MultiPartParser,
)
from rest_framework.permissions import (
    AllowAny,
    IsAuthenticated,
)
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import (
    OrganizerLoginSerializer,
    ParticipantLoginSerializer,
    RegisterSerializer,
    UserSerializer,
)


class RegisterView(generics.CreateAPIView):
    """
    Yalnızca katılımcı hesabı oluşturur.
    """

    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "register"

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(
            data=request.data,
        )

        serializer.is_valid(
            raise_exception=True,
        )

        user = serializer.save()

        # Kayıt tamamlandığında kullanıcı için token oluşturur.
        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "message": (
                    "Your account has been created successfully."
                ),
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": UserSerializer(
                    user,
                    context={
                        "request": request,
                    },
                ).data,
            },
            status=status.HTTP_201_CREATED,
        )


class ParticipantLoginView(TokenObtainPairView):
    """
    Katılımcı girişini gerçekleştirir.
    """

    serializer_class = ParticipantLoginSerializer
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "login"


class OrganizerLoginView(TokenObtainPairView):
    """
    Organizatör girişini gerçekleştirir.
    """

    serializer_class = OrganizerLoginSerializer
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "login"


class ProfileView(generics.RetrieveUpdateAPIView):
    """
    Giriş yapan kullanıcının profilini görüntüler ve günceller.
    """

    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    parser_classes = [
        JSONParser,
        MultiPartParser,
        FormParser,
    ]

    def get_object(self):
        # Access token'a ait kullanıcıyı döndürür.
        return self.request.user


class LogoutView(APIView):
    """
    Refresh token'ı geçersiz hâle getirerek güvenli çıkış yapar.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get(
            "refresh",
        )

        if not refresh_token:
            return Response(
                {
                    "refresh": (
                        "Refresh token is required."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # Refresh token'ı blacklist'e ekler.
            token = RefreshToken(refresh_token)
            token.blacklist()

            return Response(
                {
                    "message": (
                        "You have been logged out successfully."
                    )
                },
                status=status.HTTP_200_OK,
            )

        except TokenError:
            return Response(
                {
                    "refresh": (
                        "The refresh token is invalid or expired."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )