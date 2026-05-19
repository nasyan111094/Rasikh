import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';

import 'package:size_config/size_config.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(

      body: Column(
        children: [
          _buildHeader(theme, colorScheme, textTheme),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              children: [
                _buildReceiverMessage(
                  context,
                  'السلام عليكم، أنا المحامي عبدالله الشمري،\nكيف أقدر اساعدك اليوم؟',
                  '09:25 AM',
                ),
                SizedBox(height: 12.h),
                _buildSenderMessage(
                  context,
                  'وعليكم السلام استاذ عبدالله، عندي مشكلة\nفي قضية عمالية وابغى اعرف وضعي\nالقانوني.',
                  '09:25 AM',
                ),
                SizedBox(height: 12.h),
                _buildReceiverMessage(
                  context,
                  'تفضل أخوي، ممكن تعطيني تفاصيل أكثر عن\nالقضية؟ مثل نوع العقد وسبب النزاع.',
                  '09:26 AM',
                ),
              ],
            ),
          ),
          _buildInputField(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.only(top: 50.h, bottom: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Arrow button
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color:theme.dividerColor.withOpacity(.5),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Icon(
              Icons.arrow_back,
              size: 20.sp,
              color: colorScheme.onSurface,
            ),
          ),
          Gap(10.w) ,
          CircleAvatar(
            radius: 25.h,
            backgroundColor: colorScheme.surfaceVariant,
            child: Icon(
              Icons.person,
              color: colorScheme.onSurfaceVariant,
              size: 28.sp,
            ),
          ),
          Gap(10.w) ,
          // Name and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عبدالله بن فهد الشمري',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'دقيقة 9 : 55',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Profile picture
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildReceiverMessage(BuildContext context, String text, String time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 50.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(.5),
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CircleAvatar(
          radius: 18.h,
          backgroundColor: theme.dividerColor.withOpacity(.5),
          child: Icon(
            Icons.person,
            color: colorScheme.onSurfaceVariant,
            size: 18.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSenderMessage(BuildContext context, String text, String time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18.h,
          backgroundColor: colorScheme.surfaceVariant,
          child: Icon(
            Icons.person,
            color: colorScheme.onSurfaceVariant,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(  height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 50.w),
      ],
    );
  }

  Widget _buildInputField(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Send icon
          _buildIconButton(Icons.send, theme.dividerColor.withOpacity(.5), theme.hintColor),
          SizedBox(width: 12.w),
          // Text field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(25.h),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب الرسالة هنا...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontSize: 14.sp,

                    ),
                    fillColor: theme.dividerColor,
                    filled: true ,
                    border: InputBorder.none,

                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Attachment icon
          _buildIconButton(Icons.attach_file, colorScheme.surfaceVariant, theme.hintColor),
          SizedBox(width: 12.w),
          // Mic button
          _buildIconButton(Icons.mic, colorScheme.primary, colorScheme.onPrimary),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20.sp, color: iconColor),
    );
  }
}
