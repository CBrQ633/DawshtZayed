import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور')),
      );
      return;
    }

    await ref.read(authViewModelProvider.notifier).signInWithEmail(
      email: email,
      password: password,
    );

    _handleAuthResult();
  }

  void _onGoogleLogin() async {
    await ref.read(authViewModelProvider.notifier).signInWithGoogle();
    _handleAuthResult();
  }

  void _handleAuthResult() {
    final authState = ref.read(authViewModelProvider);
    if (!authState.hasError) {
      if (mounted) context.go('/home');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تسجيل الدخول: ${authState.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.directions_run_rounded,
                      size: 80,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك مجدداً في مجتمع دوشة',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Email Field
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary),
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: AppColors.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Button
                ElevatedButton(
                  onPressed: authViewModel.isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: authViewModel.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تسجيل دخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 32),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو بضغطة واحدة عبر',
                        style: TextStyle(color: isDark ? Colors.grey[500] : AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.grey[300])),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Social Logins
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        label: 'Google',
                        iconPath: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                        onPressed: authViewModel.isLoading ? null : _onGoogleLogin,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Sign Up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('لا تملك حساباً؟', style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('أنشئ حسابك الآن', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required String iconPath, required VoidCallback? onPressed, required bool isDark}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(iconPath, height: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
