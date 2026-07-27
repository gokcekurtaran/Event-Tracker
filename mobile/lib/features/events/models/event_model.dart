import 'category_model.dart';
import 'organizer_model.dart';

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.city,
    required this.locationName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.capacity,
    required this.participantCount,
    required this.remainingCapacity,
    required this.price,
    required this.isFree,
    required this.category,
    required this.organizer,
    required this.status,
    required this.isJoined,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String description;
  final String coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String city;
  final String locationName;
  final String address;
  final double? latitude; 
  final double? longitude;
  final int capacity;
  final int participantCount;
  final int remainingCapacity;
  final double price;
  final bool isFree;
  final CategoryModel category;
  final OrganizerModel organizer;
  final String status;
  final bool isJoined;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory EventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImage: json['cover_image']?.toString() ?? '',
      startDate: DateTime.parse(
        json['start_date'].toString(),
      ).toLocal(),
      endDate: DateTime.parse(
        json['end_date'].toString(),
      ).toLocal(),
      city: json['city']?.toString() ?? '',
      locationName:
          json['location_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _toNullableDouble(
        json['latitude'],
      ),
      longitude: _toNullableDouble(
        json['longitude'],
      ),
      capacity: _toInt(
        json['capacity'],
      ),
      participantCount: _toInt(
        json['participant_count'],
      ),
      remainingCapacity: _toInt(
        json['remaining_capacity'],
      ),
      price: _toDouble(
        json['price'],
      ),
      isFree: json['is_free'] == true,
      category: CategoryModel.fromJson(
        Map<String, dynamic>.from(
          json['category'] as Map,
        ),
      ),
      organizer: OrganizerModel.fromJson(
        Map<String, dynamic>.from(
          json['organizer'] as Map,
        ),
      ),
      status: json['status']?.toString() ?? '',
      isJoined: json['is_joined'] == true,
      isFavorite: json['is_favorite'] == true,
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ).toLocal(),
      updatedAt: DateTime.parse(
        json['updated_at'].toString(),
      ).toLocal(),
    );
  }
  // JSON içindeki int veya String değerini int'e dönüştürür.
  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
  // JSON içindeki sayısal değeri double'a dönüştürür.
  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
  // Boş bırakılabilen koordinat değerlerini dönüştürür.
  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  EventModel copyWith({
    int? participantCount,
    int? remainingCapacity,
    bool? isJoined,
    bool? isFavorite,
  }) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      coverImage: coverImage,
      startDate: startDate,
      endDate: endDate,
      city: city,
      locationName: locationName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      capacity: capacity,
      participantCount:
          participantCount ?? this.participantCount,
      remainingCapacity:
          remainingCapacity ?? this.remainingCapacity,
      price: price,
      isFree: isFree,
      category: category,
      organizer: organizer,
      status: status,
      isJoined: isJoined ?? this.isJoined,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}