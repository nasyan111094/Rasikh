import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';

import '../theme/sizes.dart';

class NoConnectionScreen extends StatefulWidget {
  const NoConnectionScreen({super.key});

  @override
  State<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends State<NoConnectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openWifiSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  void _openMobileDataSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.dataRoaming);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: colorScheme.background, // background حسب الثيم
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _buttonAnimation,
                  child: Picture(
                    getAssetIcon("no_internet.svg"),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "لا يوجد اتصال بالإنترنت",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onBackground, // نص حسب الثيم
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: colorScheme.shadow.withOpacity(0.5),
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                ),
                Gap(h20),
                Text(
                  "شغّل بيانات الجوال من إعدادات الشبكة أو من شريط الإشعارات علشان تقدر تكمل الاتصال",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onBackground, // نص حسب الثيم

                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: colorScheme.shadow.withOpacity(0.5),
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _buttonAnimation,
                  child: ElevatedButton.icon(
                    onPressed: _openWifiSettings,
                    icon: Icon(Icons.wifi, color: colorScheme.onPrimary),
                    label: Text(
                      "فتح إعدادات الواي فاي",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 6,
                      shadowColor: colorScheme.shadow,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: _buttonAnimation,
                  child: ElevatedButton.icon(
                    onPressed: _openMobileDataSettings,
                    icon: Icon(Icons.data_usage, color: colorScheme.onPrimary),
                    label: Text(
                      "فتح بيانات الهاتف",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 6,
                      shadowColor: colorScheme.shadow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
