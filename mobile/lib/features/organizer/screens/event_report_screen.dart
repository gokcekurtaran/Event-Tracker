import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/organizer_management_provider.dart';


class EventReportScreen extends ConsumerWidget {
  const EventReportScreen({
    required this.eventId,
    super.key,
  });

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(
      organizerReportProvider(eventId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Report',
        ),
      ),
      body: reportState.when(
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
                  organizerReportProvider(eventId),
                );
              },
              child: const Text(
                'Try Again',
              ),
            ),
          );
        },
        data: (report) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                organizerReportProvider(eventId),
              );

              await ref.read(
                organizerReportProvider(
                  eventId,
                ).future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  report.eventTitle,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _ReportCard(
                      title: 'Capacity',
                      value:
                          report.capacity.toString(),
                      icon: Icons.groups_outlined,
                    ),
                    _ReportCard(
                      title: 'Registered',
                      value: report.registeredCount
                          .toString(),
                      icon:
                          Icons.how_to_reg_outlined,
                    ),
                    _ReportCard(
                      title: 'Remaining',
                      value: report.remainingCapacity
                          .toString(),
                      icon:
                          Icons.event_seat_outlined,
                    ),
                    _ReportCard(
                      title: 'Cancelled',
                      value: report.cancelledCount
                          .toString(),
                      icon:
                          Icons.person_off_outlined,
                    ),
                    _ReportCard(
                      title: 'Checked In',
                      value: report.checkedInCount
                          .toString(),
                      icon:
                          Icons.check_circle_outline,
                    ),
                    _ReportCard(
                      title: 'Attendance Rate',
                      value:
                          '${report.attendanceRate.toStringAsFixed(1)}%',
                      icon:
                          Icons.analytics_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.schedule_outlined,
                    ),
                    title: const Text(
                      'Not Checked In',
                    ),
                    trailing: Text(
                      report.notCheckedInCount
                          .toString(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}