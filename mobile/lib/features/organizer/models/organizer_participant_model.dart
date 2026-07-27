class ParticipantUserModel {
  const ParticipantUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.profileImage,
    required this.city,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? profileImage;
  final String city;

  factory ParticipantUserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ParticipantUserModel(
      id: _toInt(
        json['id'],
      ),
      email: json['email']?.toString() ?? '',
      firstName:
          json['first_name']?.toString() ?? '',
      lastName:
          json['last_name']?.toString() ?? '',
      fullName:
          json['full_name']?.toString() ?? '',
      profileImage:
          json['profile_image']?.toString(),
      city: json['city']?.toString() ?? '',
    );
  }

  // JSON içindeki kimlik değerini int türüne dönüştürür.
  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}


class OrganizerParticipantModel {
  const OrganizerParticipantModel({
    required this.id,
    required this.user,
    required this.status,
    required this.isCheckedIn,
    this.checkedInAt,
    required this.registeredAt,
    required this.updatedAt,
  });

  final int id;
  final ParticipantUserModel user;
  final String status;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final DateTime registeredAt;
  final DateTime updatedAt;

  factory OrganizerParticipantModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic checkedInValue =
        json['checked_in_at'];

    return OrganizerParticipantModel(
      id: _toInt(
        json['id'],
      ),
      user: ParticipantUserModel.fromJson(
        Map<String, dynamic>.from(
          json['user'] as Map,
        ),
      ),
      status: json['status']?.toString() ?? '',
      isCheckedIn:
          json['is_checked_in'] == true,
      checkedInAt: checkedInValue == null
          ? null
          : DateTime.parse(
              checkedInValue.toString(),
            ).toLocal(),
      registeredAt: DateTime.parse(
        json['registered_at'].toString(),
      ).toLocal(),
      updatedAt: DateTime.parse(
        json['updated_at'].toString(),
      ).toLocal(),
    );
  }

  // JSON içindeki kimlik değerini int türüne dönüştürür.
  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}