import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../attendance/models/attendance_model.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../events/screens/event_detail_screen.dart';


class CalendarScreen
    extends ConsumerStatefulWidget {
  const CalendarScreen({
    super.key,
  });

  @override
  ConsumerState<CalendarScreen> createState() {
    return _CalendarScreenState();
  }
}


class _CalendarScreenState
    extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat =
      CalendarFormat.month;

  List<AttendanceModel> _eventsForDay(
    List<AttendanceModel> attendances,
    DateTime day,
  ) {
    return attendances.where(
      (attendance) {
        return isSameDay(
          attendance.event.startDate,
          day,
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(
      myAttendancesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
        ),
      ),
      body: attendanceState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(
                        myAttendancesProvider,
                      );
                    },
                    child: const Text(
                      'Try Again',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        data: (attendances) {
          final List<AttendanceModel>
              selectedEvents = _eventsForDay(
            attendances,
            _selectedDay,
          );

          return Column(
            children: [
              TableCalendar<AttendanceModel>(
                firstDay: DateTime.now().subtract(
                  const Duration(days: 365),
                ),
                lastDay: DateTime.now().add(
                  const Duration(days: 730),
                ),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(
                    _selectedDay,
                    day,
                  );
                },
                eventLoader: (day) {
                  return _eventsForDay(
                    attendances,
                    day,
                  );
                },
                onDaySelected: (
                  selectedDay,
                  focusedDay,
                ) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.twoWeeks:
                      'Two weeks',
                  CalendarFormat.week: 'Week',
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat(
                      'EEEE, MMMM d',
                    ).format(_selectedDay),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              Expanded(
                child: selectedEvents.isEmpty
                    ? const _NoCalendarEvent()
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          24,
                        ),
                        itemCount:
                            selectedEvents.length,
                        separatorBuilder: (
                          context,
                          index,
                        ) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final AttendanceModel
                              attendance =
                              selectedEvents[index];

                          return Card(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.all(
                                14,
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  attendance
                                      .event
                                      .categoryIcon,
                                ),
                              ),
                              title: Text(
                                attendance.event.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${DateFormat('HH:mm').format(attendance.event.startDate)}'
                                ' • ${attendance.event.locationName}',
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute<void>(
                                    builder: (
                                      context,
                                    ) {
                                      return EventDetailScreen(
                                        eventId:
                                            attendance
                                                .event
                                                .id,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _NoCalendarEvent extends StatelessWidget {
  const _NoCalendarEvent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No registered events on this day.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}