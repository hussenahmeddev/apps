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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedDepartment;
  int? _selectedYear;

  static const List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Electrical & Computer Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Plant Sciences (Agriculture)',
    'Animal Sciences',
    'Agricultural Economics',
    'Business Administration & Management',
    'Accounting & Finance',
    'Economics',
    'School of Law',
    'Medicine',
    'Public Health',
    'Pharmacy',
    'Other'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          department: _selectedDepartment,
          year: _selectedYear,
        );

    final authState = ref.read(authNotifierProvider);
    if (authState.status == AuthStatus.error && mounted) {
      SnackBarUtils.showError(
        context,
        authState.errorMessage ?? 'Registration failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding * 1.5,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Haramaya Campus Connect',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in your student information to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                AuthTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Abebe Bikila',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _studentIdController,
                  label: 'Student ID',
                  hint: 'UGR/12345/14',
                  prefixIcon: Icons.badge_outlined,
                  validator: Validators.studentId,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'abebe@haramaya.edu.et',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // Department Dropdown
                Text(
                  'Department',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment,
                  isExpanded: true,
                  hint: const Text('Select your department'),
                  items: departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDepartment = val;
                    });
                  },
                  validator: (val) =>
                      val == null ? 'Please select a department' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Year of Study Dropdown
                Text(
                  'Year of Study',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  hint: const Text('Select year'),
                  items: [1, 2, 3, 4, 5, 6, 7].map((yr) {
                    return DropdownMenuItem(
                      value: yr,
                      child: Text('Year $yr'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedYear = val;
                    });
                  },
                  validator: (val) =>
                      val == null ? 'Please select your study year' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_clock_outlined,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (val) => Validators.confirmPassword(
                    val,
                    _passwordController.text,
                  ),
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 28),

                CustomButton(
                  label: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already registered? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

