import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/features/Lawyer/consultation/consultations_screen.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/lawyer_appointments_screen.dart';
import 'package:rasikh/features/Lawyer/lawyer-home/lawyer_home.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';

import 'package:size_config/size_config.dart';

import '../../../core/app_wrapper.dart';
import '../../../core/cache/cache_helper.dart';
import '../../Lawyer/lawyer_Settings/screens/lawyer_settings_screen.dart';

import '../../User/Appointments/appointments_screen.dart';
import '../../User/Consulation/consulations_screen.dart';
import '../../User/home/home_page.dart';
import '../../User/profile/screens/profile_screen.dart';
import '../account_type_selection/models/account_type_model.dart';
import '../account_type_selection/screens/account_type_screen.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({Key? key}) : super(key: key);

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  int _selectedIndex = 0;

  List<NavItem> _getNavItems(BuildContext context) {
    final theme = Theme.of(context);
    return [
      NavItem(
        svgIcon: "assets/icons/home.svg",
        label: 'الرئيسيه',
        color: theme.colorScheme.primary,
      ),
      NavItem(
        svgIcon: "assets/icons/consultation.svg",
        label: "إستشاراتي",
        color: theme.colorScheme.primary,
      ),
      NavItem(
        svgIcon: "assets/icons/Calendar.svg",
        label: "مواعيدي",
        color: theme.colorScheme.primary,
      ),
      NavItem(
        svgIcon: "assets/icons/user.svg",
        label: "حسابي",
        color: theme.colorScheme.primary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navItems = _getNavItems(context);

    final isDark = theme.brightness == Brightness.dark;
    final barColor = theme.scaffoldBackgroundColor;

    return AppWrapper(
      withSafeArea: true,
      child: Scaffold(
        body: _selectedIndex == 0
            ? (getIt<CacheHelper>().cachedVendorType == VendorType.user ? HomePage() : LawyerHomeScreen())
            : _selectedIndex == 1
                ? LawerConsultationsScreen()
                : _selectedIndex == 2
                    ? (getIt<CacheHelper>().cachedVendorType  == VendorType.user ?  MyAppointmentsScreen() :LawyerAppointmentsScreen())
                    : getIt<CacheHelper>().cachedVendorType == VendorType.user ? ProfileScreen()  : LawyerSettingsScreen (),
        bottomNavigationBar: Container(
          height: 100.h, // 👈 ارتفاع ثابت للبار

          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:0.w, vertical: 0.h),
            child: Card(
              color: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(
                  color: greyFA,
                  width: 1,
                ),
              ),
              child: Row(
                children: List.generate(
                  navItems.length,
                  (index) => Expanded(
                    child: NavBarItem(
                      navItem: navItems[index],
                      isSelected: _selectedIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String svgIcon;
  final String label;
  final Color color;

  NavItem({
    required this.svgIcon,
    required this.label,
    required this.color,
  });
}

class NavBarItem extends StatelessWidget {
  final NavItem navItem;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    Key? key,
    required this.navItem,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // يوسّط الأيقونة والليبل
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? navItem.color : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              navItem.svgIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: isSelected
                ? Container(
                    key: const ValueKey('dot'),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: navItem.color,
                      shape: BoxShape.circle,
                    ),
                  )
                : Text(
                    navItem.label,
                    key: const ValueKey('text'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
