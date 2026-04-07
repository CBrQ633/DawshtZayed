import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/data/models/post_model.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class PostRepository {
  final SupabaseClient _supabase;

  PostRepository(this._supabase);

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select('*, profiles(name, avatar_url)')
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => PostModel.fromJson(e)).toList();
    } catch (e) {
      // Return empty list on error for now
      return [];
    }
  }

  Future<void> createPost(PostModel post) async {
    await _supabase.from('posts').insert(post.toJson());
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return PostRepository(supabase);
});

final postsProvider = FutureProvider<List<PostModel>>((ref) async {
  return ref.watch(postRepositoryProvider).getPosts();
});
