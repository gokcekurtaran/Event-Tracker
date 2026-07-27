import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../events/models/category_model.dart';
import '../../events/providers/event_provider.dart';
import '../data/organizer_repository.dart';
import '../providers/organizer_event_provider.dart';


class CreateEventScreen
    extends ConsumerStatefulWidget {
  const CreateEventScreen({
    super.key,
  });

  @override
  ConsumerState<CreateEventScreen> createState() {
    return _CreateEventScreenState();
  }
}


class _CreateEventScreenState
    extends ConsumerState<CreateEventScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _latitudeController =
      TextEditingController();

  final TextEditingController _longitudeController =
      TextEditingController();

  final TextEditingController _capacityController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController(
    text: '0',
  );

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _coverImage;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCategoryId;
  String _status = 'draft';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final XFile? image =
        await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _coverImage = image;
    });
  }

  Future<DateTime?> _pickDateTime({
    required DateTime initialDate,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate =
        await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now)
          ? now
          : initialDate,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: DateTime(
        now.year + 5,
      ),
    );

    if (selectedDate == null || !mounted) {
      return null;
    }

    final TimeOfDay? selectedTime =
        await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        initialDate,
      ),
    );

    if (selectedTime == null) {
      return null;
    }

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime initialDate =
        _startDate ??
        DateTime.now().add(
          const Duration(days: 1),
        );

    final DateTime? selectedDate =
        await _pickDateTime(
      initialDate: initialDate,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _startDate = selectedDate;

      // Bitiş tarihi başlangıçtan önceyse otomatik düzeltir.
      if (
          _endDate == null ||
          !_endDate!.isAfter(selectedDate)) {
        _endDate = selectedDate.add(
          const Duration(hours: 2),
        );
      }
    });
  }

  Future<void> _selectEndDate() async {
    final DateTime initialDate =
        _endDate ??
        (_startDate ?? DateTime.now()).add(
          const Duration(hours: 2),
        );

    final DateTime? selectedDate =
        await _pickDateTime(
      initialDate: initialDate,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _endDate = selectedDate;
    });
  }

  String? _requiredValidator(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  String? _capacityValidator(String? value) {
    final int? capacity = int.tryParse(
      value?.trim() ?? '',
    );

    if (capacity == null || capacity < 1) {
      return 'Capacity must be at least 1.';
    }

    return null;
  }

  String? _priceValidator(String? value) {
    final double? price = double.tryParse(
      value?.trim().replaceAll(',', '.') ?? '',
    );

    if (price == null || price < 0) {
      return 'Enter a valid ticket price.';
    }

    return null;
  }

  double? _optionalDouble(
    TextEditingController controller,
  ) {
    final String value = controller.text
        .trim()
        .replaceAll(',', '.');

    if (value.isEmpty) {
      return null;
    }

    return double.tryParse(value);
  }

  Future<void> _createEvent() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_coverImage == null) {
      _showMessage(
        'Please select a cover image.',
        isError: true,
      );
      return;
    }

    if (_selectedCategoryId == null) {
      _showMessage(
        'Please select a category.',
        isError: true,
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showMessage(
        'Please select the start and end dates.',
        isError: true,
      );
      return;
    }

    if (!_endDate!.isAfter(_startDate!)) {
      _showMessage(
        'The end date must be later than the start date.',
        isError: true,
      );
      return;
    }

    final double? latitude = _optionalDouble(
      _latitudeController,
    );

    final double? longitude = _optionalDouble(
      _longitudeController,
    );

    if (
        _latitudeController.text.trim().isNotEmpty &&
        latitude == null) {
      _showMessage(
        'Enter a valid latitude.',
        isError: true,
      );
      return;
    }

    if (
        _longitudeController.text.trim().isNotEmpty &&
        longitude == null) {
      _showMessage(
        'Enter a valid longitude.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(organizerRepositoryProvider)
          .createEvent(
            title: _titleController.text,
            description:
                _descriptionController.text,
            coverImagePath:
                _coverImage!.path,
            startDate: _startDate!,
            endDate: _endDate!,
            city: _cityController.text,
            locationName:
                _locationController.text,
            address: _addressController.text,
            latitude: latitude,
            longitude: longitude,
            capacity: int.parse(
              _capacityController.text.trim(),
            ),
            price: double.parse(
              _priceController.text
                  .trim()
                  .replaceAll(',', '.'),
            ),
            categoryId:
                _selectedCategoryId!,
            status: _status,
          );

      await ref
          .read(
            organizerEventsProvider.notifier,
          )
          .refreshEvents();

      if (mounted) {
        _showMessage(
          'The event has been created successfully.',
        );

        Navigator.of(context).pop();
      }
    } on OrganizerException catch (error) {
      if (mounted) {
        _showMessage(
          error.message,
          isError: true,
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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(
      categoriesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Event',
        ),
      ),
      body: categoriesState.when(
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
                  categoriesProvider,
                );
              },
              child: const Text(
                'Retry Categories',
              ),
            ),
          );
        },
        data: (categories) {
          return _buildForm(
            context,
            categories,
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<CategoryModel> categories,
  ) {
    final DateFormat dateFormat = DateFormat(
      'MMM d, yyyy • HH:mm',
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap:
                    _isSaving ? null : _pickCoverImage,
                borderRadius:
                    BorderRadius.circular(18),
                child: Container(
                  height: 210,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: _coverImage == null
                      ? const Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 52,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Select Cover Image',
                            ),
                          ],
                        )
                      : Image.file(
                          File(
                            _coverImage!.path,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 22),

              TextFormField(
                controller: _titleController,
                enabled: !_isSaving,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(
                    Icons.title_rounded,
                  ),
                ),
                validator: (value) {
                  return _requiredValidator(
                    value,
                    'Title',
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _descriptionController,
                enabled: !_isSaving,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  return _requiredValidator(
                    value,
                    'Description',
                  );
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                items: categories.map(
                  (category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        '${category.icon} '
                        '${category.name}',
                      ),
                    );
                  },
                ).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategoryId =
                              value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Category is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              _DateSelectionField(
                label: 'Start date',
                value: _startDate == null
                    ? 'Select start date'
                    : dateFormat.format(
                        _startDate!,
                      ),
                onTap: _selectStartDate,
              ),
              const SizedBox(height: 16),

              _DateSelectionField(
                label: 'End date',
                value: _endDate == null
                    ? 'Select end date'
                    : dateFormat.format(
                        _endDate!,
                      ),
                onTap: _selectEndDate,
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
                validator: (value) {
                  return _requiredValidator(
                    value,
                    'City',
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _locationController,
                enabled: !_isSaving,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Location name',
                  prefixIcon: Icon(
                    Icons.place_outlined,
                  ),
                ),
                validator: (value) {
                  return _requiredValidator(
                    value,
                    'Location name',
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                enabled: !_isSaving,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  return _requiredValidator(
                    value,
                    'Address',
                  );
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:
                          _latitudeController,
                      enabled: !_isSaving,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Latitude',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _longitudeController,
                      enabled: !_isSaving,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Longitude',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:
                          _capacityController,
                      enabled: !_isSaving,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText: 'Capacity',
                      ),
                      validator:
                          _capacityValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _priceController,
                      enabled: !_isSaving,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Ticket price',
                        suffixText: '₺',
                      ),
                      validator: _priceValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Publication status',
                  prefixIcon: Icon(
                    Icons.visibility_outlined,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'draft',
                    child: Text('Draft'),
                  ),
                  DropdownMenuItem(
                    value: 'published',
                    child: Text('Published'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _status = value;
                        });
                      },
              ),
              const SizedBox(height: 26),

              ElevatedButton(
                onPressed:
                    _isSaving ? null : _createEvent,
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
                        'Create Event',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _DateSelectionField extends StatelessWidget {
  const _DateSelectionField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),
        child: Text(value),
      ),
    );
  }
}