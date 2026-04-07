import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/profile_model.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  String? _fitnessLevel;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _cityController = TextEditingController(text: widget.profile.city);
    _fitnessLevel = widget.profile.fitnessLevel;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تعديل البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.surface,
                    backgroundImage: _imageFile != null 
                      ? FileImage(_imageFile!) as ImageProvider
                      : (widget.profile.avatarUrl != null ? NetworkImage(widget.profile.avatarUrl!) : null),
                    child: (widget.profile.avatarUrl == null && _imageFile == null) 
                      ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // ... (rest of the fields)
            const Text('الاسم بالكامل', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // City Field
            const Text('المدينة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'الشيخ زايد، 6 أكتوبر...',
              ),
            ),
            const SizedBox(height: 24),

            // Fitness Level Dropdown
            const Text('مستوى اللياقة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _fitnessLevel,
                  isExpanded: true,
                  hint: const Text('اختر مستواك'),
                  items: ['مبتدئ', 'متوسط', 'متقدم', 'محترف'].map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (val) => setState(() => _fitnessLevel = val),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isUploading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ التغييرات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isUploading = true);

    try {
      String? finalAvatarUrl = widget.profile.avatarUrl;

      // 1. Upload new avatar if selected
      if (_imageFile != null) {
        finalAvatarUrl = await ref.read(profileRepositoryProvider).uploadAvatar(
          widget.profile.id, 
          _imageFile!
        );
      }

      // 2. Update profile details
      final updatedProfile = ProfileModel(
        id: widget.profile.id,
        name: _nameController.text.trim(),
        email: widget.profile.email,
        city: _cityController.text.trim(),
        fitnessLevel: _fitnessLevel,
        avatarUrl: finalAvatarUrl,
        coins: widget.profile.coins,
        xp: widget.profile.xp,
        totalKm: widget.profile.totalKm,
        streakDays: widget.profile.streakDays,
        rank: widget.profile.rank,
      );

      await ref.read(profileRepositoryProvider).updateProfile(updatedProfile);
      ref.invalidate(currentUserProfileProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بياناتك بنجاح!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الحفظ.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}
