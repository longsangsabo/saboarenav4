import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);

    _animationController.forward();

    _navigateToHome();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    
    // Check if user is already logged in
    final isAuthenticated = AuthService.instance.isAuthenticated;
    
    if (isAuthenticated) {
      // User is logged in, check if admin and redirect accordingly
      final isAdmin = await AuthService.instance.isCurrentUserAdmin();
      if (mounted) {
        if (isAdmin) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboardScreen);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.userProfileScreen);
        }
      }
    } else {
      // User not logged in, check onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (mounted) {
        if (hasSeenOnboarding) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.onboardingScreen);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/img_app_logo.svg',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 20),
                Text(
                  "Sabo Arena",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Connecting Players",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withAlpha(204),
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