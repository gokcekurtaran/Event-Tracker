import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'register_screen.dart';


enum LoginRole {
  participant,
  organizer,
}


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  ConsumerState<LoginScreen> createState() {
    return _LoginScreenState();
  }
}


class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  LoginRole _selectedRole = LoginRole.participant;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required.';
    }

    final RegExp emailExpression = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailExpression.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == LoginRole.participant) {
      await ref
          .read(authProvider.notifier)
          .participantLogin(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } else {
      await ref
          .read(authProvider.notifier)
          .organizerLogin(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  void _openRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return const RegisterScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.event_available_rounded,
                      size: 38,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Welcome back',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Event Tracker.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 28),

                SegmentedButton<LoginRole>(
                  segments: const [
                    ButtonSegment<LoginRole>(
                      value: LoginRole.participant,
                      label: Text('Participant'),
                      icon: Icon(
                        Icons.person_outline_rounded,
                      ),
                    ),
                    ButtonSegment<LoginRole>(
                      value: LoginRole.organizer,
                      label: Text('Organizer'),
                      icon: Icon(
                        Icons.business_center_outlined,
                      ),
                    ),
                  ],
                  selected: {
                    _selectedRole,
                  },
                  onSelectionChanged: isLoading
                      ? null
                      : (selection) {
                          setState(() {
                            _selectedRole = selection.first;
                          });
                        },
                  showSelectedIcon: false,
                ),
                const SizedBox(height: 26),

                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [
                    AutofillHints.password,
                  ],
                  onFieldSubmitted: (_) {
                    _login();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),

                if (authState.hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context)
                              .colorScheme
                              .onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.error.toString(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedRole ==
                                  LoginRole.participant
                              ? 'Participant Login'
                              : 'Organizer Login',
                        ),
                ),

                if (_selectedRole ==
                    LoginRole.participant) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : _openRegisterScreen,
                        child: const Text(
                          'Create Account',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Organizer accounts are created '
                            'by the system administrator.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}