import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'edit_event_screen.dart';
import '../../events/providers/event_detail_provider.dart';
import 'event_report_screen.dart';
import 'participant_list_screen.dart';


class OrganizerEventDetailScreen
    extends ConsumerWidget {
  const OrganizerEventDetailScreen({
    required this.eventId,
    super.key,
  });

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(
      eventDetailProvider(eventId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Event',
        ),
      ),
      body: eventState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  eventDetailProvider(eventId),
                );
              },
              child: const Text('Try Again'),
            ),
          );
        },
        data: (event) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                event.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat(
                  'MMM d, yyyy • HH:mm',
                ).format(event.startDate),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _ManagementStatistic(
                      value:
                          event.participantCount.toString(),
                      label: 'Participants',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ManagementStatistic(
                      value: event.remainingCapacity
                          .toString(),
                      label: 'Remaining',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.edit_outlined,
                      ),
                      title: const Text(
                        'Edit Event',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return EditEventScreen(
          event: event,
        );
      },
    ),
  );
},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.groups_outlined,
                      ),
                      title: const Text(
                        'View Participants',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return ParticipantListScreen(
                                eventId: event.id,
                                eventTitle: event.title,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.analytics_outlined,
                      ),
                      title: const Text(
                        'Attendance Report',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return EventReportScreen(
                                eventId: event.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _ManagementStatistic extends StatelessWidget {
  const _ManagementStatistic({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}