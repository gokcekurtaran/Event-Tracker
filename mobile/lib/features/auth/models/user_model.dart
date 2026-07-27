class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.loginMode,
    this.profileImage,
    required this.city,
    required this.bio,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;

  // Kullanıcının veritabanındaki gerçek yetki rolüdür.
  final String role;

  // Kullanıcının hangi bölümden giriş yaptığını belirtir.
  final String loginMode;

  final String? profileImage;
  final String city;
  final String bio;

  bool get isParticipant =>
      role == 'participant';

  bool get isOrganizer =>
      role == 'organizer';

  bool get isParticipantMode =>
      loginMode == 'participant';

  bool get isOrganizerMode =>
      loginMode == 'organizer';

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final String role =
        json['role']?.toString() ?? 'participant';

    return UserModel(
      id: json['id'] as int,
      email: json['email']?.toString() ?? '',
      firstName:
          json['first_name']?.toString() ?? '',
      lastName:
          json['last_name']?.toString() ?? '',
      fullName:
          json['full_name']?.toString() ?? '',
      role: role,

      // login_mode gelmezse gerçek role göre
      // varsayılan mod belirlenir.
      loginMode:
          json['login_mode']?.toString() ?? role,

      profileImage:
          json['profile_image']?.toString(),
      city: json['city']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
    );
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? role,
    String? loginMode,
    String? profileImage,
    String? city,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName:
          firstName ?? this.firstName,
      lastName:
          lastName ?? this.lastName,
      fullName:
          fullName ?? this.fullName,
      role: role ?? this.role,
      loginMode:
          loginMode ?? this.loginMode,
      profileImage:
          profileImage ?? this.profileImage,
      city: city ?? this.city,
      bio: bio ?? this.bio,
    );
  }
}