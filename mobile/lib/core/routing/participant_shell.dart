import 'package:flutter/material.dart';

import '../../features/attendance/screens/my_events_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/events/screens/participant_home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';


class ParticipantShell extends StatefulWidget {
  const ParticipantShell({
    super.key,
  });

  @override
  State<ParticipantShell> createState() {
    return _ParticipantShellState();
  }
}


class _ParticipantShellState
    extends State<ParticipantShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ParticipantHomeScreen(),
    MyEventsScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.event_note_outlined,
            ),
            selectedIcon: Icon(
              Icons.event_note_rounded,
            ),
            label: 'My Events',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}