import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete (reduced time)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      print('🚀 Splash: Starting navigation check...');
      
      // Check if user has seen onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (hasSeenOnboarding) {
        // User has seen onboarding, go to login
        print('🔄 Splash: User has seen onboarding, navigating to login...');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.loginScreen);
          print('✅ Splash: Navigation to login completed');
        }
      } else {
        // First time user, show onboarding
        print('🔄 Splash: First time user, navigating to onboarding...');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingScreen);
          print('✅ Splash: Navigation to onboarding completed');
        }
      }
      
    } catch (e) {
      print('❌ Splash Navigation error: $e');
      // Force navigation to onboarding on error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingScreen);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Fixed color instead of theme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                Container(
                      width: 80.h,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(20.h),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20.h,
                            offset: Offset(0, 10.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sports,
                          size: 40.h,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                ),
                
                SizedBox(height: 15.h),
                
                // App Name
                Text(
                      'SABO ARENA',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                ),
                
                SizedBox(height: 5.h),
                
                // Tagline
                Text(
                      'Billiards Tournament Platform',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                ),
                
                SizedBox(height: 25.h),
                
                // Loading Indicator
                SizedBox(
                      width: 25.h,
                      height: 25.h,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                        strokeWidth: 3.0,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}