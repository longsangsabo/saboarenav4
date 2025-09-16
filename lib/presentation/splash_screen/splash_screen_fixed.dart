import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    print('🚀 Splash: Navigating to login...');
    
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    
    print('✅ Splash: Navigation completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 20.h,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.h),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5.h,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sports_tennis,
                  size: 10.h,
                  color: Colors.blue,
                ),
              ),
              
              SizedBox(height: 4.h),
              
              // App Title
              Text(
                'SABO ARENA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(2.h, 2.h),
                      blurRadius: 8.h,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 5.h),
              
              // Tagline
              Text(
                'Billiards Tournament Platform',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16.sp,
                  letterSpacing: 1.2,
                ),
              ),
              
              SizedBox(height: 25.h),
              
              // Loading Indicator
              SizedBox(
                width: 25.h,
                height: 25.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}