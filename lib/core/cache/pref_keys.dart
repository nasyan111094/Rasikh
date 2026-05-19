// ─────────────────────────────────────────────────────────────────────────────
// pref_keys.dart
// Central registry for every SharedPreferences key used in the app.
// ─────────────────────────────────────────────────────────────────────────────

class PrefKeys {
  PrefKeys._();

  // ── User (regular) ─────────────────────────────────────────────────────────
  static const String currentUser    = 'currentUser';
  static const String cachedVendorType    = 'cachedVendorType';
  static const String userToken      = 'userToken';
  static const String refreshToken   = 'refreshToken';
  static const String otpToken       = 'otpToken';

  // ── Lawyer ─────────────────────────────────────────────────────────────────
  static const String lawyerToken    = 'lawyerToken';   // fixed typo (was lawerToken)

  // ── UI / Theme ─────────────────────────────────────────────────────────────
  static const String kIsDarkTheme   = 'kIsDarkTheme';
  static const String themeModeKey   = 'themeMode';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String onBoardingDone = 'onBoardingState';   // true once user has seen it
  static const String userOnBoardIsSkipped = 'onBoardingSkipped';

  // ── Misc ───────────────────────────────────────────────────────────────────
  static const String userLangKey       = 'lang';
  static const String userKey           = 'user';
  static const String userProfileKey    = 'userProfile';
  static const String userAddressList   = 'addressList';
}