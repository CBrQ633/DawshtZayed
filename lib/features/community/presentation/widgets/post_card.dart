import 'package:flutter/material.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/post_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostCard extends StatefulWidget {
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
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.post.userAvatar ?? 'https://sqafkemeyofuaewgbgzs.supabase.co/storage/v1/object/public/avatars/default_avatar.png'),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName ?? 'عداء دوشة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.timeAgo,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          if (widget.post.caption != null) 
            Text(
              widget.post.caption!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
          
          if (widget.post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.post.mediaUrls.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.post.mediaUrls[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.post.mediaUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.post.mediaUrls.length,
                        effect: const ScrollingDotsEffect(
                          dotWidth: 6,
                          dotHeight: 6,
                          activeDotColor: AppColors.primaryGreen,
                          dotColor: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                if (widget.post.mediaUrls.length > 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.post.mediaUrls.length} صور',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          if (widget.post.distanceKm > 0.0) ...[
            const SizedBox(height: 16),
            // Run Stats Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('المسافة', '${widget.post.distanceKm} كم', isDark),
                  Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.2)),
                  _buildStat('الوقت', '${widget.post.durationMinutes} دقيقة', isDark),
                  Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.2)),
                  _buildStat('السرعة', widget.post.pace, isDark),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          
          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                widget.post.isLikedByMe ? Icons.favorite : Icons.favorite_border, 
                '${widget.post.likesCount} إعجاب', 
                widget.post.isLikedByMe ? Colors.red : (isDark ? Colors.grey[400]! : AppColors.textSecondary),
                widget.onLike ?? () {}
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                Icons.chat_bubble_outline, 
                '${widget.post.commentsCount} تعليق', 
                isDark ? Colors.grey[400]! : AppColors.textSecondary,
                widget.onComment ?? () {}
              ),
              const Spacer(),
              _buildActionButton(Icons.share_outlined, 'مشاركة', isDark ? Colors.grey[400]! : AppColors.textSecondary, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
        Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary, fontSize: 12)),
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
