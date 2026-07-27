class OrganizerModel {
  const OrganizerModel({
    required this.id,
    required this.fullName,
    this.profileImage,
  });

  final int id;
  final String fullName;
  final String? profileImage;

  factory OrganizerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrganizerModel(
      id: json['id'] as int,
      fullName: json['full_name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }
}