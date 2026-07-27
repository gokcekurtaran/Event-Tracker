import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_report_model.dart';
import '../models/organizer_participant_model.dart';
import 'organizer_event_provider.dart';


final organizerParticipantsProvider =
    FutureProvider.family<
        List<OrganizerParticipantModel>,
        int>(
  (ref, eventId) {
    return ref
        .watch(organizerRepositoryProvider)
        .getParticipants(eventId);
  },
);


final organizerReportProvider =
    FutureProvider.family<EventReportModel, int>(
  (ref, eventId) {
    return ref
        .watch(organizerRepositoryProvider)
        .getEventReport(eventId);
  },
);