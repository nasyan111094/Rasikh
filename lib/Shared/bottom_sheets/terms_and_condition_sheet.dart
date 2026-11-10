import 'package:flutter/material.dart';

import '../terms/terms_and_conditions_view.dart';

/// Legacy entry point kept for backwards compatibility.
///
/// Prefer [TermsAndConditionsScreen] for a full page, or
/// [TermsAndConditionsView] when embedding the documents in a sheet.
class TermsAndCondSheets extends StatelessWidget {
  const TermsAndCondSheets({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.92,
      child: const TermsAndConditionsView(isSheet: true),
    );
  }
}
