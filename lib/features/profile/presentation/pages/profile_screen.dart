import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';
import 'package:dawsha_app/features/profile/presentation/widgets/profile_stat_tile.dart';
import 'package:dawsha_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:dawsha_app/features/profile/presentation/pages/leaderboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    // Mock data for display purposes
    final name = profileAsync.value?.name ?? 'يا بطل';
    final email = profileAsync.value?.email ?? 'runner@dawsha.com';
    final avatarUrl = profileAsync.value?.avatarUrl;
    final totalKm = profileAsync.value?.totalKm.toStringAsFixed(1) ?? '42.5';
    final runs = profileAsync.value?.streakDays.toString() ?? '12';
    final pace = profileAsync.value?.preferredPace ?? '5:30 /km';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حسابي', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Header: Avatar & Name
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGreen, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primarySilver,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null 
                          ? const Icon(Icons.person, color: Colors.white, size: 50) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (profileAsync.value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(profile: profileAsync.value!),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('تعديل البيانات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats Section
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'إحصائيات الجري',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ProfileStatTile(
              label: 'إجمالي المسافة',
              value: totalKm,
              unit: 'كم',
              icon: Icons.map_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            ProfileStatTile(
              label: 'معدل السرعة (Pace)',
              value: pace,
              icon: Icons.speed_rounded,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            ProfileStatTile(
              label: 'إجمالي الجولات',
              value: runs,
              unit: 'جولة',
              icon: Icons.directions_run_rounded,
              color: AppColors.primaryGreen,
            ),
            
            const SizedBox(height: 32),

            // Achievements Section
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الإنجازات المكتسبة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAchievementBadge('البداية', Icons.directions_run_rounded, AppColors.primaryGreen, isAchieved: (profileAsync.value?.totalKm ?? 0) > 0),
                  const SizedBox(width: 12),
                  _buildAchievementBadge('بطل الـ 10كم', Icons.star_rounded, Colors.amber, isAchieved: (profileAsync.value?.totalKm ?? 0) >= 10),
                  const SizedBox(width: 12),
                  _buildAchievementBadge('وحش الـ 50كم', Icons.local_fire_department_rounded, Colors.orange, isAchieved: (profileAsync.value?.totalKm ?? 0) >= 50),
                  const SizedBox(width: 12),
                  _buildAchievementBadge('سندباد الزايد', Icons.map_rounded, Colors.blue, isAchieved: (profileAsync.value?.totalKm ?? 0) >= 100),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontSize: 16)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String label, IconData icon, Color color, {bool isAchieved = true}) {
    return Opacity(
      opacity: isAchieved ? 1.0 : 0.3,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAchieved ? color.withValues(alpha: 0.3) : Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isAchieved ? color : Colors.grey, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAchieved ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
