import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';
import 'package:dawsha_app/data/repositories/event_repository.dart';
import 'package:dawsha_app/features/home/presentation/widgets/weekly_chart.dart';
import 'package:dawsha_app/features/community/presentation/widgets/event_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsync = ref.watch(currentUserProfileProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, profileAsync, isDark),
              const SizedBox(height: 30),
              
              // Summary Stats
              _buildSummaryStats(context, profileAsync, isDark),
              const SizedBox(height: 30),

              // Weekly Progress Chart
              const WeeklyChart(),
              const SizedBox(height: 30),
              
              // Upcoming Event Card
              _buildSectionTitle(context, 'الفعالية القادمة', isDark, () {
                // Navigate to community -> events tab
              }),
              const SizedBox(height: 12),
              ref.watch(eventsProvider).when(
                data: (events) => events.isNotEmpty 
                    ? EventCard(event: events.first)
                    : Center(child: Text('لا توجد فعاليات قادمة حالياً', style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary))),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                error: (err, _) => Text('خطأ: $err', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 30),

              // Top Runner
              _buildSectionTitle(context, 'العداء المتميز 🏆', isDark, null),
              const SizedBox(height: 12),
              leaderboardAsync.when(
                data: (leaders) => leaders.isNotEmpty
                    ? _buildTopRunnerCard(leaders.first.name, '${leaders.first.totalKm.toStringAsFixed(1)} كم هذا الأسبوع', leaders.first.avatarUrl, isDark)
                    : Center(child: Text('لا توجد بيانات حالياً', style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary))),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                error: (err, _) => Text('خطأ: $err', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 30),
              
              // Quick Actions
              _buildSectionTitle(context, 'روابط سريعة', isDark, null),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  InkWell(
                    onTap: () => context.push('/tracking'),
                    child: _buildQuickAction(context, 'ابدأ الجري', Icons.play_arrow_rounded, AppColors.primaryGreen, isDark),
                  ),
                  InkWell(
                    onTap: () => context.push('/tracking'),
                    child: _buildQuickAction(context, 'ابدأ الجري', Icons.play_arrow_rounded, AppColors.primaryGreen, isDark),
                  ),
                  InkWell(
                    onTap: () => context.go('/community'), 
                    child: _buildQuickAction(context, 'انضم لفعالية', Icons.event_rounded, Colors.blue, isDark),
                  ),
                  InkWell(
                    onTap: () => context.go('/community'),
                    child: _buildQuickAction(context, 'المجتمع', Icons.people_alt_rounded, Colors.purple, isDark),
                  ),
                  InkWell(
                    onTap: () => context.go('/store'),
                    child: _buildQuickAction(context, 'المتجر', Icons.shopping_bag_rounded, Colors.orange, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue profileAsync, bool isDark) {
    final name = profileAsync.value?.name ?? 'يا بطل';
    final avatarUrl = profileAsync.value?.avatarUrl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أهلاً بك،',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: isDark ? Colors.white10 : AppColors.primarySilver,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null 
              ? Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.white) 
              : null,
        ),
      ],
    );
  }

  Widget _buildTopRunnerCard(String name, String status, String? avatarUrl, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.3), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isDark ? Colors.white10 : AppColors.primarySilver,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(Icons.trending_up_rounded, color: AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, AsyncValue profileAsync, bool isDark) {
    final rank = profileAsync.value?.rank ?? 'مبتدئ';
    final coins = profileAsync.value?.coins.toString() ?? '150';
    final streak = profileAsync.value?.streakDays.toString() ?? '3';

    return Row(
      children: [
        _buildStatCard(context, 'الرتبة', rank, Icons.emoji_events_rounded, Colors.orange, isDark),
        const SizedBox(width: 12),
        _buildStatCard(context, 'العملات', coins, Icons.monetization_on_rounded, Colors.amber, isDark),
        const SizedBox(width: 12),
        _buildStatCard(context, 'الستريك', '$streak أيام', Icons.local_fire_department_rounded, Colors.red, isDark),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color iconColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppColors.textSecondary, 
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll, 
            child: const Text('رؤية الكل', style: TextStyle(color: AppColors.primaryGreen)),
          ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
