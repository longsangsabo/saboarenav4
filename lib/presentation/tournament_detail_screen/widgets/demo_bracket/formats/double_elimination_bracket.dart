import 'package:flutter/material.dart';// 🎯 SABO ARENA - Double Elimination Bracket

import '../components/bracket_components.dart';// Complete Double Elimination tournament format implementation



class DoubleEliminationBracket extends StatelessWidget {import 'package:flutter/material.dart';

  final int playerCount;import '../components/bracket_components.dart';

  final VoidCallback? onFullscreenTap;import '../shared/tournament_data_generator.dart';



  const DoubleEliminationBracket({class DoubleEliminationBracket extends StatelessWidget {

    super.key,  final int playerCount;

    required this.playerCount,  final VoidCallback? onFullscreenTap;

    this.onFullscreenTap,

  });  const DoubleEliminationBracket({

    super.key,

  @override    required this.playerCount,

  Widget build(BuildContext context) {    this.onFullscreenTap,

    return BracketContainer(  });

      title: 'Double Elimination',

      subtitle: '$playerCount players',  @override

      onFullscreenTap: onFullscreenTap,  Widget build(BuildContext context) {

      onInfoTap: () => _showInfo(context),    return BracketContainer(

      child: const Center(      title: 'Double Elimination',

        child: Text(      subtitle: '$playerCount players',

          'Double Elimination\nComing Soon...',      onFullscreenTap: onFullscreenTap,

          textAlign: TextAlign.center,      onInfoTap: () => _showDoubleEliminationInfo(context),

          style: TextStyle(fontSize: 16, color: Colors.grey),      child: _buildBracketContent(context),

        ),    );

      ),  }

    );

  }  Widget _buildBracketContent(BuildContext context) {

    return const Center(

  void _showInfo(BuildContext context) {      child: Text(

    showDialog(        'Double Elimination\nComing Soon...',

      context: context,        textAlign: TextAlign.center,

      builder: (context) => AlertDialog(        style: TextStyle(

        title: const Text('Double Elimination'),          fontSize: 16,

        content: const Text('🎯 Mỗi player có 2 cơ hội\n🏆 Winners Bracket + Losers Bracket\n🏅 Grand Final với bracket reset'),          color: Colors.grey,

        actions: [        ),

          TextButton(      ),

            onPressed: () => Navigator.of(context).pop(),    );

            child: const Text('Đóng'),  }

          ),

        ],  void _showSingleEliminationInfo(BuildContext context) {

      ),    showDialog(

    );      context: context,

  }      builder: (context) => AlertDialog(

}        title: const Row(

          children: [

class DoubleEliminationFullscreenDialog extends StatelessWidget {            Icon(Icons.info_outline, color: Colors.blue),

  final int playerCount;            SizedBox(width: 8),

            Text('Single Elimination'),

  const DoubleEliminationFullscreenDialog({          ],

    super.key,        ),

    required this.playerCount,        content: const SingleChildScrollView(

  });          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

  @override            mainAxisSize: MainAxisSize.min,

  Widget build(BuildContext context) {            children: [

    return Dialog.fullscreen(              Text(

      child: Scaffold(                'Hình thức thi đấu loại trực tiếp',

        appBar: AppBar(                style: TextStyle(

          title: Text('Double Elimination - $playerCount Players'),                  fontSize: 16,

          leading: IconButton(                  fontWeight: FontWeight.bold,

            icon: const Icon(Icons.close),                ),

            onPressed: () => Navigator.of(context).pop(),              ),

          ),              SizedBox(height: 12),

        ),              Text(

        body: const Center(                '🎯 Nguyên tắc cơ bản:',

          child: Text('Double Elimination Fullscreen\nComing Soon...'),                style: TextStyle(

        ),                  fontSize: 14,

      ),                  fontWeight: FontWeight.bold,

    );                  color: Colors.green,

  }                ),

}              ),
              SizedBox(height: 4),
              Text('• Mỗi người chơi chỉ được thua 1 lần duy nhất'),
              Text('• Thua 1 trận = bị loại khỏi giải đấu'),
              Text('• Người thắng tiến vào vòng tiếp theo'),
              Text('• Chỉ còn 1 người cuối cùng = Vô địch'),
              SizedBox(height: 12),
              Text(
                '⚡ Đặc điểm:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              Text('• Nhanh và đơn giản'),
              Text('• Số trận ít nhất'),
              Text('• Không có cơ hội sửa sai'),
              Text('• Tính kịch tính cao'),
              SizedBox(height: 12),
              Text(
                '🏆 Ứng dụng:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 4),
              Text('• Các giải đấu lớn (World Cup, Olympics)'),
              Text('• Giải đấu có thời gian hạn chế'),
              Text('• Khi cần xác định nhà vô địch nhanh'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

// Full screen dialog for Single Elimination
class SingleEliminationFullscreenDialog extends StatelessWidget {
  final int playerCount;

  const SingleEliminationFullscreenDialog({
    super.key,
    required this.playerCount,
  });

  @override
  Widget build(BuildContext context) {
    final rounds = TournamentDataGenerator.calculateSingleEliminationRounds(playerCount);
    
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Single Elimination - $playerCount Players'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showSingleEliminationInfo(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rounds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final round = entry.value;
                  
                  return RoundColumn(
                    title: round['title'],
                    matches: round['matches'],
                    roundIndex: index,
                    totalRounds: rounds.length,
                    isFullscreen: true,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSingleEliminationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Single Elimination'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hình thức thi đấu loại trực tiếp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '🎯 Nguyên tắc cơ bản:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text('• Mỗi người chơi chỉ được thua 1 lần duy nhất'),
              Text('• Thua 1 trận = bị loại khỏi giải đấu'),
              Text('• Người thắng tiến vào vòng tiếp theo'),
              Text('• Chỉ còn 1 người cuối cùng = Vô địch'),
              SizedBox(height: 12),
              Text(
                '⚡ Đặc điểm:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              Text('• Nhanh và đơn giản'),
              Text('• Số trận ít nhất'),
              Text('• Không có cơ hội sửa sai'),
              Text('• Tính kịch tính cao'),
              SizedBox(height: 12),
              Text(
                '🏆 Ứng dụng:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 4),
              Text('• Các giải đấu lớn (World Cup, Olympics)'),
              Text('• Giải đấu có thời gian hạn chế'),
              Text('• Khi cần xác định nhà vô địch nhanh'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}