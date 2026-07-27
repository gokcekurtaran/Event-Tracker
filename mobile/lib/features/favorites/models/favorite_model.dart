import '../../attendance/models/attendance_model.dart';


class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.event,
    required this.createdAt,
  });

  final int id;
  final AttendanceEventModel event;
  final DateTime createdAt;

  factory FavoriteModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FavoriteModel(
      id: json['id'] as int,
      event: AttendanceEventModel.fromJson(
        Map<String, dynamic>.from(
          json['event'] as Map,
        ),
      ),
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ).toLocal(),
    );
  }
}