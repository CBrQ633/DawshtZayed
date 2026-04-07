import 'package:flutter/material.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final String timeAgo;

  const PostCard({
    super.key,
    required this.post,
    required this.timeAgo,
    this.onLike,
    this.onComment,
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
                backgroundImage: NetworkImage(post.userAvatar ?? 'https://i.pravatar.cc/150'),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName ?? 'عداء دوشة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          if (post.caption != null) 
            Text(post.caption!, style: const TextStyle(fontSize: 14)),
          
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
                _buildStat('المسافة', '${post.distanceKm} كم'),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                _buildStat('الوقت', '${post.durationMinutes} دقيقة'),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                _buildStat('السرعة', post.pace),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          
          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                post.isLikedByMe ? Icons.favorite : Icons.favorite_border, 
                '${post.likesCount} إعجاب', 
                post.isLikedByMe ? Colors.red : AppColors.textSecondary,
                onLike ?? () {}
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                Icons.chat_bubble_outline, 
                '${post.commentsCount} تعليق', 
                AppColors.textSecondary,
                onComment ?? () {}
              ),
              const Spacer(),
              _buildActionButton(Icons.share_outlined, 'مشاركة', AppColors.textSecondary, () {}),
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

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
