import 'package:flutter/material.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String distance;
  final String duration;
  final String pace;
  final int likes;
  final int comments;

  const PostCard({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userAvatar),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(timeAgo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Text('أنهيت جولة جري رائعة في زايد! الجو كان ممتازاً 🏃‍♂️💨', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),

          // Run Stats Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('المسافة', distance),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                _buildStat('الوقت', duration),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                _buildStat('السرعة', pace),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          
          // Action Buttons
          Row(
            children: [
              _buildActionButton(Icons.favorite_border, '$likes إعجاب', () {}),
              const SizedBox(width: 24),
              _buildActionButton(Icons.chat_bubble_outline, '$comments تعليق', () {}),
              const Spacer(),
              _buildActionButton(Icons.share_outlined, 'مشاركة', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
