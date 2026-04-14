import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/post_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class PostRepository {
  final SupabaseClient _supabase;

  PostRepository(this._supabase);

  Future<List<PostModel>> getPosts(String? currentUserId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('*, profiles(name, avatar_url), post_likes(user_id)')
          .order('created_at', ascending: false);
      
      return (response as List).map((e) {
        final likes = (e['post_likes'] as List?) ?? [];
        final isLiked = currentUserId != null && likes.any((l) => l['user_id'] == currentUserId);
        
        return PostModel.fromJson({
          ...e,
          'is_liked_by_me': isLiked,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> createPost(PostModel post) async {
    await _supabase.from('posts').insert(post.toJson());
  }

  Future<List<String>> uploadPostImages(String userId, List<File> imageFiles) async {
    List<String> uploadedUrls = [];
    try {
      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = '$userId/post_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        await _supabase.storage.from('post_images').upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
        
        final String publicUrl = _supabase.storage.from('post_images').getPublicUrl(fileName);
        uploadedUrls.add(publicUrl);
      }
      return uploadedUrls;
    } catch (e) {
      return uploadedUrls; // Return what we managed to upload so far, or empty list
    }
  }

  Future<bool> toggleLike(String postId, String userId, bool currentlyLiked) async {
    try {
      if (currentlyLiked) {
        // Unlike
        await _supabase
            .from('post_likes')
            .delete()
            .match({'post_id': postId, 'user_id': userId});
      } else {
        // Like
        await _supabase
            .from('post_likes')
            .insert({'post_id': postId, 'user_id': userId});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addComment(String postId, String userId, String content) async {
    await _supabase.from('post_comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
    });
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return PostRepository(supabase);
});

final postsProvider = FutureProvider<List<PostModel>>((ref) async {
  final user = ref.watch(authStateProvider).value?.session?.user;
  return ref.watch(postRepositoryProvider).getPosts(user?.id);
});
