import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/constants/app_constants.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/utils/validators.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    final authState = ref.read(authNotifierProvider);
    if (authState.status == AuthStatus.error && mounted) {
      SnackBarUtils.showError(
        context,
        authState.errorMessage ?? 'Failed to send reset email',
      );
    } else if (mounted) {
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding * 1.5,
            vertical: 24,
          ),
          child: _submitted ? _buildSuccessView() : _buildFormView(isLoading),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.successContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 50,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Check Your Email',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a password reset link to\n${_emailController.text.trim()}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            label: 'Back to Sign In',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email address registered with your account and we’ll send a link to reset your password.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'student@haramaya.edu.et',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleReset(),
          ),
          const SizedBox(height: 28),
          CustomButton(
            label: 'Send Reset Link',
            isLoading: isLoading,
            onPressed: _handleReset,
          ),
        ],
      ),
    );
  }
}

