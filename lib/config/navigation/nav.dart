import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/widget_utils.dart';

import 'package:rasikh/core/widgets/delete_bottom_sheet.dart';
import 'package:rasikh/core/widgets/image_cropper.dart';
import 'package:rasikh/core/widgets/logout_bottom_sheet.dart';
import 'package:rasikh/core/widgets/must_login_bottom_sheet.dart';



import 'package:rasikh/features/common/Auth/screens/auth_page.dart';
import 'package:rasikh/features/common/Auth/screens/otp_page.dart';



import '../../Shared/bottom_sheets/terms_and_condition_sheet.dart';

import '../../features/Company/company_register_completion/pages/company_completion_page.dart';
import '../../features/Lawyer/adding_work_appointment/adding_work_appointment_screen.dart';
import '../../features/Lawyer/lawer_register_compilation/screens/lawyer_license_page.dart';
import '../../features/Lawyer/lawer_register_compilation/screens/lawyer_personal_info_page.dart';
import '../../features/Lawyer/lawer_register_compilation/screens/lawyer_qualifications_page.dart';
import '../../features/Lawyer/lawer_register_compilation/screens/lawyer_specialization_page.dart';
import '../../features/Lawyer/lawyer-appointments/lawyer_appointments_screen.dart';

import '../../features/Lawyer/lawyer_Settings/screens/helping_center_screen.dart';
import '../../features/Lawyer/lawyer_Settings/screens/lawyer_edit_profile.dart';
import '../../features/Lawyer/lawyer_Settings/screens/lawyer_profile_screen.dart';
import '../../features/Lawyer/lawyer_Settings/screens/lawyer_rates_screen.dart';
import '../../features/Lawyer/lawyer_Settings/screens/lawyer_specializations_screen.dart';
import '../../features/Lawyer/lawyer_Settings/screens/lawyer_update_licence_screen.dart';
import '../../features/Lawyer/lawyer_Settings/screens/wallet_screen.dart';
import '../../features/Lawyer/lawyer_Settings/screens/withdraw_request_screen.dart';

import '../../features/User/Appointments/appointment_details_screen.dart';

import '../../features/User/application/appointment_booking_screen(3.3).dart';
import '../../features/User/application/chat_screen.dart';
import '../../features/User/application/chooseLawyerScreen(4).dart';
import '../../features/User/application/choose_specialty_screen(1).dart';
import '../../features/User/application/connecting_to_lawyer_screen.dart';
import '../../features/User/application/consultation_details_screen(3.1_2).dart';
import '../../features/User/application/consultation_type_screen(2).dart';
import '../../features/User/application/end_session_screen.dart';
import '../../features/User/application/payment_screen(5).dart';
import '../../features/User/application/video_call_screen.dart';

import '../../features/User/lawyer_details/lawyer_details_screen.dart';

import '../../features/User/profile/screens/change_phone_number.dart';
import '../../features/User/profile/screens/financial_transactions_screen.dart';
import '../../features/User/profile/screens/setting_screen.dart';

import '../../features/User/user_register_completion/pages/user_completion_page.dart';
import '../../features/common/Auth/models/auth_model.dart';
import '../../features/common/OnBoarding/screens/on_boarding_screen.dart';
import '../../features/common/account_type_selection/screens/account_type_screen.dart';
import '../../features/common/layout/layout_screen.dart';

import 'pages_keys.dart';

/// don't use Navigator.of(context)
/// must use this
abstract class Nav {
  static final mainNavKey = GlobalKey<NavigatorState>();

  // ─────────────────────────────────────────────
  // Vendor Completion Flow
  // ─────────────────────────────────────────────

  static Future<void> vendorCompletion(
      BuildContext context, {
        required VendorType vendor,
      }) async {
    switch (vendor) {
      case VendorType.lawyer:
        await _push(
          context,
          PageKey.login,
          const LawyerPersonalInfoPage(),
        );
        break;

      case VendorType.user:
        await _push(
          context,
          PageKey.login,
          const UserCompletionPage(),
        );
        break;

      case VendorType.company:
        await _push(
          context,
          PageKey.login,
          const CompanyCompletionPage(),
        );
        break;
    }
  }

  // ─────────────────────────────────────────────
  // OLD Alias (Backward Compatibility)
  // ─────────────────────────────────────────────

  static registerationSecondPage(
      BuildContext context,
      ) async =>
      await vendorCompletion(
        context,
        vendor: VendorType.lawyer,
      );

  // ─────────────────────────────────────────────
  // Lawyer Completion Flow
  // ─────────────────────────────────────────────

  static registerLawyerSpecialization(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerSpecializationPage(),
      );

  static qualificationsSExperienceScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerQualificationsPage(),
      );

  static licensePracticeScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerLicensePage(),
      );

  static lawer_personal_info_page(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerPersonalInfoPage(),
      );

  // ─────────────────────────────────────────────
  // Bottom Sheets
  // ─────────────────────────────────────────────

  static filterBottomSheet(
      BuildContext context,
      Widget bottomSheetBody,
      ) async =>
      await _pushDraggableBottomSheet(
        key: PageKey.bottomSheetFilter,
        context: context,
        page: bottomSheetBody,
        barrierDismissible: true,
      );

  static deleteBottomSheet({
    required BuildContext context,
    required VoidCallback onDelete,
  }) async =>
      await _pushBottomSheet(
        key: PageKey.deleteBottomSheet,
        context: context,
        page: DeleteBottomSheet(
          onYesClicked: onDelete,
        ),
        barrierDismissible: true,
      );

  static logoutBottomSheet({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async =>
      await _pushBottomSheet(
        key: PageKey.logoutBottomSheet,
        context: context,
        page: LogoutBottomSheet(
          onYesClicked: onConfirm,
        ),
        barrierDismissible: true,
      );

  static loginBottomSheet({
    required BuildContext context,
  }) async =>
      await _pushBottomSheet(
        key: PageKey.loginBottomSheet,
        context: context,
        page: const LoginBottomSheet(),
        barrierDismissible: true,
      );

  static imagePickerBottomSheet({
    required BuildContext context,
    required Widget content,
  }) async =>
      await _pushBottomSheet(
        key: PageKey.logoutBottomSheet,
        context: context,
        page: content,
        barrierDismissible: true,
      );

  static termsAndConditions(
      BuildContext context,
      ) async =>
      await _pushBottomSheet(
        key: PageKey.termsAndConditions,
        context: context,
        page: const TermsAndCondSheets(),
        barrierDismissible: true,
      );

  static placeOfWorkBottomSheet(
      BuildContext context,
      Widget bottomSheetBody,
      ) async =>
      await _pushBottomSheet(
        key: PageKey.placeOfWorkBottomSheet,
        context: context,
        page: bottomSheetBody,
        barrierDismissible: true,
      );

  static placeOfBirthBottomSheet(
      BuildContext context,
      Widget bottomSheetBody,
      ) async =>
      await _pushBottomSheet(
        key: PageKey.placeOfBirthBottomSheet,
        context: context,
        page: bottomSheetBody,
        barrierDismissible: true,
      );

  // ─────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────

  static cancelContractDialog(
      BuildContext context,
      Widget bottomSheetBody,
      ) async =>
      await _pushDialog(
        key: PageKey.contractsPage,
        context: context,
        page: bottomSheetBody,
        barrierDismissible: true,
      );

  static soonDialog(
      BuildContext context,
      Widget bottomSheetBody,
      ) async =>
      await _pushDialog(
        key: PageKey.home,
        context: context,
        page: bottomSheetBody,
        barrierDismissible: true,
      );

  static sureReservation(
      BuildContext context,
      Widget bottomSheetBody,
      ) async =>
      await _pushDialog(
        key: PageKey.sureReservation,
        context: context,
        page: bottomSheetBody,
        barrierDismissible: true,
      );

  // ─────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────

  static registerOtp({
    required BuildContext context,
    required String phoneNumber,
    required String otpCode,
    required int from,
  }) async =>
      await _push(
        context,
        PageKey.otp,
        OtpPage(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
          from: from,
        ),
      );

  static login(BuildContext context) async => await _push(
    context,
    PageKey.login,
    const AuthPage(),
  );

  // ─────────────────────────────────────────────
  // Lawyer Settings
  // ─────────────────────────────────────────────

  static withdrawRequestScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const WithdrawRequestScreen(),
      );

  static walletScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const WalletScreen(),
      );

  static helpingCenterScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const HelpingCenterScreen(),
      );

  static lawyerRatesScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerRatesScreen(),
      );

  static financialTransactionsScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const FinancialTransactionsScreen(),
      );

  static lawyerSpecializationsScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerSpecializationsScreen(),
      );

  static lawyerUpdateLicense(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerUpdateLicenceScreen(),
      );

  static lawyerProfileScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        LawyerProfileScreen(),
      );

  static lawyerEditProfileScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerEditProfileScreen(),
      );

  // ─────────────────────────────────────────────
  // Lawyer Features
  // ─────────────────────────────────────────────

  static addWorkAppointment(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const AddingWorkAppointmentScreen(),
      );

  static lawyerAppointmentsScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        LawyerAppointmentsScreen(),
      );

  // ─────────────────────────────────────────────
  // User Features
  // ─────────────────────────────────────────────

  static changePhoneNumber(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ChangePhoneNumber(),
      );

  static lawyerDetailsScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const LawyerDetailsScreen(),
      );

  static endSessionScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const EndSessionScreen(),
      );

  static chat(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ChatScreen(),
      );

  static videoCallScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const VideoCallScreen(),
      );

  static connectingToLawyerScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ConnectingToLawyerScreen(),
      );

  static appointmentBookingScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const AppointmentBookingScreen(),
      );

  static paymentScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        PaymentScreen(),
      );

  static chooseLawyerScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ChooseLawyerScreen(),
      );

  static appointmentDetailsScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const AppointmentDetailsScreen(),
      );

  static selectConsulationType(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ConsultationTypeScreen(),
      );

  static consultationDetailsScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ConsultationDetailsScreen(),
      );

  static chooseSpecialtyScreen(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const ChooseSpecialtyScreen(),
      );

  static settings(
      BuildContext context,
      ) async =>
      await _push(
        context,
        PageKey.login,
        const SettingsScreen(),
      );

  // ─────────────────────────────────────────────
  // Main Navigation
  // ─────────────────────────────────────────────

  static layout(BuildContext context) async => await _replaceAll(
    context,
    PageKey.login,
    const LayoutPage(),
  );

  static account_type_screen(BuildContext context) async =>
      await _replaceAll(
        context,
        PageKey.login,
        const AccountTypeScreen(),
      );

  static onBoarding(BuildContext context) async => await _replaceAll(
    context,
    PageKey.login,
    const OnBoardingScreen(),
  );

  // ─────────────────────────────────────────────
  // Image Cropper
  // ─────────────────────────────────────────────

  static Future<Uint8List?> crop(
      BuildContext context,
      Uint8List image,
      ) async =>
      await _push(
        context,
        PageKey.crop,
        ImageCropper(image: image),
      );

  // ─────────────────────────────────────────────
  // Internal Navigation Helpers
  // ─────────────────────────────────────────────

  static Future<T?> _pushDialog<T>({
    required BuildContext context,
    required PageKey key,
    required Widget page,
    bool barrierDismissible = false,
  }) async {
    await _closeDrawer(context);

    if (!context.mounted) return null;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.white12,
      routeSettings: RouteSettings(name: key.name),
      builder: (context) => page,
    );
  }

  static Future<T?> _pushBottomSheet<T>({
    required BuildContext context,
    required PageKey key,
    required Widget page,
    double? radius,
    BoxConstraints? constraints,
    bool barrierDismissible = false,
  }) async {
    await _closeDrawer(context);

    if (!context.mounted) return null;

    return showModalBottomSheet<T?>(
      isDismissible: barrierDismissible,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      constraints: constraints,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            radius ?? getBorderRadius(),
          ),
        ),
      ),
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: page,
      ),
    );
  }

  static Future<T?> _pushDraggableBottomSheet<T>({
    required BuildContext context,
    required PageKey key,
    required Widget page,
    double? radius,
    BoxConstraints? constraints,
    bool barrierDismissible = false,
  }) async {
    await _closeDrawer(context);

    if (!context.mounted) return null;

    return showModalBottomSheet<T?>(
      isDismissible: barrierDismissible,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      enableDrag: true,
      context: context,
      builder: (context) => page,
    );
  }

  static Future<T?> _push<T>(
      BuildContext context,
      PageKey key,
      Widget page,
      ) async {
    await _closeDrawer(context);

    if (!context.mounted) return null;

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 400),
        alignment: Alignment.bottomCenter,
        settings: RouteSettings(name: key.name),
        child: page,
        childCurrent: page,
      ),
    );

    return null;
  }

  static Future<T?> _replace<T, TO>(
      BuildContext context,
      PageKey key,
      Widget page,
      ) async {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 400),
        alignment: Alignment.bottomCenter,
        settings: RouteSettings(name: key.name),
        child: page,
        childCurrent: page,
      ),
    );

    return null;
  }

  static Future<T?> _replaceAll<T>(
      BuildContext context,
      PageKey key,
      Widget page,
      ) async {
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 400),
        alignment: Alignment.bottomCenter,
        child: page,
        childCurrent: page,
        settings: RouteSettings(name: key.name),
      ),
          (route) => false,
    );

    return null;
  }

  static Future<void> _closeDrawer(
      BuildContext context,
      ) async {
    final scaffoldState = Scaffold.maybeOf(context);

    if (scaffoldState?.isDrawerOpen == true) {
      scaffoldState?.closeDrawer();

      await Future.delayed(
        Durations.medium1,
      );
    }
  }
}