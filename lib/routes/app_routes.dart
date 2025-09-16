import 'package:flutter/material.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/home_feed_screen/home_feed_screen.dart';
import '../presentation/tournament_list_screen/tournament_list_screen.dart';
import '../presentation/find_opponents_screen/find_opponents_screen.dart';
import '../presentation/club_main_screen/club_main_screen.dart';
import 'package:sabo_arena/presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/tournament_detail_screen/tournament_detail_screen.dart';
import '../presentation/login_screen.dart';
import '../presentation/register_screen.dart';
import '../presentation/forgot_password_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash';
  static const String onboardingScreen = '/onboarding';
  static const String homeFeedScreen = '/home_feed_screen';
  static const String tournamentListScreen = '/tournament_list_screen';
  static const String findOpponentsScreen = '/find_opponents_screen';
  static const String clubProfileScreen = '/club_profile_screen';
  static const String userProfileScreen = '/user_profile_screen';
  static const String tournamentDetailScreen = '/tournament_detail_screen';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String forgotPasswordScreen = '/forgot-password';

  static const String initial = splashScreen;

  static Map<String, WidgetBuilder> get routes => {
        splashScreen: (context) => const SplashScreen(),
        onboardingScreen: (context) => const OnboardingScreen(),
        homeFeedScreen: (context) => const HomeFeedScreen(),
        tournamentListScreen: (context) => const TournamentListScreen(),
        findOpponentsScreen: (context) => const FindOpponentsScreen(),
        clubProfileScreen: (context) => const ClubMainScreen(),
        userProfileScreen: (context) => const UserProfileScreen(),
        tournamentDetailScreen: (context) => const TournamentDetailScreen(),
        loginScreen: (context) => const LoginScreen(),
        registerScreen: (context) => const RegisterScreen(),
        forgotPasswordScreen: (context) => const ForgotPasswordScreen(),
      };
}
