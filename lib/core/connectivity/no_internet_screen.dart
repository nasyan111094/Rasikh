import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/localization/loc_keys.dart';
import '../utils/get_asset_path.dart';
import '../widgets/picture.dart';
import 'cubit/connectivity_cubit.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRetryPressed() async {
    final cubit = context.read<ConnectivityCubit>();

    // Show a snackbar that we're retrying
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("جاري إعادة المحاولة..."),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Call the Cubit's checkConnectivity method
    await cubit.checkConnectivity();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.05),
                colorScheme.surfaceVariant.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Picture(getAssetIcon("no_internet.svg") , fit: BoxFit.contain),
                ),
                const SizedBox(height: 30),
                Text(
                  "انقطع الاتصال بالإنترنت",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onBackground, // استخدام لون الثيم
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                        color: colorScheme.shadow.withOpacity(0.25),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "تحقق من الشبكة وحاول مرة أخرى",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 35),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: ElevatedButton.icon(
                    onPressed: _onRetryPressed,
                    icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
                    label: Text(
                      "إعادة المحاولة",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 8,
                      shadowColor: colorScheme.shadow.withOpacity(0.3),
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
