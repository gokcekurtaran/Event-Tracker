class EventReportModel {
  const EventReportModel({
    required this.eventId,
    required this.eventTitle,
    required this.capacity,
    required this.registeredCount,
    required this.cancelledCount,
    required this.remainingCapacity,
    required this.checkedInCount,
    required this.notCheckedInCount,
    required this.attendanceRate,
  });

  final int eventId;
  final String eventTitle;
  final int capacity;
  final int registeredCount;
  final int cancelledCount;
  final int remainingCapacity;
  final int checkedInCount;
  final int notCheckedInCount;
  final double attendanceRate;

  factory EventReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> event =
        Map<String, dynamic>.from(
      json['event'] as Map,
    );

    final Map<String, dynamic> report =
        Map<String, dynamic>.from(
      json['report'] as Map,
    );

    return EventReportModel(
      eventId: event['id'] as int,
      eventTitle:
          event['title']?.toString() ?? '',
      capacity: _toInt(
        report['capacity'],
      ),
      registeredCount: _toInt(
        report['registered_count'],
      ),
      cancelledCount: _toInt(
        report['cancelled_count'],
      ),
      remainingCapacity: _toInt(
        report['remaining_capacity'],
      ),
      checkedInCount: _toInt(
        report['checked_in_count'],
      ),
      notCheckedInCount: _toInt(
        report['not_checked_in_count'],
      ),
      attendanceRate: _toDouble(
        report['attendance_rate'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
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