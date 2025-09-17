import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const CustomIconWidget({
    super.key,
    required this.iconName,
    this.size = 24,
    this.color,
  });

  static const Map<String, IconData> _iconMap = {
    // Common actions/navigation
    'add': Icons.add,
    'arrow_back': Icons.arrow_back,
    'arrow_forward': Icons.arrow_forward,
    'chevron_right': Icons.chevron_right,
    'clear': Icons.clear,
    'close': Icons.close,
    'edit': Icons.edit,
    'logout': Icons.logout,
    'more_vert': Icons.more_vert,
    'qr_code': Icons.qr_code,
    'search': Icons.search,
    'share': Icons.share,
    'download': Icons.download,

    // Media
    'camera_alt': Icons.camera_alt,
    'photo_library': Icons.photo_library,

    // Places/Map
    'location_on': Icons.location_on,
    'location_off': Icons.location_off,
    'north_west': Icons.north_west,
    'history': Icons.history,

    // Tournament/score
    'emoji_events': Icons.emoji_events,
    'emoji_events_outlined': Icons.emoji_events_outlined,
    'leaderboard': Icons.leaderboard,
    'military_tech': Icons.military_tech,
    'payments': Icons.payments,
    'check_circle': Icons.check_circle,

    // Misc
    'account_tree': Icons.account_tree,
    'business': Icons.business,
    'calendar_today': Icons.calendar_today,
    'how_to_reg': Icons.how_to_reg,
    'people': Icons.people,
    'person': Icons.person,
    'rule': Icons.rule,
    'timer': Icons.timer,
    'monetization_on': Icons.monetization_on,
    'search_off': Icons.search_off,
    'rate_review': Icons.rate_review,
    'sports_bar': Icons.sports_bar,
    'access_time': Icons.access_time,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[iconName] ?? Icons.help_outline;
    return Icon(
      icon,
      size: size,
      color: color ?? Theme.of(context).iconTheme.color,
      semanticLabel: iconName,
    );
  }
}
