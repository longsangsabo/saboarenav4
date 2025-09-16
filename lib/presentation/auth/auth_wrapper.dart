import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final Stream<AuthState> _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = AuthService.instance.authStateChanges;
    
    // Listen to auth state changes
    _authStateStream.listen((AuthState data) {
      if (mounted) {
        final session = data.session;
        
        if (session != null) {
          // User is logged in, navigate to home
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homeFeedScreen,
            (route) => false,
          );
        } else {
          // User is not logged in, navigate to login
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.loginScreen,
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check current auth state
        final session = snapshot.data?.session;
        
        if (session != null) {
          // User is authenticated, show home
          return Navigator(
            initialRoute: AppRoutes.homeFeedScreen,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: AppRoutes.routes[AppRoutes.homeFeedScreen]!,
                settings: settings,
              );
            },
          );
        } else {
          // User not authenticated, show login
          return Navigator(
            initialRoute: AppRoutes.loginScreen,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: AppRoutes.routes[AppRoutes.loginScreen]!,
                settings: settings,
              );
            },
          );
        }
      },
    );
  }
}