import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';

import 'terms_and_conditions_view.dart';

/// Full-page terms & conditions screen used from the profile, the lawyer
/// settings and the public navigation helper.
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GeneralAppBar(title: Loc.termsAndConditions()),
      body: const SafeArea(
        top: false,
        child: TermsAndConditionsView(),
      ),
    );
  }
}
