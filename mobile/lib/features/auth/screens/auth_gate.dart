import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/participant_shell.dart';
import '../../organizer/screens/organizer_home_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () {
        return const _AuthLoadingScreen();
      },
      error: (error, stackTrace) {
        return const LoginScreen();
      },
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        if (user.isOrganizerMode) {
  return const OrganizerHomeScreen();
}
        return const ParticipantShell();
      },
    );
  }
}


class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}