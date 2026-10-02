
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/widgets/account_item_widget.dart' show AccountItem;
import '../../../../config/navigation/nav.dart';
import '../../../User/profile/widgets/dialog_widget.dart';


class LawyerProfileScreen extends StatelessWidget {
  const LawyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withOpacity(0.2);
    final divider = Divider(color: dividerColor, thickness: 1, height: 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: GeneralAppBar(title: Loc.myProfile()),
        body: SafeArea(
          child: Column(
            children: [
              divider,
              const SizedBox(height: 20),
              _LawyerProfileMenuBody(divider: divider),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LawyerProfileMenuBody extends StatelessWidget {
  const _LawyerProfileMenuBody({required this.divider});
  final Divider divider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AccountItem(
            svgAsset: 'assets/icons/edit.svg',
            label: Loc.editPersonalData(),
            trailingChevronRight: true,
            onTap: () => Nav.lawyerEditProfileScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/user_id.svg',
            label: Loc.editPracticeLicense(),
            trailingChevronRight: true,
            onTap: () => Nav.lawyerUpdateLicense(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/mobile.svg',
            label: Loc.editMobileNumber(),
            trailingChevronRight: true,
            onTap: () => Nav.changePhoneNumber(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/Trash_Bin.svg',
            label: Loc.deleteAccount(),
            iconbgColor: Colors.red,
            trailingChevronRight: true,
            onTap: () => showLogoutAndDeletAccountConfirmDialog(
              context,
              title: Loc.confirmDeletion(),
              message: Loc.deleteAccountWarning(),
              svgAsset: 'assets/icons/Trash_Bin.svg',
              isLogout: false ,
            ),
          ),
        ],
      ),
    );
  }
}