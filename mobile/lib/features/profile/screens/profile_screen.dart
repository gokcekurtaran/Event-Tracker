import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../favorites/screens/favorite_events_screen.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref
          .read(authProvider.notifier)
          .logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final attendanceState = ref.watch(
      myAttendancesProvider,
    );

    final user = authState.value;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final int eventCount =
        attendanceState.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          28,
        ),
        children: [
          Center(
            child: _ProfileAvatar(
              profileImage: user.profileImage,
              fullName: user.fullName,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 5),

          Text(
            user.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _ProfileStatistic(
                  value: eventCount.toString(),
                  label: 'My Events',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileStatistic(
                  value: user.city.isEmpty
                      ? '—'
                      : user.city,
                  label: 'City',
                ),
              ),
            ],
          ),

          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'About',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              user.bio,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 28),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: const Text(
                    'Edit Profile',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return EditProfileScreen(
          user: user,
        );
      },
    ),
  );
},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.favorite_border_rounded,
                  ),
                  title: const Text(
                    'Favorite Events',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return const FavoriteEventsScreen();
      },
    ),
  );
},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .error,
                    ),
                  ),
                  onTap: () {
                    _confirmLogout(
                      context,
                      ref,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profileImage,
    required this.fullName,
  });

  final String? profileImage;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final String firstCharacter =
        fullName.trim().isEmpty
            ? '?'
            : fullName.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: 52,
      backgroundColor: Theme.of(context)
          .colorScheme
          .primaryContainer,
      backgroundImage: profileImage != null &&
              profileImage!.isNotEmpty
          ? CachedNetworkImageProvider(
              profileImage!,
            )
          : null,
      child: profileImage == null ||
              profileImage!.isEmpty
          ? Text(
              firstCharacter,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    fontWeight: FontWeight.bold,
                  ),
            )
          : null,
    );
  }
}


class _ProfileStatistic extends StatelessWidget {
  const _ProfileStatistic({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 18,
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
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