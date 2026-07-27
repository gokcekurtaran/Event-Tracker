from django.contrib.auth.base_user import BaseUserManager

class CustomUserManager(BaseUserManager):
    #Kullanıcı adı yerine e-posta adresiyle kullanıcı oluşturan özel yönetici sınıfıdır.
    # Normal kullanıcıyı katılımcı olarak oluşturmak

    def create_user(self, email, password=None, **extra_fields):
        # Kullanıcı oluşturulurken e-posta adresi zorunludur.
        if not email:
            raise ValueError("Email address is required.")

        email = self.normalize_email(email)
        # Yeni kullanıcılar varsayılan olarak katılımcı olur.
        extra_fields.setdefault("role", "participant")

        # Verilen bilgilerle kullanıcı nesnesini oluşturur
        user = self.model(
            email=email,
            **extra_fields,
        )

        # Şifreyi hash'leyerek saklar.
        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_superuser(self, email, password=None, **extra_fields):
        # Yönetici kullanıcısı için gerekli yetkileri tanımlar.
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("role", "organizer")

        if extra_fields.get("is_staff") is not True:
            raise ValueError(
                "A superuser must have is_staff=True."
            )

        if extra_fields.get("is_superuser") is not True:
            raise ValueError(
                "A superuser must have is_superuser=True."
            )

        # Doğrulanan bilgilerle yönetici kullanıcısını oluşturur
        return self.create_user(
            email=email,
            password=password,
            **extra_fields,
        )


