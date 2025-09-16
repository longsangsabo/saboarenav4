import 'package:flutter/material.dart';

import '../presentation/home_feed_screen/home_feed_screen.dart';
import '../presentation/tournament_list_screen/tournament_list_screen.dart';
import '../presentation/find_opponents_screen/find_opponents_screen.dart';
import '../presentation/club_profile_screen/club_profile_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/tournament_detail_screen/tournament_detail_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';

class AppRoutes {
  static const String homeFeedScreen = '/home_feed_screen';
  static const String tournamentListScreen = '/tournament_list_screen';
  static const String findOpponentsScreen = '/find_opponents_screen';
  static const String clubProfileScreen = '/club_profile_screen';
  static const String userProfileScreen = '/user_profile_screen';
  static const String tournamentDetailScreen = '/tournament_detail_screen';
  static const String loginScreen = '/login';
  static const String signupScreen = '/signup';

  static const String initial = homeFeedScreen;

  static Map<String, WidgetBuilder> get routes => {
        homeFeedScreen: (context) => const HomeFeedScreen(),
        tournamentListScreen: (context) => const TournamentListScreen(),
        findOpponentsScreen: (context) => const FindOpponentsScreen(),
        clubProfileScreen: (context) => const ClubProfileScreen(),
        userProfileScreen: (context) => const UserProfileScreen(),
        tournamentDetailScreen: (context) => const TournamentDetailScreen(),
        loginScreen: (context) => const LoginScreen(),
        signupScreen: (context) => const SignupScreen(),
      };
}
