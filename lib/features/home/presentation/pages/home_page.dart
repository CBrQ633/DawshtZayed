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
    // For now, if profile is null, we can provide a default visually, or just wait.
    // To make sure it looks good immediately, let's use a mock profile fallback in UI
    final profileAsync = ref.watch(currentUserProfileProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, profileAsync),
              const SizedBox(height: 30),
              
              // Summary Stats
              _buildSummaryStats(context, profileAsync),
              
              const SizedBox(height: 30),

              // Weekly Progress Chart
              const WeeklyChart(),

              const SizedBox(height: 30),
              
              // Upcoming Event Card
              _buildSectionTitle(context, 'الفعالية القادمة', () {
                // Navigate to community -> events tab
              }),
              const SizedBox(height: 12),
              ref.watch(eventsProvider).when(
                data: (events) => events.isNotEmpty 
                    ? EventCard(event: events.first)
                    : const Center(child: Text('لا توجد فعاليات قادمة حالياً')),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('خطأ: $err'),
              ),
              
              const SizedBox(height: 30),

              // Top Runner
              _buildSectionTitle(context, 'العداء المتميز 🏆', null),
              const SizedBox(height: 12),
              leaderboardAsync.when(
                data: (leaders) => leaders.isNotEmpty
                    ? _buildTopRunnerCard(leaders.first.name, '${leaders.first.totalKm.toStringAsFixed(1)} كم هذا الأسبوع', leaders.first.avatarUrl)
                    : const Center(child: Text('لا توجد بيانات حالياً')),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('خطأ: $err'),
              ),
              
              const SizedBox(height: 30),
              
              // Quick Actions
              _buildSectionTitle(context, 'روابط سريعة', null),
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
                    child: _buildQuickAction(context, 'ابدأ الجري', Icons.play_arrow_rounded, AppColors.primaryGreen),
                  ),
                  _buildQuickAction(context, 'انضم لفعالية', Icons.event_rounded, Colors.blue),
                  _buildQuickAction(context, 'المجتمع', Icons.people_alt_rounded, Colors.purple),
                  _buildQuickAction(context, 'المتجر', Icons.shopping_bag_rounded, Colors.orange),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue profileAsync) {
    // Use fallback data if loading or null
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
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primarySilver,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null 
              ? const Icon(Icons.person, color: Colors.white) 
              : null,
        ),
      ],
    );
  }

  Widget _buildTopRunnerCard(String name, String status, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  Widget _buildSummaryStats(BuildContext context, AsyncValue profileAsync) {
    final rank = profileAsync.value?.rank ?? 'مبتدئ';
    final coins = profileAsync.value?.coins.toString() ?? '150';
    final streak = profileAsync.value?.streakDays.toString() ?? '3';

    return Row(
      children: [
        _buildStatCard(context, 'الرتبة', rank, Icons.emoji_events_rounded, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(context, 'العملات', coins, Icons.monetization_on_rounded, Colors.amber),
        const SizedBox(width: 12),
        _buildStatCard(context, 'الستريك', '$streak أيام', Icons.local_fire_department_rounded, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll, 
            child: const Text('رؤية الكل')
          ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
