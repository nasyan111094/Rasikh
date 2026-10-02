
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_version_model.dart';

Future<void> _openStore(AppVersionCheck info, BuildContext context) async {
  final uri = Uri.tryParse(info.effectiveStoreUrl);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Loc.unableToOpenStore())),
      );
    }
  }
}

Future<void> showForceUpdateDialog(
  BuildContext context,
  AppVersionCheck info,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: _UpdateDialogBody(
        info: info,
        isForce: true,
        onUpdate: () => _openStore(info, context),
        onLater: null,
      ),
    ),
  );
}

Future<bool?> showOptionalUpdateDialog(
  BuildContext context,
  AppVersionCheck info,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _UpdateDialogBody(
      info: info,
      isForce: false,
      onUpdate: () {
        _openStore(info, context);
        Navigator.of(context).pop(true);
      },
      onLater: () => Navigator.of(context).pop(false),
    ),
  );
}

class _UpdateDialogBody extends StatelessWidget {
  final AppVersionCheck info;
  final bool isForce;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;

  const _UpdateDialogBody({
    required this.info,
    required this.isForce,
    required this.onUpdate,
    this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: colorScheme.primary,
                size: 28.w,
              ),
            ),
            Gap(14.h),
            Text(
              (info.title?.trim().isNotEmpty == true)
                  ? info.title!
                  : (isForce ? Loc.appUpdateRequired() : Loc.newUpdateAvailable()),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            Gap(8.h),
            Text(
              (info.message?.trim().isNotEmpty == true)
                  ? info.message!
                  : (isForce
                      ? Loc.pleaseUpdateToContinue()
                      : Loc.optionalUpdateAvailable()),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                height: 1.6,
                color: theme.hintColor,
              ),
            ),
            if (info.latestVersion != null) ...[
              Gap(8.h),
              Text(
                Loc.newVersionLabel(info.latestVersion),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
            Gap(18.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                ),
                child: Text(
                  Loc.updateNow(),
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isForce && onLater != null) ...[
              Gap(10.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: onLater,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: colorScheme.primary.withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                  ),
                  child: Text(
                    Loc.later(),
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
