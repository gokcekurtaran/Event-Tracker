import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../events/screens/event_detail_screen.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';


class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({
    super.key,
  });

  Future<void> _refresh(
    WidgetRef ref,
  ) async {
    ref.invalidate(
      myAttendancesProvider,
    );

    await ref.read(
      myAttendancesProvider.future,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(
      myAttendancesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
        ),
      ),
      body: attendanceState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _AttendanceErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                myAttendancesProvider,
              );
            },
          );
        },
        data: (attendances) {
          if (attendances.isEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return _refresh(ref);
              },
              child: const CustomScrollView(
                physics:
                    AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyAttendanceView(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return _refresh(ref);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                28,
              ),
              itemCount: attendances.length,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                final AttendanceModel attendance =
                    attendances[index];

                return _AttendanceCard(
                  attendance: attendance,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) {
                          return EventDetailScreen(
                            eventId:
                                attendance.event.id,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.attendance,
    required this.onTap,
  });

  final AttendanceModel attendance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AttendanceEventModel event =
        attendance.event;

    final DateFormat dateFormat = DateFormat(
      'MMM d, yyyy • HH:mm',
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 145,
              child: event.coverImage.isEmpty
                  ? Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Icon(
                        Icons.event_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: event.coverImage,
                      fit: BoxFit.cover,
                      errorWidget: (
                        context,
                        url,
                        error,
                      ) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: const Icon(
                            Icons.event_rounded,
                          ),
                        );
                      },
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.categoryIcon} '
                      '${event.categoryName}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),

                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 9),

                    Text(
                      dateFormat.format(
                        event.startDate,
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '${event.locationName}, '
                      '${event.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _AttendanceStatus(
                      isCheckedIn:
                          attendance.isCheckedIn,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _AttendanceStatus extends StatelessWidget {
  const _AttendanceStatus({
    required this.isCheckedIn,
  });

  final bool isCheckedIn;

  @override
  Widget build(BuildContext context) {
    final Color color = isCheckedIn
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isCheckedIn
            ? 'Checked In'
            : 'Registered',
        style: TextStyle(
          color: isCheckedIn
          ? Colors.green.shade700
          : Colors.orange.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


class _EmptyAttendanceView extends StatelessWidget {
  const _EmptyAttendanceView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 68,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              'No registered events',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Events you join will appear here.',
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


class _AttendanceErrorView extends StatelessWidget {
  const _AttendanceErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}