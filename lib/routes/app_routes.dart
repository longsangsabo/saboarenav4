import 'package:flutter/material.dart';
import '../presentation/tournament_detail_screen/tournament_detail_screen.dart';
import '../presentation/tournament_list_screen/tournament_list_screen.dart';
import '../presentation/find_opponents_screen/find_opponents_screen.dart';
import '../presentation/club_profile_screen/club_profile_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/home_feed_screen/home_feed_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String tournamentDetail = '/tournament-detail-screen';
  static const String tournamentList = '/tournament-list-screen';
  static const String findOpponents = '/find-opponents-screen';
  static const String clubProfile = '/club-profile-screen';
  static const String userProfile = '/user-profile-screen';
  static const String homeFeed = '/home-feed-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TournamentDetailScreen(),
    tournamentDetail: (context) => const TournamentDetailScreen(),
    tournamentList: (context) => const TournamentListScreen(),
    findOpponents: (context) => const FindOpponentsScreen(),
    clubProfile: (context) => const ClubProfileScreen(),
    userProfile: (context) => const UserProfileScreen(),
    homeFeed: (context) => const HomeFeedScreen(),
    // TODO: Add your other routes here
  };
}
