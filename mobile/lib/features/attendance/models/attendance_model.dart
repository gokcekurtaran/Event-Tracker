class AttendanceEventModel {
  const AttendanceEventModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.city,
    required this.locationName,
    required this.price,
    required this.isFree,
    required this.categoryName,
    required this.categoryIcon,
    required this.status,
  });

  final int id;
  final String title;
  final String coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String city;
  final String locationName;
  final double price;
  final bool isFree;
  final String categoryName;
  final String categoryIcon;
  final String status;

  factory AttendanceEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceEventModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      coverImage:
          json['cover_image']?.toString() ?? '',
      startDate: DateTime.parse(
        json['start_date'].toString(),
      ).toLocal(),
      endDate: DateTime.parse(
        json['end_date'].toString(),
      ).toLocal(),
      city: json['city']?.toString() ?? '',
      locationName:
          json['location_name']?.toString() ?? '',
      price: _toDouble(
        json['price'],
      ),
      isFree: json['is_free'] == true,
      categoryName:
          json['category_name']?.toString() ?? '',
      categoryIcon:
          json['category_icon']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}


class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.event,
    required this.status,
    required this.isCheckedIn,
    this.checkedInAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final AttendanceEventModel event;
  final String status;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AttendanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic checkedInValue =
        json['checked_in_at'];

    return AttendanceModel(
      id: json['id'] as int,
      event: AttendanceEventModel.fromJson(
        Map<String, dynamic>.from(
          json['event'] as Map,
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
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ).toLocal(),
      updatedAt: DateTime.parse(
        json['updated_at'].toString(),
      ).toLocal(),
    );
  }
}