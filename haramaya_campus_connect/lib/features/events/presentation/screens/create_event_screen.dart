import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/utils/date_utils.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/utils/validators.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  final _capacityController = TextEditingController();

  EventCategory _category = EventCategory.academic;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _locationDetailsController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserModelProvider);
    if (user == null) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    setState(() => _isLoading = true);

    try {
      final newEvent = EventModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: _locationController.text.trim(),
        locationDetails: _locationDetailsController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        organizerId: user.uid,
        organizerName: user.fullName,
        isFeatured: user.role.isAdmin && _isFeatured,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(eventRepositoryProvider).createEvent(newEvent);

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Event published successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserModelProvider);
    final isAdmin = user?.role.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campus Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g. Annual Tech Symposium 2026',
                  prefixIcon: Icon(Icons.event_available_rounded),
                ),
                validator: (val) => Validators.required(val, 'Event Title'),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: EventCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 18, color: cat.color),
                        const SizedBox(width: 8),
                        Text(cat.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Start Date & Time Row
              const Text('Start Date & Time', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(AppDateUtils.shortDate(_startDate)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartTime,
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(_startTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // End Date & Time Row
              const Text('End Date & Time', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(AppDateUtils.shortDate(_endDate)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndTime,
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(_endTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Venue / Location',
                  hintText: 'e.g. Aday Abeba Hall or Main Library',
                  prefixIcon: Icon(Icons.place_rounded),
                ),
                validator: (val) => Validators.required(val, 'Venue'),
              ),
              const SizedBox(height: 16),

              // Location Details
              TextFormField(
                controller: _locationDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Location Details (Optional)',
                  hintText: 'e.g. Room 204, 2nd Floor',
                  prefixIcon: Icon(Icons.info_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Capacity',
                  hintText: '100',
                  prefixIcon: Icon(Icons.group_rounded),
                ),
                validator: Validators.eventCapacity,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                  hintText: 'Describe event agenda, speakers, requirements...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => Validators.required(val, 'Description'),
              ),
              const SizedBox(height: 16),

              if (isAdmin)
                SwitchListTile(
                  title: const Text('Highlight as Featured Event'),
                  subtitle: const Text('Shows prominently on campus home feed'),
                  value: _isFeatured,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isFeatured = val),
                ),
              const SizedBox(height: 24),

              CustomButton(
                label: 'Publish Event',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

