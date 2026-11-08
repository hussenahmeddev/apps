import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/utils/date_utils.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/utils/validators.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/core/widgets/error_widget.dart';
import 'package:haramaya_campus_connect/core/widgets/loading_widget.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/providers/admin_provider.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/events/domain/enums/event_category.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  final _capacityController = TextEditingController();

  EventCategory _category = EventCategory.academic;
  EventStatus _status = EventStatus.published;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isFeatured = false;
  bool _isLoading = false;
  bool _initialized = false;
  EventModel? _originalEvent;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _locationDetailsController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _populateEvent(EventModel event) {
    if (_initialized) return;
    _initialized = true;
    _originalEvent = event;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _locationDetailsController.text = event.locationDetails ?? '';
    _capacityController.text = event.capacity.toString();
    _category = event.category;
    _status = event.status;
    _startDate = event.startDateTime;
    _startTime = TimeOfDay.fromDateTime(event.startDateTime);
    _endDate = event.endDateTime;
    _endTime = TimeOfDay.fromDateTime(event.endDateTime);
    _isFeatured = event.isFeatured;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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
    if (!_formKey.currentState!.validate() || _originalEvent == null) return;

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
      final updatedEvent = _originalEvent!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        status: _status,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: _locationController.text.trim(),
        locationDetails: _locationDetailsController.text.trim().isEmpty
            ? null
            : _locationDetailsController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        isFeatured:
            user.role.isAdmin ? _isFeatured : _originalEvent!.isFeatured,
        updatedAt: DateTime.now(),
      );

      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);
      ref.invalidate(eventDetailProvider(widget.eventId));
      ref.invalidate(eventsStreamProvider);
      ref.invalidate(featuredEventsProvider);
      ref.invalidate(upcomingEventsProvider);
      ref.invalidate(adminStatsProvider);

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Event updated successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to update event: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(eventRepositoryProvider).deleteEvent(widget.eventId);
      ref.invalidate(eventsStreamProvider);
      ref.invalidate(featuredEventsProvider);
      ref.invalidate(upcomingEventsProvider);
      ref.invalidate(adminStatsProvider);

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Event deleted successfully');
        // Pop edit screen and detail screen back to events list
        context.pop();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to delete event: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final user = ref.watch(currentUserModelProvider);
    final isAdmin = user?.role.isAdmin ?? false;

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return const Scaffold(
            body: AppErrorWidget(message: 'Event not found'),
          );
        }

        _populateEvent(event);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Campus Event'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                tooltip: 'Delete Event',
                onPressed: _isLoading ? null : _deleteEvent,
              ),
            ],
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

                  // Event Status Dropdown
                  DropdownButtonFormField<EventStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: EventStatus.values.map((st) {
                      return DropdownMenuItem(
                        value: st,
                        child: Text(st.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Start Date & Time
                  const Text('Start Date & Time',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickStartDate,
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 18),
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

                  // End Date & Time
                  const Text('End Date & Time',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickEndDate,
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 18),
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
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => Validators.required(val, 'Description'),
                  ),
                  const SizedBox(height: 16),

                  if (isAdmin)
                    SwitchListTile(
                      title: const Text('Highlight as Featured Event'),
                      subtitle:
                          const Text('Shows prominently on campus home feed'),
                      value: _isFeatured,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isFeatured = val),
                    ),
                  const SizedBox(height: 24),

                  CustomButton(
                    label: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete Event'),
                    onPressed: _isLoading ? null : _deleteEvent,
                  ),
                  SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: AppLoadingWidget()),
      error: (e, _) => Scaffold(
        body: AppErrorWidget(
          message: 'Failed to load event for editing',
          details: e.toString(),
          onRetry: () => ref.invalidate(eventDetailProvider(widget.eventId)),
        ),
      ),
    );
  }
}
