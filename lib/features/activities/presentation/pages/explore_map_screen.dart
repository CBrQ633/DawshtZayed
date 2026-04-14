import 'package:flutter/material.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';

class ExploreMapScreen extends StatelessWidget {
  const ExploreMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الخريطة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_rounded, size: 80, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'استكشاف مسارات الجري والفعاليات \nسيتوفر هنا قريباً!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
