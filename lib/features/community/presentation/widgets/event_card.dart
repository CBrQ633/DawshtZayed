import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/event_model.dart';
import 'package:dawsha_app/data/repositories/event_repository.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';
import 'package:intl/intl.dart';

class EventCard extends ConsumerWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value?.session?.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Stack(
            children: [
              Image.network(
                event.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  child: Center(child: Icon(Icons.image_not_supported, color: isDark ? Colors.grey[800] : Colors.grey)),
                ),
              ),
              if (event.isFeatured)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('مميز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
            ],
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18, 
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGreen),
                      ),
                      child: Text(event.distance, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEE, d MMM • h:mm a').format(event.date),
                      style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${event.participantsCount} مشارك', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى تسجيل الدخول للانضمام')),
                          );
                          return;
                        }
                        
                        final success = await ref.read(eventRepositoryProvider).toggleJoinEvent(
                          event.id, 
                          user.id, 
                          event.isJoinedByMe
                        );
                        
                        if (success) {
                          ref.invalidate(eventsProvider);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.isJoinedByMe 
                            ? (isDark ? Colors.white12 : Colors.white) 
                            : AppColors.primaryGreen,
                        foregroundColor: event.isJoinedByMe 
                            ? AppColors.primaryGreen 
                            : Colors.white,
                        side: event.isJoinedByMe ? const BorderSide(color: AppColors.primaryGreen) : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        event.isJoinedByMe ? 'تم الانضمام' : 'انضم الآن', 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
