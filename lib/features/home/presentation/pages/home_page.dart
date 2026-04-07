import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/repositories/profile_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('لم يتم العثور على بيانات الملف الشخصي'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                            profile.name,
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
                        backgroundImage: profile.avatarUrl != null 
                            ? NetworkImage(profile.avatarUrl!) 
                            : null,
                        child: profile.avatarUrl == null 
                            ? const Icon(Icons.person, color: Colors.white) 
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Summary Stats
                  Row(
                    children: [
                      _buildStatCard(
                        context, 
                        'الرتبة', 
                        profile.rank, 
                        Icons.emoji_events_rounded, 
                        Colors.orange
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context, 
                        'العملات', 
                        profile.coins.toString(), 
                        Icons.monetization_on_rounded, 
                        Colors.amber
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context, 
                        'الستريك', 
                        '${profile.streakDays} أيام', 
                        Icons.local_fire_department_rounded, 
                        Colors.red
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Upcoming Event Card
                  _buildSectionTitle(context, 'الفعالية القادمة'),
                  const SizedBox(height: 12),
                  _buildEventCard(context),
                  
                  const SizedBox(height: 30),
                  
                  // Quick Actions
                  _buildSectionTitle(context, 'روابط سريعة'),
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
            );
          },
        ),
      ),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {}, 
          child: const Text('رؤية الكل')
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&q=80&w=1000'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Badge(
              label: Text('مميز'),
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 40),
            const Text(
              'ماراثون الجمعة 5KM',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                const Text('الجمعة القادم - 7:00 ص', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                const Text('مدينتي', style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('سجل الآن'),
            ),
          ],
        ),
      ),
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
