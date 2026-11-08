import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/events/domain/models/event_model.dart';
import 'package:haramaya_campus_connect/features/events/presentation/providers/event_provider.dart';

class RegistrationButton extends ConsumerStatefulWidget {
  final EventModel event;

  const RegistrationButton({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<RegistrationButton> createState() => _RegistrationButtonState();
}

class _RegistrationButtonState extends ConsumerState<RegistrationButton> {
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final user = ref.read(currentUserModelProvider);
    if (user == null) {
      SnackBarUtils.showWarning(context, 'Please sign in to register');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(eventRepositoryProvider).registerForEvent(
            eventId: widget.event.id,
            userId: user.uid,
            userName: user.fullName,
          );
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Successfully registered for event!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancel() async {
    final user = ref.read(currentUserModelProvider);
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: const Text(
          'Are you sure you want to cancel your registration for this event?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Registration'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(eventRepositoryProvider).cancelRegistration(
            eventId: widget.event.id,
            userId: user.uid,
          );
      if (mounted) {
        SnackBarUtils.showInfo(context, 'Registration cancelled');
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
    final isRegisteredAsync =
        ref.watch(isUserRegisteredForEventProvider(widget.event.id));
    final isRegistered = isRegisteredAsync.value ?? false;

    if (isRegistered) {
      return CustomButton(
        label: 'Registered ✓ (Cancel)',
        isOutlined: true,
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.error,
        isLoading: _isLoading,
        onPressed: _handleCancel,
      );
    }

    if (widget.event.isFull) {
      return const CustomButton(
        label: 'Event Full',
        backgroundColor: AppColors.disabled,
        foregroundColor: Colors.white,
        onPressed: null,
      );
    }

    return CustomButton(
      label: 'Register Now',
      icon: Icons.how_to_reg_rounded,
      isLoading: _isLoading,
      onPressed: _handleRegister,
    );
  }
}

