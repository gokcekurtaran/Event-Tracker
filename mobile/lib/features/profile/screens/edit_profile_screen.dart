import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen
    extends ConsumerStatefulWidget {
  const EditProfileScreen({
    required this.user,
    super.key,
  });

  final UserModel user;

  @override
  ConsumerState<EditProfileScreen> createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _firstNameController;

  late final TextEditingController
      _lastNameController;

  late final TextEditingController
      _cityController;

  late final TextEditingController
      _bioController;

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.user.firstName,
    );

    _lastNameController = TextEditingController(
      text: widget.user.lastName,
    );

    _cityController = TextEditingController(
      text: widget.user.city,
    );

    _bioController = TextEditingController(
      text: widget.user.bio,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  String? _validateRequired(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final UserModel updatedUser = await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            firstName:
                _firstNameController.text,
            lastName:
                _lastNameController.text,
            city: _cityController.text,
            bio: _bioController.text,
            imagePath: _selectedImage?.path,
          );

      // Güncellenen kullanıcı bilgisini bütün
      // uygulamaya aktarır.
      ref
          .read(authProvider.notifier)
          .updateCurrentUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your profile has been updated.',
            ),
          ),
        );

        Navigator.of(context).pop();
      }
    } on ProfileException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message,
            ),
            backgroundColor:
                Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _EditableAvatar(
                        selectedImage:
                            _selectedImage,
                        currentImage:
                            widget.user.profileImage,
                        fullName:
                            widget.user.fullName,
                      ),
                      IconButton.filled(
                        onPressed:
                            _isSaving ? null : _pickImage,
                        tooltip: 'Choose photo',
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                TextFormField(
                  initialValue: widget.user.email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _firstNameController,
                  enabled: !_isSaving,
                  textInputAction:
                      TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) {
                    return _validateRequired(
                      value,
                      'First name',
                    );
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _lastNameController,
                  enabled: !_isSaving,
                  textInputAction:
                      TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) {
                    return _validateRequired(
                      value,
                      'Last name',
                    );
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cityController,
                  enabled: !_isSaving,
                  textInputAction:
                      TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(
                      Icons.location_city_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  enabled: !_isSaving,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Biography',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: 72,
                      ),
                      child: Icon(
                        Icons.notes_rounded,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed:
                      _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.selectedImage,
    required this.currentImage,
    required this.fullName,
  });

  final XFile? selectedImage;
  final String? currentImage;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final String firstCharacter =
        fullName.trim().isEmpty
            ? '?'
            : fullName.trim()[0].toUpperCase();

    ImageProvider<Object>? imageProvider;

    if (selectedImage != null) {
      imageProvider = FileImage(
        File(selectedImage!.path),
      );
    } else if (
        currentImage != null &&
        currentImage!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(
        currentImage!,
      );
    }

    return CircleAvatar(
      radius: 62,
      backgroundColor: Theme.of(context)
          .colorScheme
          .primaryContainer,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              firstCharacter,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
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