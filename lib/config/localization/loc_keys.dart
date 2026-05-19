// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:rasikh/config/localization/lang_repo.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';

abstract class Loc {
  static void switchLanguage(BuildContext context) {
    Locale currentLocale = context.locale;

    // Switch between English and Arabic
    if (currentLocale.languageCode == 'en') {
      context.setLocale(const Locale('ar'));
      getIt<LangRepo>().setLang("ar", context);
    } else {
      context.setLocale(const Locale('en'));
      getIt<LangRepo>().setLang("en", context);
    }
    //Nav.mainLayout(context);
    // Rebuild the UI to reflect the language change
  }

  static String en() => 'en';

  static String start_now() => 'start_now'.tr();

  static String next() => 'next'.tr();

  static String cameraSubtitle() => 'camersSubtitle'.tr();

  static String login() => 'login'.tr();

  static String midiationServices() => 'midiationServices'.tr();

  static String monthlyServices() => 'monthlyServices'.tr();

  static String email() => 'email'.tr();

  static String phone() => 'phone'.tr();

  static String gender() => 'gender'.tr();

  static String noInternetConnection() => 'noInternetConnection'.tr();

  static String checkNetworkSettings() => 'checkNetworkSettings'.tr();

  static String connectedNoInternet() => 'connectedNoInternet'.tr();

  static String checkNetworkSettingsLater() => 'checkNetworkSettingsLater'.tr();

  /// -------------------------------------------------
  static String visitDetails() => 'visitDetails'.tr();

  static String dataSavedSuccessfully() => 'dataSavedSuccessfully'.tr();

  static String date() => 'date'.tr();

  static String visitStatus() => 'visitStatus'.tr();

  static String newStatus() => 'newStatus'.tr();

  static String visitContract() => 'visitContract'.tr();

  static String visits() => 'visits'.tr();

  static String previousVisits() => 'previousVisits'.tr();

  static String upcomingVisits() => 'upcomingVisits'.tr();

  static String confirmContractCancel() => 'confirmContractCancel'.tr();

  static String server_key() => 'server_key'.tr();

  static String contractDetails() => 'contractDetails'.tr();

  static String password() => 'password'.tr();

  static String contractNumber() => 'contractNumber'.tr();

  static String amount() => 'amount'.tr();

  static String requestDate() => 'requestDate'.tr();

  static String active() => 'active'.tr();

  static String expired() => 'expired'.tr();

  static String password_weak() => 'password_weak'.tr();

  static String contracts() => 'contracts'.tr();

  static String password_must_contain() => 'password_must_contain'.tr();

  static String search() => 'search'.tr();

  static String soonSubtitle() => 'soonSubtitle'.tr();

  static String confirm() => 'confirm'.tr();

  static String pick_file_source() => 'pick_file_source'.tr();

  static String gallery() => 'gallery'.tr();

  static String camera() => 'camera'.tr();

  static String skip() => 'skip'.tr();

  static String alert() => 'alert'.tr();

  static String splash_title_1() => 'splash_title_1'.tr();

  static String splash_title_2() => 'splash_title_2'.tr();

  static String splash_title_3() => 'splash_title_3'.tr();

  static String splash_sub_title_1() => 'splash_sub_title_1'.tr();

  static String splash_sub_title_2() => 'splash_sub_title_2'.tr();

  static String splash_sub_title_3() => 'splash_sub_title_3'.tr();

  static String login_page_subtitle() => 'login_page_subtitle'.tr();

  static String phone_number() => 'phone_number'.tr();

  static String continuee() => 'continuee'.tr();

  static String terms_hint() => 'terms_hint'.tr();

  static String terms_and_conditions() => 'terms_and_conditions'.tr();

  static String agree() => 'agree'.tr();

  static String soon() => 'soon'.tr();

  static String confirm_register() => 'confirm_register'.tr();

  static String confirmation_code_sent_to_number() =>
      'confirmation_code_sent_to_number'.tr();

  static String confirm_code() => 'confirm_code'.tr();

  static String write_name() => 'write_name'.tr();

  static String create_account() => "create_account".tr();

  static String searchInCountries() => "country".tr();

  static String terms_and_condition_content() =>
      "terms_and_condition_content".tr();

  static String about_to_finish() => 'about_to_finish'.tr();

  static String enter_name_to_continue() => 'enter_name_to_continue'.tr();

  static String didnt_receive_code() => 'didnt_receive_code'.tr();

  static String resend_code() => 'resend_code'.tr();

  static String emptyPhoneNumber() => 'emptyPhoneNumber'.tr();

  static String generalUnvaildPhoneNumber() => 'unvaildPhoneNumber'.tr();

  static String otbIsEmpty() => 'otbEmptyValue'.tr();

  static String egyptUnvaildPhoneNumber() =>
      'EgyptPhoneNumberValidMassage'.tr();

  static String home() => 'home'.tr();

  static String aboutPrivacy() => 'aboutPrivacy'.tr();

  static String askForHelpMassage() => 'askForHelpMassage'.tr();

  static String askForHelpTitle() => 'askForHelpTitle'.tr();

  static String chat() => 'chat'.tr();

  static String addPerson() => 'addPerson'.tr();

  static String mySettings() => 'mySettings'.tr();

  static String searchHintText() => 'searchHintText'.tr();

  static String aiTitle() => 'aiTitle'.tr();

  static String chatExample() => 'chatExample'.tr();

  static String sendMassageHint() => 'sendMassageHint'.tr();

  static String send() => 'send'.tr();

  static String addPerson2() => 'addPerson2'.tr();

  static String contactInfoForProposedPerson() =>
      'contactInfoForProposedPerson'.tr();

  static String addContactFormExample() => 'addContactFormExample'.tr();

  static String personName() => 'personName'.tr();

  static String phoneNumber() => 'phoneNumber'.tr();

  static String male() => 'male'.tr();

  static String byDays() => 'byDays'.tr();

  static String byMonths() => 'byMonths'.tr();

  static String female() => 'female'.tr();

  static String placeOfBirth() => 'placeOfBirth'.tr();

  static String placeOfWork() => 'placeOfWork'.tr();

  static String noteAboutPerson() => 'noteAboutPerson'.tr();

  static String noteAboutPersonExample() => 'noteAboutPersonExample'.tr();

  static String whatDoYouWork() => 'whatDoYouWork'.tr();

  static String wordsYouCanEasilyCommunicateWith() =>
      'wordsYouCanEasilyCommunicateWith'.tr();

  static String wordsYouCanEasilyCommunicateWithExample() =>
      'wordsYouCanEasilyCommunicateWithExample'.tr();

  static String second() => 'second'.tr();

  static String dismiss() => 'dismiss'.tr();

  static String add() => 'add'.tr();

  static String writeYourSearchWords() => 'writeYourSearchWord'.tr();

  static String appName() => 'appName'.tr();

  static String youCanShareYourContactsTile() =>
      'youCanShareYourContactsTile'.tr();

  static String shareMyContacts() => 'shareMyContacts'.tr();

  static String areYouSureToShareYourContacts() =>
      'areYouSureToShareYourContacts'.tr();

  static String shareContactsDialogSubtitle() =>
      'shareContactsDialogSubtitle'.tr();

  static String dontWanna() => 'iDontWant'.tr();

  static String yesShare() => 'yesShare'.tr();

  static String noCancel() => 'noCancel'.tr();

  static String cancel() => 'cancel'.tr();

  static String filter() => 'filter'.tr();

  static String welcome() => 'welcome'.tr();

  static String aboutApp() => 'aboutApp'.tr();

  static String shareApp() => 'shareApp'.tr();

  static String friendYouShareWith() => 'friendYouShareWith'.tr();

  static String noSearchResult() => 'noSearchResult'.tr();

  static String forBetterSearchResultMassage() =>
      'forBetterSearchResultMassage'.tr();

  static String pleaseAcceptTermsAndConditions() =>
      'acceptTermsAndConditions'.tr();

  static String lastUpdate() => 'lastUpdate'.tr();

  static String aboutAppDescription() => 'aboutAppDescription'.tr();

  static String callUs() => 'call_us'.tr();

  static String rate_app() => 'rateApp'.tr();

  static String update_contacts_message() => 'update_contacts_message'.tr();

  static String update() => 'update'.tr();

  static String another_time() => 'another_time'.tr();

  static String emptyName() => 'emptyUserName'.tr();

  static String loginErrorMassage() => 'loginErrorMassage'.tr();

  static String updateImageMessage() => 'updateImageMessage'.tr();

  static String genderValidationMassageNew() => 'genderValidateMassage'.tr();

  static String placeOfBirthValidateMassage() =>
      'placeOfBirthValidateMassage'.tr();

  static String placeOfWorkValidateMassage() =>
      'placeOfWorkValidateMassage'.tr();

  static String notesValidationMassage() => 'notesValidationMassage'.tr();

  static String emptyNationality() => 'emptyNationality'.tr();

  static String emptyIdNumber() => 'emptyIdNumber'.tr();

  static String wordsToCommunicateValidationMassage() =>
      'wordsToCommunicateValidationMassage'.tr();

  static String jobValidationMassage() => 'jobValidationMassage'.tr();

  static String addSuccessfullMassage() => 'addSuccessfullyAdd'.tr();

  static String shareSuccessfullMassage() => 'shareSuccessfullyAdd'.tr();

  static String categories() => "categories".tr();

  static String countryLabel() => 'countryLabel'.tr();

  static String noName() => 'noName'.tr();

  static String noCity() => 'noCity'.tr();

  static String noPlaceOfWork() => 'noPlaceOfWork'.tr();

  static String accessDenied() => 'accessDenied'.tr();

  static String searchIsEmpty() => 'searchIsEmpty'.tr();

  static String saveAndUpdateAnotherContact() =>
      'saveAndUpdateAnotherContact'.tr();

  static String SaveOnlyTheCurrent() => 'saveOnlyTheCurrent'.tr();

  static String saveEditedData() => 'saveEditedData'.tr();

  static String logoutTitle() => 'logoutTitle'.tr();

  static String logoutSubtitle() => 'logoutSubtitle'.tr();

  static String areYouSureAboutDeleting() => 'areYouSureAboutSave'.tr();

  static String yes() => 'yes'.tr();

  static String no() => 'no'.tr();

  static String noPlaceOfBirth() => 'noPlaceOfBirth'.tr();

  static String noJob() => 'noJob'.tr();

  static String delete() => 'delete'.tr();

  static String selectImageFromGallery() => 'selectImageFromGallery'.tr();

  static String selectImage() => 'selectImage'.tr();

  static String profileHasNoImags() => 'profileHasNoImags'.tr();

  static String city() => 'city'.tr();

  static String reset() => 'reset'.tr();

  static String verificationFailed() => 'verificationFailed'.tr();

  static String changeLang() => 'changeLang'.tr();

  static String englishLanguage() => 'english'.tr();

  static String arabicLanguage() => 'arabic'.tr();

  static String noImageSelected() => 'noImageSelected'.tr();

  static String uploadImage() => 'uploadImage'.tr();

  static String apply() => 'apply'.tr();

  static String clear() => 'clear'.tr();

  static String emptyShareContracts() => 'emptyShareContracts'.tr();

  static String toShareClickHere() => 'toShareClickHere'.tr();

  static String pleaseShareContracts() => 'pleaseShareContracts'.tr();

  static String uploadContracts() => 'uploadContracts'.tr();

  static String uploadContractsSuccessfully() =>
      'uploadContractsSuccessfully'.tr();

  static String save() => 'save'.tr();

  static String errorIn() => 'errorIn'.tr();

  static String updateContactsFromPhone() => 'updateContactsFromPhone'.tr();

  static String noContactsToUpdate() => 'noContactsToUpdate'.tr();

  static String resetFilter() => 'resetFilter'.tr();

  static String allContact() => 'allContacts'.tr();

  static String edit() => 'edit'.tr();

  static String deleteAll() => 'deleteAll'.tr();

  static String deleteWarninigMassage() => 'pleaseSelectContactsToDelete'.tr();

  static String sendNotification() => 'sendNotification'.tr();

  static String updateContacts() => 'updateContacts'.tr();

  static String helpYourFriends() => 'helpYourFriends'.tr();

  static String messageIsEmpty() => 'messageIsEmpty'.tr();

  static String reviewUnavailable() => 'reviewUnavailable'.tr();

  static String noReviews() => 'noReviews'.tr();

  static String writeReview() => 'writeReview'.tr();

  static String noReviewMassage() => 'noReviewMassage'.tr();

  static String ok() => 'ok'.tr();

  static String loginToYourAccount() => 'loginToYourAccount'.tr();

  static String enterYourDataToCompleteAuthentication() =>
      'enterYourDataToCompleteAuthentication'.tr();

  static String forgetPassword() => 'forgetPassword'.tr();

  static String dontHaveAnAccount() => 'dontHaveAnAccount'.tr();

  static String userName() => 'userName'.tr();

  static String pleaseEnterEmail() => 'pleaseEnterEmail'.tr();

  static String pleaseEnterValidEmail() => 'pleaseEnterValidEmail'.tr();

  static String invalidIdNumber() => 'invalidIdNumber'.tr();

  static String pleaseSelectGender() => 'pleaseSelectGender'.tr();

  static String editProfile() => 'editProfile'.tr();

  static String IDNumber() => "idNumber".tr();

  static String accountNumber() => "accountNumber".tr();

  static String confirmPassword() => 'confirmPassword'.tr();

  static String notifications() => 'notifications'.tr();

  static String support() => 'support'.tr();

  static String pleaseInsertYourEmailToRestoreYourPassword() =>
      'pleaseInsertYourEmailToRestoreYourPassword'.tr();

  static String insertOtpThatSentToYourEmail() =>
      'insertOtpThatSentToYourEmail'.tr();

  static String otpCode() => 'otpCode'.tr();

  static String registerNow() => 'registerNow'.tr();

  static String loginAsGuest() => 'loginAsGuest'.tr();

  static String contacts() => 'contacts'.tr();

  static String profile() => 'profile'.tr();

  static String myLocation() => 'myLocation'.tr();

  static String servicesPerHour() => 'servicesPerHour'.tr();

  static String period() => 'period'.tr();

  static String morning() => 'morning'.tr();

  static String afternoon() => 'afternoon'.tr();

  static String allDay() => 'allDay'.tr();

  static String nationality() => 'nationality'.tr();

  static String selectVisitDays() => 'selectVisitDays'.tr();

  static String selectDateForFirstVisit() => 'selectDateForFirstVisit'.tr();

  static String selectContractDuration() => 'selectContractDuration'.tr();

  static String numbersOfWorkersForEveryVisit() =>
      'numbersOfWorkersForEveryVisit'.tr();

  static String numbersOfVisitDays() => 'numbersOfVisitDays'.tr();

  static String saturday() => 'saturday'.tr();

  static String sunday() => 'sunday'.tr();

  static String monday() => 'monday'.tr();

  static String tuesday() => 'tuesday'.tr();

  static String wednesday() => 'wednesday'.tr();

  static String thursday() => 'thursday'.tr();

  static String friday() => 'friday'.tr();

  static String choseYourAddress() => 'choseYourAddress'.tr();

  static String addNewAddress() => 'addNewAddress'.tr();

  static String companyName() => 'companyName'.tr();

  static String cost() => 'cost'.tr();

  static String discount() => 'discount'.tr();

  static String tax() => 'tax'.tr();

  static String total() => 'total'.tr();

  static String startDate() => 'startDate'.tr();

  static String address() => 'address'.tr();

  static String chosenDays() => 'chosenDays'.tr();

  static String serviceDetails() => 'serviceDetails'.tr();

  static String paymentDetails() => 'paymentDetails'.tr();

  static String contractDuration() => 'contractDuration'.tr();

  static String numberOfWorkers() => 'numberOfWorkers'.tr();

  static String howManyPerWeek() => 'howManyPerWeek'.tr();

  static String numberOfDailyWorkHours() => 'numberOfDailyWorkHours'.tr();

  static String forwardToPay() => 'forwardToPay'.tr();

  static String doYouWantToSelectThisLocation() =>
      'doYouWantToSelectThisLocation'.tr();

  static String tapOnALocationToGetTheAddress() =>
      'tapOnALocationToGetTheAddress'.tr();

  static String registerNew() => 'registerNew'.tr();

  static String alreadyHaveAnAccount() => 'alreadyHaveAccount'.tr();

  static String verifySentCode() => 'verifySentCode'.tr();

  static String enterSentCode() => 'enterSentCode'.tr();

  static String enterSentCodeToVerify() => 'enterSentCodeToVerify'.tr();

  static String price() => 'price'.tr();

  static String areYouSureAboutReserving() => 'areYouSureAboutReserving'.tr();

  static String bookNow() => 'bookNow'.tr();

  static String reservationSuccess() => 'reservationSuccess'.tr();

  static String signUpInOurApp() => 'signUpInOurApp'.tr();

  static String enterUsernameAndPhoneNumberToRegister() =>
      'enterUsernameAndPhoneNumberToRegister'.tr();

  static String invalidName() => 'invalidName'.tr();

  static String pleaseCheckInternetConnection() =>
      'pleaseCheckInternetConnection'.tr();

  static String noTitle() => 'noTitle'.tr();

  static String noAds() => 'noAds'.tr();

  static String pleaseWait() => 'pleaseWait'.tr();

  static String pleaseSelectDate() => 'pleaseSelectDate'.tr();

  static String pleaseSelectVisitDate() => 'pleaseSelectVisitDate'.tr();

  static String pleaseSelectNationality() => 'pleaseSelectNationality'.tr();

  static String pleaseSelectThePeriod() => 'pleaseSelectThePeriod'.tr();

  static String pleaseSelectAddress() => 'pleaseSelectAddress'.tr();

  static String noVisits() => 'noVisits'.tr();

  static String paymentMethod() => 'paymentMethod'.tr();

  static String cardNumber() => 'cardNumber'.tr();

  static String cardHolderName() => 'cardHolderName'.tr();

  static String cvv() => 'cvv'.tr();

  static String expiryDate() => 'expiryDate'.tr();

  static String enterCardNumber() => 'enterCardNumber'.tr();

  static String invalidCardNumber() => 'invalidCardNumber'.tr();

  static String enterCardHolderName() => 'enterCardHolderName'.tr();

  static String enterCVV() => 'enterCVV'.tr();

  static String invalidCVV() => 'invalidCVV'.tr();

  static String enterExpiryDate() => 'enterExpiryDate'.tr();

  static String invalidExpiryDate() => 'invalidExpiryDate'.tr();

  static String invalidDateFormat() => 'invalidDateFormat'.tr();

  static String payAmount() => 'payAmount'.tr();

  static String noContracts() => 'noContracts'.tr();

  static String noAccountPleaseCreateOne() => 'noAccountPleaseCreateOne'.tr();

  static String doYouWantToCreateAccount() => 'doYouWantToCreateAccount'.tr();

  static String yesIWant() => 'yesIWant'.tr();

  static String unknownNow() => 'unknownNow'.tr();

  static String enableLocationToRegister() => 'enableLocationToRegister'.tr();

  static String unableToLocateYourPosition() =>
      'unableToLocateYourPosition'.tr();

  // ------------------ mutigina's localization ---------------------
  static String onBoardingTitle1() => 'onBoardingTitle1'.tr();

  static String onBoardingDescription1() => 'onBoardingDescription1'.tr();

  static String onBoardingTitle2() => 'onBoardingTitle2'.tr();

  static String currencySAR() => 'currencySAR'.tr();

  static String confirmed() => 'confirmed'.tr();

  static String notConfirmed() => 'notConfirmed'.tr();

  static String mediationServices() => 'mediationServices'.tr();

  static String offers() => 'offers'.tr();

  static String dearCustomer() => 'dearCustomer'.tr();

  static String welcomeToCompany() => 'welcomeToCompany'.tr();

  static String cleaning() => 'cleaning'.tr();

  static String chooseContractDays() => 'chooseContractDays'.tr();

  static String day() => 'day'.tr();

  static String month() => 'month'.tr();

  static String chooseContractMonths() => 'chooseContractMonths'.tr();

  static String abha() => 'abha'.tr();

  static String alAhsa() => 'alAhsa'.tr();

  static String alBaha() => 'alBaha'.tr();

  static String alKharj() => 'alKharj'.tr();

  static String arRass() => 'arRass'.tr();

  static String riyadh() => 'riyadh'.tr();

  static String noWorkers() => 'noWorkers'.tr();

  static String alQassim() => 'alQassim'.tr();

  static String medina() => 'medina'.tr();

  static String chooseCity() => 'chooseCity'.tr();

  static String searchCity() => 'searchCity'.tr();

  static String pleaseSelectCity() => 'pleaseSelectCity'.tr();

  static String packagePrice() => 'packagePrice'.tr();

  static String taxValue() => 'taxValue'.tr();

  static String totalPackagePrice() => 'totalPackagePrice'.tr();

  static String selectContractMonths() => 'selectContractMonths'.tr();

  static String pleaseSelectPrice() => 'pleaseSelectPrice'.tr();

  static String name() => 'name'.tr();

  static String age() => 'age'.tr();

  static String experience() => 'experience'.tr();

  static String salary() => 'salary'.tr();

  static String recruitmentFees() => 'recruitmentFees'.tr();

  static String religion() => 'religion'.tr();

  static String job() => 'job'.tr();

  static String language() => 'language'.tr();

  static String skills() => 'skills'.tr();

  static String failedTitle() => 'failedTitle'.tr();

  static String failedMessage() => 'failedMessage'.tr();

  static String successTitle() => 'successTitle'.tr();

  static String successMessage() => 'successMessage'.tr();

  static String showContract() => 'showContract'.tr();

  static String mutiginaCompany() => 'mutiginaCompany'.tr();

  static String service() => 'service'.tr();

  static String serviceType() => 'serviceType'.tr();

  static String stayForMonth() => 'stayForMonth'.tr();

  static String packageDetails() => 'packageDetails'.tr();

  static String noServices() => 'noServices'.tr();

  static String startDateContract() => 'startDateContract'.tr();

  static String contractStatus() => 'contractStatus'.tr();

  static String startContractDate() => 'startContractDate'.tr();

  static String numberOfVisits() => 'numberOfVisits'.tr();

  static String countOfRemainingVisits() => 'countOfRemainingVisits'.tr();

  static String visit() => 'visit'.tr();

  static String visitDate() => 'visitDate'.tr();
  static String currentContracts() => 'currentContracts'.tr();
  static String viewAll() => 'viewAll'.tr();
  static String services() => 'services'.tr();
  static String myCurrentOrders() => 'myCurrentOrders'.tr();
  static String serviceSystem() => 'serviceSystem'.tr();
  static String cleaningServices() => 'cleaningServices'.tr();
  static String babysitter() => 'babysitter'.tr();
  static String cooking() => 'cooking'.tr();
  static String privateDriver() => 'privateDriver'.tr();
  static String personalCare() => 'personalCare'.tr();
  static String hostingService() => 'hostingService'.tr();
  static String perHour() => 'perHour'.tr();
  static String perDay() => 'perDay'.tr();
  static String perMonth() => 'perMonth'.tr();
  static String remainingDuration() => 'remainingDuration'.tr();
  static String activeContracts() => 'activeContracts'.tr();
  static String previousContracts() => 'previousContracts'.tr();
  static String renewContract() => 'renewContract'.tr();
  static String currentOrders() => 'currentOrders'.tr();
  static String previousOrders() => 'previousOrders'.tr();
  static String myOrders() => 'myOrders'.tr();
  static String viewDetails() => 'viewDetails'.tr();
  static String savedAddresses() => 'savedAddresses'.tr();
  static String deliveryAddresses() => 'deliveryAddresses'.tr();
}
