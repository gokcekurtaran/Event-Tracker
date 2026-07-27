import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../events/models/category_model.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_detail_provider.dart';
import '../../events/providers/event_provider.dart';
import '../data/organizer_repository.dart';
import '../providers/organizer_event_provider.dart';


class EditEventScreen
    extends ConsumerStatefulWidget {
  const EditEventScreen({
    required this.event,
    super.key,
  });

  final EventModel event;

  @override
  ConsumerState<EditEventScreen> createState() {
    return _EditEventScreenState();
  }
}


class _EditEventScreenState
    extends ConsumerState<EditEventScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _titleController;

  late final TextEditingController
      _descriptionController;

  late final TextEditingController
      _cityController;

  late final TextEditingController
      _locationController;

  late final TextEditingController
      _addressController;

  late final TextEditingController
      _latitudeController;

  late final TextEditingController
      _longitudeController;

  late final TextEditingController
      _capacityController;

  late final TextEditingController
      _priceController;

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _newCoverImage;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _selectedCategoryId;
  late String _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final EventModel event = widget.event;

    _titleController = TextEditingController(
      text: event.title,
    );

    _descriptionController = TextEditingController(
      text: event.description,
    );

    _cityController = TextEditingController(
      text: event.city,
    );

    _locationController = TextEditingController(
      text: event.locationName,
    );

    _addressController = TextEditingController(
      text: event.address,
    );

    _latitudeController = TextEditingController(
      text: event.latitude?.toString() ?? '',
    );

    _longitudeController = TextEditingController(
      text: event.longitude?.toString() ?? '',
    );

    _capacityController = TextEditingController(
      text: event.capacity.toString(),
    );

    _priceController = TextEditingController(
      text: event.price.toStringAsFixed(2),
    );

    _startDate = event.startDate;
    _endDate = event.endDate;
    _selectedCategoryId = event.category.id;
    _status = event.status;
  }

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
      _newCoverImage = image;
    });
  }

  Future<DateTime?> _pickDateTime(
    DateTime initialDate,
  ) async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(
        now.year - 1,
      ),
      lastDate: DateTime(
        now.year + 5,
      ),
    );

    if (date == null || !mounted) {
      return null;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        initialDate,
      ),
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? value =
        await _pickDateTime(
      _startDate,
    );

    if (value == null || !mounted) {
      return;
    }

    setState(() {
      _startDate = value;

      if (!_endDate.isAfter(value)) {
        _endDate = value.add(
          const Duration(hours: 2),
        );
      }
    });
  }

  Future<void> _selectEndDate() async {
    final DateTime? value =
        await _pickDateTime(
      _endDate,
    );

    if (value == null || !mounted) {
      return;
    }

    setState(() {
      _endDate = value;
    });
  }

  String? _required(
    String? value,
    String name,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$name is required.';
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

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_endDate.isAfter(_startDate)) {
      _showMessage(
        'The end date must be later than the start date.',
        isError: true,
      );
      return;
    }

    final int? capacity = int.tryParse(
      _capacityController.text.trim(),
    );

    final double? price = double.tryParse(
      _priceController.text
          .trim()
          .replaceAll(',', '.'),
    );

    if (capacity == null || capacity < 1) {
      _showMessage(
        'Capacity must be at least 1.',
        isError: true,
      );
      return;
    }

    if (price == null || price < 0) {
      _showMessage(
        'Enter a valid ticket price.',
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
        latitude != null &&
        (latitude < -90 || latitude > 90)) {
      _showMessage(
        'Latitude must be between -90 and 90.',
        isError: true,
      );
      return;
    }

    if (
        longitude != null &&
        (longitude < -180 || longitude > 180)) {
      _showMessage(
        'Longitude must be between -180 and 180.',
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
          .updateEvent(
            eventId: widget.event.id,
            title: _titleController.text,
            description:
                _descriptionController.text,
            coverImagePath:
                _newCoverImage?.path,
            startDate: _startDate,
            endDate: _endDate,
            city: _cityController.text,
            locationName:
                _locationController.text,
            address: _addressController.text,
            latitude: latitude,
            longitude: longitude,
            capacity: capacity,
            price: price,
            categoryId:
                _selectedCategoryId,
            status: _status,
          );

      // Organizatör listesini ve detay ekranını yeniler.
      ref.invalidate(
        eventDetailProvider(widget.event.id),
      );

      await ref
          .read(
            organizerEventsProvider.notifier,
          )
          .refreshEvents();

      if (mounted) {
        _showMessage(
          'The event has been updated successfully.',
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
          'Edit Event',
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
    final DateFormat formatter = DateFormat(
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
                onTap: _isSaving
                    ? null
                    : _pickCoverImage,
                borderRadius:
                    BorderRadius.circular(18),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(18),
                  child: SizedBox(
                    height: 210,
                    child: _newCoverImage != null
                        ? Image.file(
                            File(
                              _newCoverImage!.path,
                            ),
                            fit: BoxFit.cover,
                          )
                        : widget.event.coverImage.isEmpty
                            ? Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: const Icon(
                                  Icons
                                      .add_photo_alternate_outlined,
                                  size: 52,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: widget
                                    .event
                                    .coverImage,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              TextFormField(
                controller: _titleController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  return _required(
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
                ),
                validator: (value) {
                  return _required(
                    value,
                    'Description',
                  );
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue:
                    _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: categories.map(
                  (CategoryModel category) {
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
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId =
                                value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),

              _EditDateField(
                label: 'Start date',
                value: formatter.format(
                  _startDate,
                ),
                onTap: _selectStartDate,
              ),
              const SizedBox(height: 16),

              _EditDateField(
                label: 'End date',
                value: formatter.format(
                  _endDate,
                ),
                onTap: _selectEndDate,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cityController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'City',
                ),
                validator: (value) {
                  return _required(
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
                decoration: const InputDecoration(
                  labelText: 'Location name',
                ),
                validator: (value) {
                  return _required(
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
                ),
                validator: (value) {
                  return _required(
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
                      decoration:
                          const InputDecoration(
                        labelText: 'Latitude',
                      ),
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _longitudeController,
                      enabled: !_isSaving,
                      decoration:
                          const InputDecoration(
                        labelText: 'Longitude',
                      ),
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
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
                      decoration:
                          const InputDecoration(
                        labelText: 'Capacity',
                      ),
                      keyboardType:
                          TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _priceController,
                      enabled: !_isSaving,
                      decoration:
                          const InputDecoration(
                        labelText: 'Ticket price',
                        suffixText: '₺',
                      ),
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText:
                      'Publication status',
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
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 26),

              ElevatedButton(
                onPressed:
                    _isSaving ? null : _save,
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
    );
  }
}


class _EditDateField extends StatelessWidget {
  const _EditDateField({
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