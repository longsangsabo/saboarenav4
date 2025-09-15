import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChallengeModalWidget extends StatefulWidget {
  final Map<String, dynamic> player;
  final String challengeType; // 'thach_dau' or 'giao_luu'
  final VoidCallback? onSendChallenge;

  const ChallengeModalWidget({
    super.key,
    required this.player,
    required this.challengeType,
    this.onSendChallenge,
  });

  @override
  State<ChallengeModalWidget> createState() => _ChallengeModalWidgetState();
}

class _ChallengeModalWidgetState extends State<ChallengeModalWidget> {
  String _selectedGameType = '8-ball';
  int _handicapValue = 0;
  int _spaPoints = 0;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedLocation = '';
  String _notes = '';

  final List<String> _gameTypes = ['8-ball', '9-ball', '10-ball'];
  final List<String> _locations = [
    'Billiards Club Sài Gòn',
    'Pool House Thủ Đức',
    'Champion Billiards',
    'Golden Ball Club',
    'Khác (ghi chú)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = _locations.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challengeType == 'thach_dau'
                          ? 'Thách đấu'
                          : 'Giao lưu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'với ${widget.player["name"]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGameTypeSelection(),
                  SizedBox(height: 3.h),
                  if (widget.challengeType == 'thach_dau') ...[
                    _buildHandicapSelection(),
                    SizedBox(height: 3.h),
                    _buildSpaPointsSelection(),
                    SizedBox(height: 3.h),
                  ],
                  _buildDateTimeSelection(),
                  SizedBox(height: 3.h),
                  _buildLocationSelection(),
                  SizedBox(height: 3.h),
                  _buildNotesSection(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Send challenge button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendChallenge,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text(
                  widget.challengeType == 'thach_dau'
                      ? 'Gửi thách đấu'
                      : 'Gửi lời mời giao lưu',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildGameTypeSelection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại game',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: _gameTypes.map((gameType) {
            final isSelected = _selectedGameType == gameType;
            return ChoiceChip(
              label: Text(gameType),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedGameType = gameType;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHandicapSelection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Handicap',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              _handicapValue == 0 ? 'Không' : '$_handicapValue bàn',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _handicapValue.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (value) {
            setState(() {
              _handicapValue = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSpaPointsSelection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Điểm SPA cược',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              _spaPoints == 0 ? 'Không cược' : '$_spaPoints điểm',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [0, 10, 20, 50, 100, 200].map((points) {
            final isSelected = _spaPoints == points;
            return ChoiceChip(
              label: Text(points == 0 ? 'Không' : '$points'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _spaPoints = points;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectDate,
                icon: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectTime,
                icon: CustomIconWidget(
                  iconName: 'access_time',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSelection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Địa điểm',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          ),
          items: _locations.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLocation = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghi chú',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Thêm ghi chú cho trận đấu...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(3.w),
          ),
          onChanged: (value) {
            _notes = value;
          },
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _sendChallenge() {
    // Handle challenge sending logic here
    if (widget.onSendChallenge != null) {
      widget.onSendChallenge!();
    }
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.challengeType == 'thach_dau'
              ? 'Đã gửi thách đấu đến ${widget.player["name"]}'
              : 'Đã gửi lời mời giao lưu đến ${widget.player["name"]}',
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }
}
