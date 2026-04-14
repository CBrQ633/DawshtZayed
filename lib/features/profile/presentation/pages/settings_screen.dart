import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('التطبيق'),
          _buildListTile(
            context,
            'عن تطبيق دوشة',
            Icons.info_outline_rounded,
            onTap: () => _showAboutAppDialog(context),
          ),
          _buildListTile(
            context,
            'عن المنظمة',
            Icons.business_rounded,
            onTap: () => _showAboutOrgDialog(context),
          ),
          _buildListTile(
            context,
            'المطور (برق للحلول التقنية)',
            Icons.code_rounded,
            onTap: () => _launchURL('https://www.instagram.com/brq_official/'),
          ),
          
          _buildSectionHeader('التواصل الاجتماعي'),
          _buildListTile(
            context,
            'صفحتنا على فيسبوك',
            Icons.facebook,
            iconColor: const Color(0xFF1877F2),
            onTap: () => _launchURL('https://www.facebook.com/dawshtzayed'),
          ),
          _buildListTile(
            context,
            'حسابنا على إنستجرام',
            Icons.camera_alt_rounded,
            iconColor: const Color(0xFFE4405F),
            onTap: () => _launchURL('https://www.instagram.com/dawshtzayedev'),
          ),

          _buildSectionHeader('الحساب'),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _handleLogout(context, ref),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'إصدار النسخة 1.0.0',
              style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, {VoidCallback? onTap, Color? iconColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? (isDark ? Colors.white70 : AppColors.textSecondary)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'),
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
  }

  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'دوشة Zayed',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.directions_run_rounded, color: AppColors.primaryGreen, size: 48),
      children: [
        const Text('تطبيق دوشة هو المنصة الأولى لمجتمع الجري والرياضة في الشيخ زايد والسادس من أكتوبر. يهدف التطبيق لتشجيع الجميع على الحركة وبناء مجتمع رياضي متفاعل.'),
      ],
    );
  }

  void _showAboutOrgDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن المنظمة'),
        content: const Text('دوشة هي مبادرة شبابية تهدف لنشر الثقافة الرياضية وتنظيم فعاليات جري جماعية في منطقة الشيخ زايد والسادس من أكتوبر.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
      ),
    );
  }
}
