import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_model.dart';

final attendanceRepositoryProvider =
    Provider<AttendanceRepository>(
  (ref) {
    return AttendanceRepository(
      ref.watch(apiClientProvider),
    );
  },
);

// Kullanıcının katıldığı etkinlikleri backend'den getirir.
final myAttendancesProvider =
    FutureProvider<List<AttendanceModel>>(
  (ref) {
    return ref
        .watch(attendanceRepositoryProvider)
        .getMyAttendances();
  },
);