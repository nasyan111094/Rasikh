import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({Key? key}) : super(key: key);




  Future<void> showEndSessionDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              /// 🔹 Main dialog content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تأكيد إنهاء',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هل تريد إنهاء الجلسة الآن؟',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// 🔹 Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'لا',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>Nav.endSessionScreen(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'نعم',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 🔹 Circle icon at top
              Positioned(
                top: -28,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.surface,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 Background (main caller)
          const Picture(
            'https://amrlaw.com.sa/wp-content/uploads/2024/12/%D8%A7%D8%B3%D8%AA%D8%B4%D8%A7%D8%B1%D8%A9-%D9%82%D8%A7%D9%86%D9%88%D9%86%D9%8A%D8%A9-%D9%85%D9%87%D9%86%D9%8A%D8%A9-%D9%85%D9%86-%D9%85%D8%AD%D8%A7%D9%85%D9%8A-%D9%81%D9%8A-%D8%AC%D8%AF%D8%A9-%D8%A7%D9%84%D9%85%D9%85%D9%84%D9%83%D8%A9-%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-%D8%A7%D9%84%D8%B3%D8%B9%D9%88%D8%AF%D9%8A%D8%A9.png',
            fit: BoxFit.cover,
          ),

          /// 🔹 Top button ("استشارة فورية")
          Positioned(
            top: 30,
            right: 0,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'استشارة فورية',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Small floating preview video
          Positioned(
            top: 100,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.onSurface.withOpacity(0.4)),
                ),
                child: const Picture(
                  'https://cdn.salla.sa/nrOXq/55a518ac-ad37-45ac-846c-b039ecdb5f7b-1000x1000-Qz5I2x4W5qibUfhbQBXkrxE8Gc6kgtQIGO8WHDQq.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// 🔹 Bottom section (name, timer, controls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.background.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Name
                  Text(
                    'عبدالله بن فهد الشمري',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '55 : 09   دقيقة',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 45),

                  /// Control buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: colorScheme.onSurface.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            onTap: ()
                            {
                              showEndSessionDialog(context);
                            },
                            icon: Icons.call_end,
                            color: colorScheme.error,
                            iconColor: colorScheme.onError,
                            size: 58,
                          ),
                          const SizedBox(width: 18),
                          _buildControlButton(
                            onTap: () {},
                            icon: Icons.flip_camera_ios,
                            color: colorScheme.surface,
                            iconColor: colorScheme.onSurface,
                            size: 48,

                          ),
                          const SizedBox(width: 18),
                          _buildControlButton(
                            onTap: () {},
                            icon: Icons.camera_alt,
                            color: colorScheme.surface,
                            iconColor: colorScheme.onSurface,
                            size: 48,
                          ),
                          const SizedBox(width: 18),
                          _buildControlButton(
                            onTap: () {},
                            icon: Icons.volume_up,
                            color: colorScheme.surface,
                            iconColor: colorScheme.onSurface,
                            size: 48,
                          ),
                          const SizedBox(width: 18),
                          _buildControlButton(
                            onTap: () {},
                            icon: Icons.mic_off,
                            color: colorScheme.surface,
                            iconColor: colorScheme.onSurface,
                            size: 48,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Reusable control button
  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required GestureTapCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(color == Colors.red ? 1 : 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: iconColor.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.45,
        ),
      ),
    );
  }
}
