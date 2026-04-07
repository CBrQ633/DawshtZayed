import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/features/community/presentation/widgets/post_card.dart';
import 'package:dawsha_app/features/community/presentation/widgets/event_card.dart';
import 'package:dawsha_app/data/repositories/event_repository.dart';
import 'package:dawsha_app/data/repositories/post_repository.dart';
import 'package:dawsha_app/data/repositories/challenge_repository.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';
import 'package:dawsha_app/features/community/presentation/widgets/challenge_card.dart';
import 'package:dawsha_app/features/profile/presentation/pages/leaderboard_screen.dart';
import 'package:dawsha_app/data/models/challenge_model.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('المجتمع', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'المنشورات'),
              Tab(text: 'الفعاليات'),
              Tab(text: 'التحديات'),
              Tab(text: 'لوحة الشرف'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedTab(postsAsync, ref),
            _buildEventsTab(eventsAsync),
            _buildChallengesTab(ref),
            const LeaderboardScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab(AsyncValue postsAsync, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value?.session?.user;

    return postsAsync.when(
      data: (posts) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            timeAgo: _formatTimeAgo(post.createdAt),
            onLike: () async {
              if (user == null) return;
              
              final success = await ref.read(postRepositoryProvider).toggleLike(
                post.id, 
                user.id, 
                post.isLikedByMe
              );
              
              if (success) {
                ref.invalidate(postsProvider);
              }
            },
            onComment: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: إضافة التعليقات!')),
              );
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      error: (err, stack) => Center(child: Text('خطأ في جلب المنشورات: $err')),
    );
  }

  Widget _buildEventsTab(AsyncValue eventsAsync) {
    return eventsAsync.when(
      data: (events) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      error: (err, stack) => Center(child: Text('خطأ في جلب الفعاليات: $err')),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return 'منذ ${difference.inDays} يوم';
    if (difference.inHours > 0) return 'منذ ${difference.inHours} ساعة';
    if (difference.inMinutes > 0) return 'منذ ${difference.inMinutes} دقيقة';
    return 'الآن';
  }

  Widget _buildChallengesTab(WidgetRef ref) {
    final challengesAsync = ref.watch(activeChallengesProvider);
    final userChallengesAsync = ref.watch(userChallengesProvider);

    return challengesAsync.when(
      data: (challenges) {
        final userParticipations = userChallengesAsync.value ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            final participation = userParticipations.firstWhere(
              (p) => p.challengeId == challenge.id,
              orElse: () => ChallengeParticipantModel(id: '', challengeId: '', userId: ''),
            );

            return ChallengeCard(
              challenge: challenge,
              participation: participation.id.isNotEmpty ? participation : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      error: (err, stack) => Center(child: Text('خطأ في جلب التحديات: $err')),
    );
  }
}
