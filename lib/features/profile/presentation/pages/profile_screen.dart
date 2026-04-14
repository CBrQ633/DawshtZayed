import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';
import 'package:dawsha_app/features/profile/presentation/widgets/profile_stat_tile.dart';
import 'package:dawsha_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:dawsha_app/features/profile/presentation/pages/leaderboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (err, stack) => Center(child: Text('خطأ في تحميل البيانات: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('لم يتم العثور على بيانات الحساب.'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(currentUserProfileProvider),
            color: AppColors.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Profile Header
                  Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark ? Colors.white10 : AppColors.primarySilver,
                            backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                                ? Icon(Icons.person, size: 50, color: isDark ? Colors.white70 : Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile.email,
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profile.rank,
                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      ProfileStatTile(
                        label: 'كم',
                        value: profile.totalKm.toStringAsFixed(1),
                        icon: Icons.directions_run_rounded,
                        color: Colors.blue,
                      ),
                      ProfileStatTile(
                        label: 'عملة',
                        value: profile.coins.toString(),
                        icon: Icons.monetization_on_rounded,
                        color: Colors.amber,
                      ),
                      ProfileStatTile(
                        label: 'يوم صمود',
                        value: profile.streakDays.toString(),
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Actions List
                  _buildActionItem(
                    context,
                    'تعديل الملف الشخصي',
                    Icons.person_outline_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)),
                    ),
                  ),
                  _buildActionItem(
                    context,
                    'متصدرين دوشة',
                    Icons.leaderboard_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                    ),
                  ),
                  _buildActionItem(
                    context,
                    'تاريخ الأنشطة',
                    Icons.history_rounded,
                    onTap: () {},
                  ),
                  _buildActionItem(
                    context,
                    'الإنجازات',
                    Icons.emoji_events_outlined,
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 24),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تسجيل الخروج'),
                            content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true), 
                                child: const Text('خروج', style: TextStyle(color: Colors.red))
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontSize: 16)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGreen),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
