import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/post_model.dart';
import 'package:dawsha_app/data/repositories/post_repository.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  final List<File> _imageFiles = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        // Limit to 40 images
        final totalNew = pickedFiles.length;
        final currentCount = _imageFiles.length;
        if (currentCount + totalNew > 40) {
          final allowed = 40 - currentCount;
          _imageFiles.addAll(pickedFiles.take(allowed).map((f) => File(f.path)));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الوصول للحد الأقصى (40 صورة)')),
          );
        } else {
          _imageFiles.addAll(pickedFiles.map((f) => File(f.path)));
        }
      });
    }
  }

  Future<void> _submitPost() async {
    final user = ref.read(authStateProvider).value?.session?.user;
    if (user == null) return;
    
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة محتوى أو اختيار صور')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        imageUrls = await ref.read(postRepositoryProvider).uploadPostImages(user.id, _imageFiles);
      }

      final post = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        caption: caption,
        mediaUrls: imageUrls,
        pace: '',
        distanceKm: 0.0,
        createdAt: DateTime.now(),
      );

      await ref.read(postRepositoryProvider).createPost(post);
      ref.invalidate(postsProvider);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نشر البوست بنجاح!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء النشر')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('نشر بوست', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submitPost,
            child: _isUploading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('نشر', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _captionController,
              maxLines: 5,
              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'بتفكر في إيه يا بطل؟',
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            if (_imageFiles.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFiles[index], width: 120, height: 150, fit: BoxFit.cover),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _imageFiles.removeAt(index)),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text('إرفاق صور (${_imageFiles.length}/40)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[800] : AppColors.surface,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
