import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/utils/validators.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  String? _selectedDepartment;
  int? _selectedYear;
  bool _isLoading = false;

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
  void initState() {
    super.initState();
    final user = ref.read(currentUserModelProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _studentIdController = TextEditingController(text: user?.studentId ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _selectedDepartment = user?.department;
    _selectedYear = user?.year;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserModelProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).updateUserProfile(
        uid: user.uid,
        data: {
          'fullName': _nameController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bio': _bioController.text.trim(),
          'department': _selectedDepartment,
          'year': _selectedYear,
        },
      );

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Profile updated successfully!');
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
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: Validators.studentId,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: departments.contains(_selectedDepartment)
                    ? _selectedDepartment
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDepartment = val),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year of Study',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                items: [1, 2, 3, 4, 5, 6, 7].map((yr) {
                  return DropdownMenuItem(
                    value: yr,
                    child: Text('Year $yr'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedYear = val),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Short Bio',
                  hintText: 'Share a little bit about your interests...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              CustomButton(
                label: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

