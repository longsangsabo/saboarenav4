import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationWidget extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final bool isRegistered;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onWithdrawTap;

  const RegistrationWidget({
    super.key,
    required this.tournament,
    required this.isRegistered,
    this.onRegisterTap,
    this.onWithdrawTap,
  });

  @override
  Widget build(BuildContext context) {
    final registrationDeadline = tournament["registrationDeadline"] as String;
    final isDeadlinePassed = _isDeadlinePassed(registrationDeadline);
    final canRegister = !isDeadlinePassed &&
        (tournament["currentParticipants"] as int) <
            (tournament["maxParticipants"] as int);

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'how_to_reg',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Đăng ký tham gia',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildRequirementItem(
              'Hạn đăng ký', registrationDeadline, 'schedule'),
          SizedBox(height: 1.h),
          _buildRequirementItem('Yêu cầu rank',
              tournament["rankRequirement"] as String, 'military_tech'),
          SizedBox(height: 1.h),
          _buildRequirementItem(
              'Lệ phí', tournament["entryFee"] as String, 'payments'),
          SizedBox(height: 2.h),
          if (!isDeadlinePassed)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'timer',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _getTimeRemaining(registrationDeadline),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: _buildActionButton(canRegister, isDeadlinePassed),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 18,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool canRegister, bool isDeadlinePassed) {
    if (isDeadlinePassed) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Hết hạn đăng ký',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (isRegistered) {
      return OutlinedButton(
        onPressed: onWithdrawTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.error,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Đã đăng ký - Rút lui',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (!canRegister) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Đã đầy',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onRegisterTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            'Đăng ký ngay',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isDeadlinePassed(String deadline) {
    try {
      final deadlineDate =
          DateTime.parse(deadline.split(' ')[0].split('/').reversed.join('-'));
      return DateTime.now().isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  String _getTimeRemaining(String deadline) {
    try {
      final deadlineDate =
          DateTime.parse(deadline.split(' ')[0].split('/').reversed.join('-'));
      final now = DateTime.now();
      final difference = deadlineDate.difference(now);

      if (difference.inDays > 0) {
        return 'Còn ${difference.inDays} ngày để đăng ký';
      } else if (difference.inHours > 0) {
        return 'Còn ${difference.inHours} giờ để đăng ký';
      } else if (difference.inMinutes > 0) {
        return 'Còn ${difference.inMinutes} phút để đăng ký';
      } else {
        return 'Sắp hết hạn đăng ký';
      }
    } catch (e) {
      return 'Kiểm tra thời gian đăng ký';
    }
  }
}
