import 'package:flutter/material.dart';

import '../terms/terms_and_conditions_view.dart';

/// Modal bottom sheet used by the auth and registration flows so users can
/// review the full terms before accepting them.
class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.92,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: const TermsAndConditionsView(isSheet: true),
      ),
    );
  }
}
