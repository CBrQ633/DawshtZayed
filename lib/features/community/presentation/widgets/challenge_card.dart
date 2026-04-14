import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/challenge_model.dart';
import 'package:dawsha_app/data/repositories/challenge_repository.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class ChallengeCard extends ConsumerWidget {
  final ChallengeModel challenge;
  final ChallengeParticipantModel? participation;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.participation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isJoined = participation != null;
    final double progress = participation?.progress ?? 0.0;
    final double percent = (progress / challenge.goalValue).clamp(0.0, 1.0);
    final bool isCompleted = participation?.isCompleted ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image
          Stack(
            children: [
              Image.network(
                challenge.imageUrl ?? 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&q=80&w=400',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  child: Center(child: Icon(Icons.image_not_supported, color: isDark ? Colors.grey[800] : Colors.grey)),
                ),
              ),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${challenge.rewardCoins} عملة • ${challenge.rewardXp} XP',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 13, 
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                if (isJoined) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCompleted ? 'تم الإكمال! 🎉' : 'التقدم: ${progress.toStringAsFixed(1)} / ${challenge.goalValue} كم',
                        style: TextStyle(
                          color: isCompleted ? AppColors.primaryGreen : (isDark ? Colors.white : AppColors.textPrimary),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(percent * 100).toInt()}%', 
                        style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                      color: isCompleted ? AppColors.primaryGreen : Colors.blue,
                      minHeight: 8,
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = ref.read(authRepositoryProvider).currentUser;
                        if (user != null) {
                          await ref.read(challengeRepositoryProvider).joinChallenge(challenge.id, user.id);
                          ref.invalidate(userChallengesProvider);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('انضم الآن', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
