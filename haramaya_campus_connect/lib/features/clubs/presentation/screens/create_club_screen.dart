import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';
import 'package:haramaya_campus_connect/core/utils/snackbar_utils.dart';
import 'package:haramaya_campus_connect/core/utils/validators.dart';
import 'package:haramaya_campus_connect/core/widgets/custom_button.dart';
import 'package:haramaya_campus_connect/features/admin/presentation/providers/admin_provider.dart';
import 'package:haramaya_campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:haramaya_campus_connect/features/clubs/domain/models/club_model.dart';
import 'package:haramaya_campus_connect/features/clubs/presentation/providers/club_provider.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _emailController = TextEditingController();
  final _imageUrlController = TextEditingController();

  static const List<String> _categories = [
    'Academic',
    'Technology',
    'Sports',
    'Arts & Culture',
    'Social & Charity',
    'Environmental',
    'Innovation',
    'General',
  ];

  String _selectedCategory = 'Technology';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserModelProvider);
    if (user != null && user.email.isNotEmpty) {
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    _emailController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserModelProvider);
    if (user == null) {
      SnackBarUtils.showError(
          context, 'You must be logged in to create a club');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final newClub = ClubModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        organizerId: user.uid,
        organizerName: user.fullName,
        meetingSchedule: _scheduleController.text.trim().isEmpty
            ? null
            : _scheduleController.text.trim(),
        contactEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        memberCount: 1,
        memberIds: [user.uid],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(clubRepositoryProvider).createClub(newClub);
      ref.invalidate(clubsStreamProvider);
      ref.invalidate(popularClubsProvider);
      ref.invalidate(adminStatsProvider);

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Club registered successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to create club: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Campus Club'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon and Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Society Registry',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Found an active student organization or chapter',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Club Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Club Name *',
                  hintText: 'e.g. Haramaya Tech Innovators',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) =>
                    Validators.required(val, 'Club Name is required'),
              ),
              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Club Mission & Description *',
                  hintText:
                      'Explain what the club does, member benefits, activities...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (val) =>
                    Validators.required(val, 'Description is required'),
              ),
              const SizedBox(height: 16),

              // Meeting Schedule
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Schedule (Optional)',
                  hintText: 'e.g. Every Wednesday 4:00 PM, Block B Room 102',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'club@haramaya.edu.et',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    return Validators.email(val.trim());
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Logo / Image URL (Optional)',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                label: 'Register Club',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
