import 'package:flutter/material.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/features/community/presentation/widgets/post_card.dart';
import 'package:dawsha_app/features/community/presentation/widgets/event_card.dart';
import 'package:dawsha_app/data/models/event_model.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('المجتمع', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'المنشورات'),
              Tab(text: 'الفعاليات'),
              Tab(text: 'لوحة الشرف'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedTab(),
            _buildEventsTab(),
            _buildLeaderboardTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PostCard(
          userName: 'أحمد علي',
          userAvatar: 'https://i.pravatar.cc/150?u=ahmed',
          timeAgo: 'منذ ساعتين',
          distance: '5.2 كم',
          duration: '25:40',
          pace: '4:56',
          likes: 24,
          comments: 5,
        ),
        PostCard(
          userName: 'سارة محمد',
          userAvatar: 'https://i.pravatar.cc/150?u=sara',
          timeAgo: 'منذ 5 ساعات',
          distance: '10.0 كم',
          duration: '55:12',
          pace: '5:31',
          likes: 42,
          comments: 12,
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyEvents.length,
      itemBuilder: (context, index) {
        return EventCard(event: dummyEvents[index]);
      },
    );
  }

  Widget _buildLeaderboardTab() {
    final List<Map<String, dynamic>> leaders = [
      {'name': 'ياسين محمود', 'distance': '124.5 كم', 'rank': 1, 'avatar': 'https://i.pravatar.cc/150?u=1'},
      {'name': 'كريم حسن', 'distance': '112.2 كم', 'rank': 2, 'avatar': 'https://i.pravatar.cc/150?u=2'},
      {'name': 'عبد الرحمن', 'distance': '98.7 كم', 'rank': 3, 'avatar': 'https://i.pravatar.cc/150?u=3'},
      {'name': 'عمر خالد', 'distance': '85.0 كم', 'rank': 4, 'avatar': 'https://i.pravatar.cc/150?u=4'},
      {'name': 'يوسف علي', 'distance': '72.3 كم', 'rank': 5, 'avatar': 'https://i.pravatar.cc/150?u=5'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final leader = leaders[index];
        final bool isTopThree = leader['rank'] <= 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: isTopThree ? Border.all(color: AppColors.primaryGreen.withOpacity(0.5)) : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${leader['rank']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isTopThree ? AppColors.primaryGreen : Colors.grey,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(leader['avatar']),
                radius: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leader['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('الشيخ زايد', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                leader['distance'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ],
          ),
        );
      },
    );
  }
}
