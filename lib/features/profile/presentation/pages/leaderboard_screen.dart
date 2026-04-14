import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/profile_model.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('لوحة المتصدرين 🏆', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
      ),
      body: leaderboardAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text('لا يوجد متصدرون حالياً', style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary)));
          }

          final topThree = users.take(3).toList();
          final others = (users as List).length > 3 ? users.sublist(3) : <ProfileModel>[];

          return Column(
            children: [
              // Podiums for Top 3
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Second Place
                    if (topThree.length >= 2) _buildPodium(topThree[1], 2, 100, isDark),
                    // First Place
                    if (topThree.isNotEmpty) _buildPodium(topThree[0], 1, 140, isDark),
                    // Third Place
                    if (topThree.length >= 3) _buildPodium(topThree[2], 3, 90, isDark),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white10),

              // List of others
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: others.length,
                  itemBuilder: (context, index) {
                    final user = others[index];
                    return _buildUserTile(user, index + 4, isDark);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, stack) => Center(child: Text('حدث خطأ: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildPodium(ProfileModel user, int rank, double height, bool isDark) {
    Color medalColor = rank == 1 ? Colors.orange : (rank == 2 ? Colors.grey : Colors.brown);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: (height / 4) + 5,
              backgroundColor: medalColor,
              child: CircleAvatar(
                radius: height / 4,
                backgroundColor: isDark ? Colors.white10 : AppColors.primarySilver,
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null ? Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.white) : null,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: medalColor, borderRadius: BorderRadius.circular(10)),
                child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name.split(' ')[0], 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        Text('${user.totalKm.toStringAsFixed(1)} كم', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height / 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [medalColor.withValues(alpha: 0.3), Colors.transparent],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(ProfileModel user, int rank, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank', 
              style: TextStyle(
                color: isDark ? Colors.grey[500] : AppColors.textSecondary, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: isDark ? Colors.white10 : AppColors.primarySilver,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? Icon(Icons.person, color: isDark ? Colors.grey[600] : Colors.white, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.rank, 
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary, 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${user.totalKm.toStringAsFixed(1)} كم',
            style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
