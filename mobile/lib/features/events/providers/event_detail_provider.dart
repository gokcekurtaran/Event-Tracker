import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'event_provider.dart';

// Detay ekranından çıkıldığında etkinlik verisini
// önbellekten otomatik olarak kaldırır.
final eventDetailProvider = FutureProvider.autoDispose.family<EventModel, int>((
  ref,
  eventId,
) async {
  return ref.watch(eventRepositoryProvider).getEventDetail(eventId);
});
