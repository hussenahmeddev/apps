import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/utils/validators.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/notifications/domain/models/notification_model.dart';
import 'package:haramaya_campus_connect/features/notifications/presentation/providers/notification_provider.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _priority = 'normal';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserModelProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final announcement = AnnouncementModel(
        id: '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: user.uid,
        authorName: user.fullName,
        priority: _priority,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await ref
          .read(notificationRepositoryProvider)
          .createAnnouncement(announcement);

      if (mounted) {
        SnackBarUtils.showSuccess(
          context,
          'University announcement published successfully!',
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Campus Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notice Headline',
                  hintText: 'e.g. Campus Wi-Fi Scheduled Maintenance',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => Validators.required(val, 'Headline'),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority Level',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(
                    value: 'urgent',
                    child: Text('Urgent (Campus Wide Alert)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _priority = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Announcement Details',
                  hintText: 'Provide full information for students and staff...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => Validators.required(val, 'Content'),
              ),
              const SizedBox(height: 28),

              CustomButton(
                label: 'Publish Announcement',
                isLoading: _isLoading,
                onPressed: _publish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

