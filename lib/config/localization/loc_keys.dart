// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:rasikh/config/localization/lang_repo.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';

abstract class Loc {
  static void switchLanguage(BuildContext context) {
    Locale currentLocale = context.locale;

    if (currentLocale.languageCode == 'en') {
      context.setLocale(const Locale('ar'));
      getIt<LangRepo>().setLang("ar", context);
    } else {
      context.setLocale(const Locale('en'));
      getIt<LangRepo>().setLang("en", context);
    }
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
  static String homeGreeting() => 'homeGreeting'.tr();
  static String howCanWeHelpYou() => 'howCanWeHelpYou'.tr();
  static String noAdsCurrently() => 'noAdsCurrently'.tr();
  static String professionalLegalConsultations() => 'professionalLegalConsultations'.tr();
  static String legalConsultationsBrief() => 'legalConsultationsBrief'.tr();
  static String consultNow() => 'consultNow'.tr();
  static String legalConsultationsDescription() => 'legalConsultationsDescription'.tr();
  static String noInternetConnectionTitle() => 'noInternetConnectionTitle'.tr();
  static String enableMobileDataHint() => 'enableMobileDataHint'.tr();
  static String openWifiSettings() => 'openWifiSettings'.tr();
  static String openMobileData() => 'openMobileData'.tr();
  static String retryingInProgress() => 'retryingInProgress'.tr();
  static String internetConnectionLost() => 'internetConnectionLost'.tr();
  static String checkNetworkAndRetry() => 'checkNetworkAndRetry'.tr();
  static String retryAgain() => 'retryAgain'.tr();
  static String ordinalFirst() => 'ordinalFirst'.tr();
  static String ordinalSecond() => 'ordinalSecond'.tr();
  static String ordinalThird() => 'ordinalThird'.tr();
  static String ordinalFourth() => 'ordinalFourth'.tr();
  static String ordinalFifth() => 'ordinalFifth'.tr();
  static String ordinalSixth() => 'ordinalSixth'.tr();
  static String ordinalSeventh() => 'ordinalSeventh'.tr();
  static String ordinalEighth() => 'ordinalEighth'.tr();
  static String ordinalNinth() => 'ordinalNinth'.tr();
  static String ordinalTenth() => 'ordinalTenth'.tr();
  static String ordinalTwentieth() => 'ordinalTwentieth'.tr();
  static String ordinalThirtieth() => 'ordinalThirtieth'.tr();
  static String ordinalFortieth() => 'ordinalFortieth'.tr();
  static String ordinalFiftieth() => 'ordinalFiftieth'.tr();
  static String ordinalSixtieth() => 'ordinalSixtieth'.tr();
  static String ordinalSeventieth() => 'ordinalSeventieth'.tr();
  static String ordinalEightieth() => 'ordinalEightieth'.tr();
  static String ordinalNinetieth() => 'ordinalNinetieth'.tr();
  static String ordinalHundredth() => 'ordinalHundredth'.tr();
  static String ordinalEleventh() => 'ordinalEleventh'.tr();
  static String ordinalTeen(Object? value) => 'ordinalTeen'.tr(namedArgs: {'value': '$value'});
  static String ordinalCompound(Object? value, Object? value2) => 'ordinalCompound'.tr(namedArgs: {'value': '$value', 'value2': '$value2'});
  static String ordinalOne() => 'ordinalOne'.tr();
  static String sessionExpiredPleaseLogin() => 'sessionExpiredPleaseLogin'.tr();
  static String filterLabel() => 'filterLabel'.tr();
  static String dearCustomerLabel() => 'dearCustomerLabel'.tr();
  static String pleaseLoginToAccessServices() => 'pleaseLoginToAccessServices'.tr();
  static String congratulations() => 'congratulations'.tr();
  static String personalDataSavedSuccessfully() => 'personalDataSavedSuccessfully'.tr();
  static String unexpectedError() => 'unexpectedError'.tr();
  static String searchHint() => 'searchHint'.tr();
  static String noResultsFound() => 'noResultsFound'.tr();
  static String pleaseEnterEmailAddress() => 'pleaseEnterEmailAddress'.tr();
  static String pleaseEnterValidEmailAddress() => 'pleaseEnterValidEmailAddress'.tr();
  static String passwordInvalidOrEmpty() => 'passwordInvalidOrEmpty'.tr();
  static String passwordsDoNotMatch() => 'passwordsDoNotMatch'.tr();
  static String passwordRequirements() => 'passwordRequirements'.tr();
  static String pleaseEnterMobileNumber() => 'pleaseEnterMobileNumber'.tr();
  static String invalidSaudiMobileNumber() => 'invalidSaudiMobileNumber'.tr();
  static String nationalIdOrIqamaNumber() => 'nationalIdOrIqamaNumber'.tr();
  static String pleaseEnterNationalIdOrIqama() => 'pleaseEnterNationalIdOrIqama'.tr();
  static String nationalIdIqamaLengthRule() => 'nationalIdIqamaLengthRule'.tr();
  static String registerAsUser() => 'registerAsUser'.tr();
  static String registerAsUserSubtitle() => 'registerAsUserSubtitle'.tr();
  static String registerAsLawyer() => 'registerAsLawyer'.tr();
  static String registerAsLawyerSubtitle() => 'registerAsLawyerSubtitle'.tr();
  static String chooseAccountType() => 'chooseAccountType'.tr();
  static String chooseAccountTypeSubtitle() => 'chooseAccountTypeSubtitle'.tr();
  static String versionCheckReadFailed() => 'versionCheckReadFailed'.tr();
  static String unableToOpenStore() => 'unableToOpenStore'.tr();
  static String appUpdateRequired() => 'appUpdateRequired'.tr();
  static String newUpdateAvailable() => 'newUpdateAvailable'.tr();
  static String pleaseUpdateToContinue() => 'pleaseUpdateToContinue'.tr();
  static String optionalUpdateAvailable() => 'optionalUpdateAvailable'.tr();
  static String newVersionLabel(Object? latestVersion) => 'newVersionLabel'.tr(namedArgs: {'latestVersion': '$latestVersion'});
  static String updateNow() => 'updateNow'.tr();
  static String later() => 'later'.tr();
  static String pleaseEnterPhoneNumber() => 'pleaseEnterPhoneNumber'.tr();
  static String pleaseEnterFullVerificationCode() => 'pleaseEnterFullVerificationCode'.tr();
  static String loginToYourAccountTitle() => 'loginToYourAccountTitle'.tr();
  static String createNewAccount() => 'createNewAccount'.tr();
  static String enterPhoneToLogin() => 'enterPhoneToLogin'.tr();
  static String enterPhoneToRegister() => 'enterPhoneToRegister'.tr();
  static String invalidPhoneNumber() => 'invalidPhoneNumber'.tr();
  static String signIn() => 'signIn'.tr();
  static String alreadyHaveAccountQuestion() => 'alreadyHaveAccountQuestion'.tr();
  static String createAccount() => 'createAccount'.tr();
  static String loginAction() => 'loginAction'.tr();
  static String byRegisteringYou() => 'byRegisteringYou'.tr();
  static String agreeToTermsOfService() => 'agreeToTermsOfService'.tr();
  static String andDataProcessingAgreementLeading() => 'andDataProcessingAgreementLeading'.tr();
  static String otpTimerSeconds(Object? m, Object? s) => 'otpTimerSeconds'.tr(namedArgs: {'m': '$m', 's': '$s'});
  static String verificationCode() => 'verificationCode'.tr();
  static String verificationCodeSentTo(Object? value) => 'verificationCodeSentTo'.tr(namedArgs: {'value': '$value'});
  static String changeNumber() => 'changeNumber'.tr();
  static String resendCode() => 'resendCode'.tr();
  static String resendCodeAfter() => 'resendCodeAfter'.tr();
  static String dearUserCongratulations(Object? value) => 'dearUserCongratulations'.tr(namedArgs: {'value': '$value'});
  static String theLawyer() => 'theLawyer'.tr();
  static String theClient() => 'theClient'.tr();
  static String accountReadyRedirecting() => 'accountReadyRedirecting'.tr();
  static String navHome() => 'navHome'.tr();
  static String myConsultations() => 'myConsultations'.tr();
  static String myAppointments() => 'myAppointments'.tr();
  static String myAccount() => 'myAccount'.tr();
  static String unableToLoadNotifications() => 'unableToLoadNotifications'.tr();
  static String noNotifications() => 'noNotifications'.tr();
  static String notificationsEmptyMessage() => 'notificationsEmptyMessage'.tr();
  static String unableToReadNotificationsCount() => 'unableToReadNotificationsCount'.tr();
  static String sliderOffersDescription() => 'sliderOffersDescription'.tr();
  static String startNow() => 'startNow'.tr();
  static String onboardingPrivacyTitle() => 'onboardingPrivacyTitle'.tr();
  static String onboardingPrivacyDescription() => 'onboardingPrivacyDescription'.tr();
  static String onboardingConsultationsTitle() => 'onboardingConsultationsTitle'.tr();
  static String onboardingConsultationsDescription() => 'onboardingConsultationsDescription'.tr();
  static String onboardingPaymentTitle() => 'onboardingPaymentTitle'.tr();
  static String onboardingPaymentDescription() => 'onboardingPaymentDescription'.tr();
  static String lawFirmData() => 'lawFirmData'.tr();
  static String lawFirmDataSubtitle() => 'lawFirmDataSubtitle'.tr();
  static String authorizedPersonName() => 'authorizedPersonName'.tr();
  static String commercialRegisterNumber() => 'commercialRegisterNumber'.tr();
  static String enterCommercialRegisterNumber() => 'enterCommercialRegisterNumber'.tr();
  static String completeRegistration() => 'completeRegistration'.tr();
  static String consultationRescheduledSuccessfully() => 'consultationRescheduledSuccessfully'.tr();
  static String consultationCancelledSuccessfully() => 'consultationCancelledSuccessfully'.tr();
  static String ratingSentSuccessfully() => 'ratingSentSuccessfully'.tr();
  static String unableToLoadConsultations() => 'unableToLoadConsultations'.tr();
  static String noConsultationsWithStatus(Object? label) => 'noConsultationsWithStatus'.tr(namedArgs: {'label': '$label'});
  static String noConsultationsInCategory() => 'noConsultationsInCategory'.tr();
  static String noConsultations() => 'noConsultations'.tr();
  static String filterByWithColon() => 'filterByWithColon'.tr();
  static String instantConsultation() => 'instantConsultation'.tr();
  static String scheduledConsultation() => 'scheduledConsultation'.tr();
  static String writtenConsultation() => 'writtenConsultation'.tr();
  static String pmLong() => 'pmLong'.tr();
  static String amLong() => 'amLong'.tr();
  static String durationMinutesShort(Object? durationMin) => 'durationMinutesShort'.tr(namedArgs: {'durationMin': '$durationMin'});
  static String completePayment() => 'completePayment'.tr();
  static String enterSession() => 'enterSession'.tr();
  static String viewSummary() => 'viewSummary'.tr();
  static String addRating() => 'addRating'.tr();
  static String viewDispute() => 'viewDispute'.tr();
  static String confirmCancellation() => 'confirmCancellation'.tr();
  static String cancelAppointmentConfirmation() => 'cancelAppointmentConfirmation'.tr();
  static String sessionStartsIn() => 'sessionStartsIn'.tr();
  static String reschedule() => 'reschedule'.tr();
  static String paymentDeadlineExpired() => 'paymentDeadlineExpired'.tr();
  static String awaitingPaymentToConfirm() => 'awaitingPaymentToConfirm'.tr();
  static String amAlt() => 'amAlt'.tr();
  static String chooseNewDateTimeForConsultation() => 'chooseNewDateTimeForConsultation'.tr();
  static String chooseDate() => 'chooseDate'.tr();
  static String timeLabel() => 'timeLabel'.tr();
  static String chooseTime() => 'chooseTime'.tr();
  static String confirmReschedule() => 'confirmReschedule'.tr();
  static String rateYourExperience() => 'rateYourExperience'.tr();
  static String ratingReflectsSatisfaction() => 'ratingReflectsSatisfaction'.tr();
  static String howWasYourExperienceTellUs() => 'howWasYourExperienceTellUs'.tr();
  static String writeHereAlt() => 'writeHereAlt'.tr();
  static String sendNow() => 'sendNow'.tr();
  static String instantConsultationAlt() => 'instantConsultationAlt'.tr();
  static String writtenConsultationAlt() => 'writtenConsultationAlt'.tr();
  static String scheduledConsultationAlt() => 'scheduledConsultationAlt'.tr();
  static String unknown() => 'unknown'.tr();
  static String disputeNumberLabel(Object? disputeNumber) => 'disputeNumberLabel'.tr(namedArgs: {'disputeNumber': '$disputeNumber'});
  static String disputeReason() => 'disputeReason'.tr();
  static String disputeDetails() => 'disputeDetails'.tr();
  static String disputeStatus() => 'disputeStatus'.tr();
  static String decisionTaken() => 'decisionTaken'.tr();
  static String done() => 'done'.tr();
  static String statusOpen() => 'statusOpen'.tr();
  static String underReview() => 'underReview'.tr();
  static String statusClosed() => 'statusClosed'.tr();
  static String disputeResolvedForLawyer() => 'disputeResolvedForLawyer'.tr();
  static String disputeResolvedForClient() => 'disputeResolvedForClient'.tr();
  static String startTime() => 'startTime'.tr();
  static String sessionDurationAlt() => 'sessionDurationAlt'.tr();
  static String filterBy() => 'filterBy'.tr();
  static String applyFilter() => 'applyFilter'.tr();
  static String consultationDetailsAlt() => 'consultationDetailsAlt'.tr();
  static String pmLongLeading() => 'pmLongLeading'.tr();
  static String amLongLeading() => 'amLongLeading'.tr();
  static String specialization() => 'specialization'.tr();
  static String consultationTitle() => 'consultationTitle'.tr();
  static String consultationDescription() => 'consultationDescription'.tr();
  static String sessionSummary() => 'sessionSummary'.tr();
  static String timeAndPrice() => 'timeAndPrice'.tr();
  static String startDateLabel() => 'startDateLabel'.tr();
  static String duration() => 'duration'.tr();
  static String durationMinutesAbbr(Object? durationMin) => 'durationMinutesAbbr'.tr(namedArgs: {'durationMin': '$durationMin'});
  static String totalPrice() => 'totalPrice'.tr();
  static String voiceNote() => 'voiceNote'.tr();
  static String attachments() => 'attachments'.tr();
  static String unableToPlayAudio() => 'unableToPlayAudio'.tr();
  static String videoLabel() => 'videoLabel'.tr();
  static String audioLabel() => 'audioLabel'.tr();
  static String imageLabel() => 'imageLabel'.tr();
  static String fileLabel() => 'fileLabel'.tr();
  static String attachmentNumber(Object? value) => 'attachmentNumber'.tr(namedArgs: {'value': '$value'});
  static String join() => 'join'.tr();
  static String nextSessionAppointment() => 'nextSessionAppointment'.tr();
  static String buttonEnabledWhenSessionStarts() => 'buttonEnabledWhenSessionStarts'.tr();
  static String disputeOpenedOnConsultation() => 'disputeOpenedOnConsultation'.tr();
  static String viewDisputeDetails() => 'viewDisputeDetails'.tr();
  static String ratingSendFailedIncompleteData() => 'ratingSendFailedIncompleteData'.tr();
  static String all() => 'all'.tr();
  static String pending() => 'pending'.tr();
  static String statusActive() => 'statusActive'.tr();
  static String statusUpcoming() => 'statusUpcoming'.tr();
  static String statusCompleted() => 'statusCompleted'.tr();
  static String statusCancelled() => 'statusCancelled'.tr();
  static String statusDisputes() => 'statusDisputes'.tr();
  static String authTokenNotFoundPleaseLogin() => 'authTokenNotFoundPleaseLogin'.tr();
  static String idImage() => 'idImage'.tr();
  static String licenseImage() => 'licenseImage'.tr();
  static String commercialRegisterImage() => 'commercialRegisterImage'.tr();
  static String practiceLicense() => 'practiceLicense'.tr();
  static String practiceLicenseSubtitle() => 'practiceLicenseSubtitle'.tr();
  static String idNumberLabel() => 'idNumberLabel'.tr();
  static String enterIdNumber() => 'enterIdNumber'.tr();
  static String licenseNumberLabel() => 'licenseNumberLabel'.tr();
  static String enterLicenseNumber() => 'enterLicenseNumber'.tr();
  static String commercialRegisterNumberLabel() => 'commercialRegisterNumberLabel'.tr();
  static String pleaseAttachRequiredImagesRequired() => 'pleaseAttachRequiredImagesRequired'.tr();
  static String pleaseUploadIdImage() => 'pleaseUploadIdImage'.tr();
  static String pleaseUploadPracticeLicenseImage() => 'pleaseUploadPracticeLicenseImage'.tr();
  static String pleaseUploadCommercialRegisterImage() => 'pleaseUploadCommercialRegisterImage'.tr();
  static String personalData() => 'personalData'.tr();
  static String personalDataSubtitle() => 'personalDataSubtitle'.tr();
  static String fullNameAlt() => 'fullNameAlt'.tr();
  static String pleaseChooseCity() => 'pleaseChooseCity'.tr();
  static String pleaseChooseCityAlt() => 'pleaseChooseCityAlt'.tr();
  static String agreeToTermsOfServiceTrailing() => 'agreeToTermsOfServiceTrailing'.tr();
  static String andDataProcessingAgreement() => 'andDataProcessingAgreement'.tr();
  static String unableToLoadCities() => 'unableToLoadCities'.tr();
  static String retryShort() => 'retryShort'.tr();
  static String qualificationsAndExperience() => 'qualificationsAndExperience'.tr();
  static String qualificationsSubtitle() => 'qualificationsSubtitle'.tr();
  static String pleaseWriteQualifications() => 'pleaseWriteQualifications'.tr();
  static String tenYearsHint() => 'tenYearsHint'.tr();
  static String yearsOfExperienceRequired() => 'yearsOfExperienceRequired'.tr();
  static String pleaseWriteYearsOfExperience() => 'pleaseWriteYearsOfExperience'.tr();
  static String pleaseEnterValidYears() => 'pleaseEnterValidYears'.tr();
  static String specializations() => 'specializations'.tr();
  static String specializationsSubtitle() => 'specializationsSubtitle'.tr();
  static String noSpecializationsAvailable() => 'noSpecializationsAvailable'.tr();
  static String thanksAccountUnderReview() => 'thanksAccountUnderReview'.tr();
  static String sendForReview() => 'sendForReview'.tr();
  static String dearLawyerCongratulations() => 'dearLawyerCongratulations'.tr();
  static String requestReceivedWillReview() => 'requestReceivedWillReview'.tr();
  static String pleaseSelectAtLeastOneDay() => 'pleaseSelectAtLeastOneDay'.tr();
  static String pleaseSetStartAndEndTime() => 'pleaseSetStartAndEndTime'.tr();
  static String endTimeMustBeAfterStart() => 'endTimeMustBeAfterStart'.tr();
  static String reviewAppointmentDetailsAnytime() => 'reviewAppointmentDetailsAnytime'.tr();
  static String editWorkAppointment() => 'editWorkAppointment'.tr();
  static String addWorkAppointment() => 'addWorkAppointment'.tr();
  static String chooseDayOrDaysRequired() => 'chooseDayOrDaysRequired'.tr();
  static String requiredInParentheses() => 'requiredInParentheses'.tr();
  static String saving() => 'saving'.tr();
  static String saveChanges() => 'saveChanges'.tr();
  static String saveAppointment() => 'saveAppointment'.tr();
  static String appointmentDeletedSuccessfully() => 'appointmentDeletedSuccessfully'.tr();
  static String noWorkAppointmentsYet() => 'noWorkAppointmentsYet'.tr();
  static String addWorkAppointmentHint() => 'addWorkAppointmentHint'.tr();
  static String workAppointments() => 'workAppointments'.tr();
  static String workAppointmentsSubtitle() => 'workAppointmentsSubtitle'.tr();
  static String deleteAppointment() => 'deleteAppointment'.tr();
  static String deleteAppointmentConfirmation() => 'deleteAppointmentConfirmation'.tr();
  static String sessionDurationMinutesLabel(Object? sessionDurationMinutes) => 'sessionDurationMinutesLabel'.tr(namedArgs: {'sessionDurationMinutes': '$sessionDurationMinutes'});
  static String gapMinutesLabel(Object? gapMinutes) => 'gapMinutesLabel'.tr(namedArgs: {'gapMinutes': '$gapMinutes'});
  static String toWord() => 'toWord'.tr();
  static String repeatsWeekly() => 'repeatsWeekly'.tr();
  static String pmShort() => 'pmShort'.tr();
  static String amShort() => 'amShort'.tr();
  static String mondayAlt() => 'mondayAlt'.tr();
  static String tuesdayAlt() => 'tuesdayAlt'.tr();
  static String appointmentsCount(Object? length) => 'appointmentsCount'.tr(namedArgs: {'length': '$length'});
  static String chooseStartTimeRequired() => 'chooseStartTimeRequired'.tr();
  static String chooseEndTimeRequired() => 'chooseEndTimeRequired'.tr();
  static String weeklyRepeatQuestion() => 'weeklyRepeatQuestion'.tr();
  static String instantConsultationAcceptedSuccessfully() => 'instantConsultationAcceptedSuccessfully'.tr();
  static String writtenConsultationAcceptedSuccessfully() => 'writtenConsultationAcceptedSuccessfully'.tr();
  static String acceptInstantConsultationFailed(Object? message) => 'acceptInstantConsultationFailed'.tr(namedArgs: {'message': '$message'});
  static String acceptWrittenConsultationFailed(Object? message) => 'acceptWrittenConsultationFailed'.tr(namedArgs: {'message': '$message'});
  static String newConsultations() => 'newConsultations'.tr();
  static String errorOccurredWithMessage(Object? message) => 'errorOccurredWithMessage'.tr(namedArgs: {'message': '$message'});
  static String noNewInstantOrWrittenConsultations() => 'noNewInstantOrWrittenConsultations'.tr();
  static String nearestThreeAppointmentsToday() => 'nearestThreeAppointmentsToday'.tr();
  static String noUpcomingAppointmentsToday() => 'noUpcomingAppointmentsToday'.tr();
  static String lastFinancialTransaction() => 'lastFinancialTransaction'.tr();
  static String noFinancialTransactions() => 'noFinancialTransactions'.tr();
  static String detailsWithValue(Object? details) => 'detailsWithValue'.tr(namedArgs: {'details': '$details'});
  static String clientWithName(Object? fullName) => 'clientWithName'.tr(namedArgs: {'fullName': '$fullName'});
  static String phoneWithValue(Object? phone) => 'phoneWithValue'.tr(namedArgs: {'phone': '$phone'});
  static String cityWithValue(Object? city) => 'cityWithValue'.tr(namedArgs: {'city': '$city'});
  static String durationWithMinutes(Object? durationMin) => 'durationWithMinutes'.tr(namedArgs: {'durationMin': '$durationMin'});
  static String priceWithSar(Object? value) => 'priceWithSar'.tr(namedArgs: {'value': '$value'});
  static String close() => 'close'.tr();
  static String availabilityStatus() => 'availabilityStatus'.tr();
  static String availableNowForInstantConsultations() => 'availableNowForInstantConsultations'.tr();
  static String available() => 'available'.tr();
  static String notAvailable() => 'notAvailable'.tr();
  static String writtenConsultationLabel() => 'writtenConsultationLabel'.tr();
  static String accept() => 'accept'.tr();
  static String detailsLabel() => 'detailsLabel'.tr();
  static String minutesAgo(Object? inMinutes) => 'minutesAgo'.tr(namedArgs: {'inMinutes': '$inMinutes'});
  static String hoursAgo(Object? inHours) => 'hoursAgo'.tr(namedArgs: {'inHours': '$inHours'});
  static String pmPlain() => 'pmPlain'.tr();
  static String amPlain() => 'amPlain'.tr();
  static String amountRiyal(Object? amount) => 'amountRiyal'.tr(namedArgs: {'amount': '$amount'});
  static String verificationCodeSentToPhone() => 'verificationCodeSentToPhone'.tr();
  static String replySentSuccessfully() => 'replySentSuccessfully'.tr();
  static String reportSentSuccessfully() => 'reportSentSuccessfully'.tr();
  static String pleaseEnterIban() => 'pleaseEnterIban'.tr();
  static String ibanMinLength() => 'ibanMinLength'.tr();
  static String ibanMaxLength() => 'ibanMaxLength'.tr();
  static String ibanMustStartWithSa() => 'ibanMustStartWithSa'.tr();
  static String ibanDigitsOnlyAfterSa() => 'ibanDigitsOnlyAfterSa'.tr();
  static String bankAccountAddedSuccessfully() => 'bankAccountAddedSuccessfully'.tr();
  static String addBankAccountFailed() => 'addBankAccountFailed'.tr();
  static String addBankAccount() => 'addBankAccount'.tr();
  static String bankNameRequired() => 'bankNameRequired'.tr();
  static String bankNameExample() => 'bankNameExample'.tr();
  static String pleaseEnterBankName() => 'pleaseEnterBankName'.tr();
  static String accountHolderNameRequired() => 'accountHolderNameRequired'.tr();
  static String fullNameLabel() => 'fullNameLabel'.tr();
  static String pleaseEnterAccountHolderName() => 'pleaseEnterAccountHolderName'.tr();
  static String ibanRequired() => 'ibanRequired'.tr();
  static String ibanHelperText() => 'ibanHelperText'.tr();
  static String addAccount() => 'addAccount'.tr();
  static String helpCenter() => 'helpCenter'.tr();
  static String faq() => 'faq'.tr();
  static String contactUs() => 'contactUs'.tr();
  static String termsOfUse() => 'termsOfUse'.tr();
  static String privacyPolicy() => 'privacyPolicy'.tr();
  static String dataUpdatedSuccessfully() => 'dataUpdatedSuccessfully'.tr();
  static String fullNameShort() => 'fullNameShort'.tr();
  static String chooseCityLabel() => 'chooseCityLabel'.tr();
  static String yearsOfExperience() => 'yearsOfExperience'.tr();
  static String pleaseEnterYearsOfExperience() => 'pleaseEnterYearsOfExperience'.tr();
  static String aboutYou() => 'aboutYou'.tr();
  static String writeHere() => 'writeHere'.tr();
  static String jeddah() => 'jeddah'.tr();
  static String dammam() => 'dammam'.tr();
  static String mecca() => 'mecca'.tr();
  static String myProfile() => 'myProfile'.tr();
  static String editPersonalData() => 'editPersonalData'.tr();
  static String editPracticeLicense() => 'editPracticeLicense'.tr();
  static String editMobileNumber() => 'editMobileNumber'.tr();
  static String deleteAccount() => 'deleteAccount'.tr();
  static String confirmDeletion() => 'confirmDeletion'.tr();
  static String deleteAccountWarning() => 'deleteAccountWarning'.tr();
  static String myRatings() => 'myRatings'.tr();
  static String latestRatings() => 'latestRatings'.tr();
  static String noRatingsYetLeading() => 'noRatingsYetLeading'.tr();
  static String clientRatingsWillAppearHere() => 'clientRatingsWillAppearHere'.tr();
  static String noRatingsYet() => 'noRatingsYet'.tr();
  static String basedOnOneRating() => 'basedOnOneRating'.tr();
  static String basedOnTwoRatings() => 'basedOnTwoRatings'.tr();
  static String basedOnFewRatings(Object? n) => 'basedOnFewRatings'.tr(namedArgs: {'n': '$n'});
  static String basedOnManyRatings(Object? n) => 'basedOnManyRatings'.tr(namedArgs: {'n': '$n'});
  static String settings() => 'settings'.tr();
  static String mySpecializations() => 'mySpecializations'.tr();
  static String wallet() => 'wallet'.tr();
  static String financialTransactions() => 'financialTransactions'.tr();
  static String helpCenterAlt() => 'helpCenterAlt'.tr();
  static String logout() => 'logout'.tr();
  static String logoutConfirmationAlt() => 'logoutConfirmationAlt'.tr();
  static String joinDateLabel(Object? day, Object? month, Object? year) => 'joinDateLabel'.tr(namedArgs: {'day': '$day', 'month': '$month', 'year': '$year'});
  static String verified() => 'verified'.tr();
  static String joinDateEmpty() => 'joinDateEmpty'.tr();
  static String specializationsSavedSuccessfully() => 'specializationsSavedSuccessfully'.tr();
  static String chooseSpecialization() => 'chooseSpecialization'.tr();
  static String mainSpecialization() => 'mainSpecialization'.tr();
  static String mainSpecializations() => 'mainSpecializations'.tr();
  static String subCountSuffix(Object? subCount) => 'subCountSuffix'.tr(namedArgs: {'subCount': '$subCount'});
  static String chooseSubSpecializationForEachMain() => 'chooseSubSpecializationForEachMain'.tr();
  static String searchSpecializationHint() => 'searchSpecializationHint'.tr();
  static String subSpecializationsSelected(Object? subSelectedCount) => 'subSpecializationsSelected'.tr(namedArgs: {'subSelectedCount': '$subSelectedCount'});
  static String subSpecializationsCount(Object? subSpecializationsCount) => 'subSpecializationsCount'.tr(namedArgs: {'subSpecializationsCount': '$subSpecializationsCount'});
  static String chooseSubSpecialization() => 'chooseSubSpecialization'.tr();
  static String canChooseMoreThanOneSpecialization() => 'canChooseMoreThanOneSpecialization'.tr();
  static String accountNowUnderReview() => 'accountNowUnderReview'.tr();
  static String editLicenseReviewNotice() => 'editLicenseReviewNotice'.tr();
  static String idNumber() => 'idNumber'.tr();
  static String licenseNumber() => 'licenseNumber'.tr();
  static String pleaseEnterLicenseNumber() => 'pleaseEnterLicenseNumber'.tr();
  static String licenseExpiryDate() => 'licenseExpiryDate'.tr();
  static String pleaseEnterCommercialRegisterNumber() => 'pleaseEnterCommercialRegisterNumber'.tr();
  static String pleaseAttachRequiredImages() => 'pleaseAttachRequiredImages'.tr();
  static String bulletIdImage() => 'bulletIdImage'.tr();
  static String bulletLicenseImage() => 'bulletLicenseImage'.tr();
  static String bulletCommercialRegisterImage() => 'bulletCommercialRegisterImage'.tr();
  static String idShort() => 'idShort'.tr();
  static String licenseShort() => 'licenseShort'.tr();
  static String registerShort() => 'registerShort'.tr();
  static String dayMonthYearPlaceholder() => 'dayMonthYearPlaceholder'.tr();
  static String noImage() => 'noImage'.tr();
  static String loadFailed() => 'loadFailed'.tr();
  static String ratingDetails() => 'ratingDetails'.tr();
  static String excellentRating() => 'excellentRating'.tr();
  static String veryGoodRating() => 'veryGoodRating'.tr();
  static String goodRating() => 'goodRating'.tr();
  static String acceptableRating() => 'acceptableRating'.tr();
  static String poorRating() => 'poorRating'.tr();
  static String clientComment() => 'clientComment'.tr();
  static String clientLeftNoComment() => 'clientLeftNoComment'.tr();
  static String consultationInfo() => 'consultationInfo'.tr();
  static String consultationNumber() => 'consultationNumber'.tr();
  static String type() => 'type'.tr();
  static String status() => 'status'.tr();
  static String viewConsultation() => 'viewConsultation'.tr();
  static String yourReplyPublished() => 'yourReplyPublished'.tr();
  static String yourReplyPendingApproval() => 'yourReplyPendingApproval'.tr();
  static String addReply() => 'addReply'.tr();
  static String replyPublishedAfterReview() => 'replyPublishedAfterReview'.tr();
  static String writeYourReplyHere() => 'writeYourReplyHere'.tr();
  static String sendReply() => 'sendReply'.tr();
  static String pleaseEnterAmount() => 'pleaseEnterAmount'.tr();
  static String pleaseEnterValidAmount() => 'pleaseEnterValidAmount'.tr();
  static String minimumDepositIs(Object? minSar) => 'minimumDepositIs'.tr(namedArgs: {'minSar': '$minSar'});
  static String maximumDepositIs(Object? maxSar) => 'maximumDepositIs'.tr(namedArgs: {'maxSar': '$maxSar'});
  static String unableToOpenPaymentLink() => 'unableToOpenPaymentLink'.tr();
  static String depositRequestFailed() => 'depositRequestFailed'.tr();
  static String depositBalance() => 'depositBalance'.tr();
  static String depositBalanceToWallet() => 'depositBalanceToWallet'.tr();
  static String depositLimitsLabel(Object? minSar, Object? maxSar) => 'depositLimitsLabel'.tr(namedArgs: {'minSar': '$minSar', 'maxSar': '$maxSar'});
  static String loadingLimits() => 'loadingLimits'.tr();
  static String depositAmountRequired() => 'depositAmountRequired'.tr();
  static String redirectToPaymentGatewayForDeposit() => 'redirectToPaymentGatewayForDeposit'.tr();
  static String deposit() => 'deposit'.tr();
  static String electronicWallet() => 'electronicWallet'.tr();
  static String addNewAccount() => 'addNewAccount'.tr();
  static String updateBankAccountsFailed() => 'updateBankAccountsFailed'.tr();
  static String recentTransactions() => 'recentTransactions'.tr();
  static String noTransactions() => 'noTransactions'.tr();
  static String bankAccounts() => 'bankAccounts'.tr();
  static String currentBalance() => 'currentBalance'.tr();
  static String availableBalance() => 'availableBalance'.tr();
  static String pendingBalance() => 'pendingBalance'.tr();
  static String topUpWallet() => 'topUpWallet'.tr();
  static String withdrawRequest() => 'withdrawRequest'.tr();
  static String paid() => 'paid'.tr();
  static String refunded() => 'refunded'.tr();
  static String processing() => 'processing'.tr();
  static String paymentFailed() => 'paymentFailed'.tr();
  static String transferred() => 'transferred'.tr();
  static String adjusted() => 'adjusted'.tr();
  static String consultationEarning() => 'consultationEarning'.tr();
  static String disputeDeposit() => 'disputeDeposit'.tr();
  static String disputeHold() => 'disputeHold'.tr();
  static String disputeRelease() => 'disputeRelease'.tr();
  static String disputeLoss() => 'disputeLoss'.tr();
  static String earningsAccrual() => 'earningsAccrual'.tr();
  static String earningsRelease() => 'earningsRelease'.tr();
  static String earningsReversal() => 'earningsReversal'.tr();
  static String commissionPenalty() => 'commissionPenalty'.tr();
  static String noBankAccounts() => 'noBankAccounts'.tr();
  static String defaultLabel() => 'defaultLabel'.tr();
  static String deleteBankAccountConfirmation(Object? bankName) => 'deleteBankAccountConfirmation'.tr(namedArgs: {'bankName': '$bankName'});
  static String bankAccountUpdatedSuccessfully() => 'bankAccountUpdatedSuccessfully'.tr();
  static String updateBankAccountFailed() => 'updateBankAccountFailed'.tr();
  static String editBankAccount() => 'editBankAccount'.tr();
  static String bankName() => 'bankName'.tr();
  static String enterBankName() => 'enterBankName'.tr();
  static String accountHolderName() => 'accountHolderName'.tr();
  static String enterAccountHolderName() => 'enterAccountHolderName'.tr();
  static String iban() => 'iban'.tr();
  static String ibanExactLength() => 'ibanExactLength'.tr();
  static String pleaseChooseBankAccount() => 'pleaseChooseBankAccount'.tr();
  static String minimumWithdrawalIs(Object? minWithdrawalAmount) => 'minimumWithdrawalIs'.tr(namedArgs: {'minWithdrawalAmount': '$minWithdrawalAmount'});
  static String insufficientBalanceForWithdrawal() => 'insufficientBalanceForWithdrawal'.tr();
  static String withdrawRequestSentSuccessfully() => 'withdrawRequestSentSuccessfully'.tr();
  static String withdrawRequestFailed() => 'withdrawRequestFailed'.tr();
  static String availableBalanceForWithdrawal() => 'availableBalanceForWithdrawal'.tr();
  static String chooseBankAccountRequired() => 'chooseBankAccountRequired'.tr();
  static String noBankAccountsDefined() => 'noBankAccountsDefined'.tr();
  static String addBankAccountPlus() => 'addBankAccountPlus'.tr();
  static String chooseAccount() => 'chooseAccount'.tr();
  static String withdrawAmountRequired() => 'withdrawAmountRequired'.tr();
  static String confirmWithdrawal() => 'confirmWithdrawal'.tr();
  static String reportComment() => 'reportComment'.tr();
  static String reportMessage() => 'reportMessage'.tr();
  static String sendAction() => 'sendAction'.tr();
  static String january() => 'january'.tr();
  static String february() => 'february'.tr();
  static String march() => 'march'.tr();
  static String april() => 'april'.tr();
  static String may() => 'may'.tr();
  static String june() => 'june'.tr();
  static String july() => 'july'.tr();
  static String august() => 'august'.tr();
  static String september() => 'september'.tr();
  static String october() => 'october'.tr();
  static String november() => 'november'.tr();
  static String december() => 'december'.tr();
  static String failedToLoadAppointments() => 'failedToLoadAppointments'.tr();
  static String unableToConnectToServer() => 'unableToConnectToServer'.tr();
  static String noAvailableAppointments() => 'noAvailableAppointments'.tr();
  static String noRemainingAppointmentsToday() => 'noRemainingAppointmentsToday'.tr();
  static String noAvailableAppointmentsThisDay() => 'noAvailableAppointmentsThisDay'.tr();
  static String bookAppointment() => 'bookAppointment'.tr();
  static String errorCreatingConsultation() => 'errorCreatingConsultation'.tr();
  static String chooseSessionDateRequired() => 'chooseSessionDateRequired'.tr();
  static String consultationTimeRequired() => 'consultationTimeRequired'.tr();
  static String unsupportedMessageType() => 'unsupportedMessageType'.tr();
  static String messagingServerConnectionFailed(Object? description) => 'messagingServerConnectionFailed'.tr(namedArgs: {'description': '$description'});
  static String unexpectedErrorWithDetails(Object? e) => 'unexpectedErrorWithDetails'.tr(namedArgs: {'e': '$e'});
  static String sessionInactiveCannotSend() => 'sessionInactiveCannotSend'.tr();
  static String sendMessageFailed(Object? description) => 'sendMessageFailed'.tr(namedArgs: {'description': '$description'});
  static String imageTooLarge(Object? value) => 'imageTooLarge'.tr(namedArgs: {'value': '$value'});
  static String fileTooLarge(Object? value) => 'fileTooLarge'.tr(namedArgs: {'value': '$value'});
  static String sendAttachmentFailed(Object? description) => 'sendAttachmentFailed'.tr(namedArgs: {'description': '$description'});
  static String downloadAttachmentFailed() => 'downloadAttachmentFailed'.tr();
  static String unableToOpenFileSaved() => 'unableToOpenFileSaved'.tr();
  static String unableToOpenFile() => 'unableToOpenFile'.tr();
  static String resendFailed(Object? description) => 'resendFailed'.tr(namedArgs: {'description': '$description'});
  static String noMessagesYetStartChat() => 'noMessagesYetStartChat'.tr();
  static String consultant() => 'consultant'.tr();
  static String connecting() => 'connecting'.tr();
  static String connected() => 'connected'.tr();
  static String takePhoto() => 'takePhoto'.tr();
  static String chooseFromGallery() => 'chooseFromGallery'.tr();
  static String sendFile() => 'sendFile'.tr();
  static String writeMessageHere() => 'writeMessageHere'.tr();
  static String sessionInactive() => 'sessionInactive'.tr();
  static String pleaseEnterMessage() => 'pleaseEnterMessage'.tr();
  static String goBack() => 'goBack'.tr();
  static String preparingChat() => 'preparingChat'.tr();
  static String waitingForOtherParty() => 'waitingForOtherParty'.tr();
  static String loadingEllipsis() => 'loadingEllipsis'.tr();
  static String twoMinutesLeftInSession() => 'twoMinutesLeftInSession'.tr();
  static String errorLoadingChat() => 'errorLoadingChat'.tr();
  static String endChat() => 'endChat'.tr();
  static String endChatConfirmation() => 'endChatConfirmation'.tr();
  static String end() => 'end'.tr();
  static String highestRated() => 'highestRated'.tr();
  static String lowestRated() => 'lowestRated'.tr();
  static String mostExperienced() => 'mostExperienced'.tr();
  static String leastExperienced() => 'leastExperienced'.tr();
  static String nameAToZ() => 'nameAToZ'.tr();
  static String nameZToA() => 'nameZToA'.tr();
  static String newest() => 'newest'.tr();
  static String oldest() => 'oldest'.tr();
  static String sortBy() => 'sortBy'.tr();
  static String searchSpecificCity() => 'searchSpecificCity'.tr();
  static String errorConnectingToServer() => 'errorConnectingToServer'.tr();
  static String noResults() => 'noResults'.tr();
  static String noCitiesAvailable() => 'noCitiesAvailable'.tr();
  static String chooseLawyer() => 'chooseLawyer'.tr();
  static String consultationCreatedSuccessfully() => 'consultationCreatedSuccessfully'.tr();
  static String redirectingToPaymentPage() => 'redirectingToPaymentPage'.tr();
  static String searchForSuitableLawyer() => 'searchForSuitableLawyer'.tr();
  static String unableToLoadRecommendedLawyer() => 'unableToLoadRecommendedLawyer'.tr();
  static String noRecommendedLawyerNow() => 'noRecommendedLawyerNow'.tr();
  static String noSuitableLawyerForSpecialization() => 'noSuitableLawyerForSpecialization'.tr();
  static String unableToLoadLawyers() => 'unableToLoadLawyers'.tr();
  static String noLawyersAvailable() => 'noLawyersAvailable'.tr();
  static String tryChangingSearchCriteria() => 'tryChangingSearchCriteria'.tr();
  static String noRecommendedLawyer() => 'noRecommendedLawyer'.tr();
  static String noSuitableLawyerFound() => 'noSuitableLawyerFound'.tr();
  static String noAdditionalLawyers() => 'noAdditionalLawyers'.tr();
  static String recommendedLawyerOnlyOption() => 'recommendedLawyerOnlyOption'.tr();
  static String availableNow() => 'availableNow'.tr();
  static String busy() => 'busy'.tr();
  static String offline() => 'offline'.tr();
  static String bestMatchForRequest() => 'bestMatchForRequest'.tr();
  static String consultationPriceAlt() => 'consultationPriceAlt'.tr();
  static String consultNowAlt() => 'consultNowAlt'.tr();
  static String quickFilterEnforcement() => 'quickFilterEnforcement'.tr();
  static String quickFilterCommercial() => 'quickFilterCommercial'.tr();
  static String quickFilterPersonalStatus() => 'quickFilterPersonalStatus'.tr();
  static String quickFilterTraffic() => 'quickFilterTraffic'.tr();
  static String somethingWentWrong() => 'somethingWentWrong'.tr();
  static String retryAlt() => 'retryAlt'.tr();
  static String tryAdjustingSearchKeywords() => 'tryAdjustingSearchKeywords'.tr();
  static String connectingYouToLawyer() => 'connectingYouToLawyer'.tr();
  static String pleaseWaitWhileConnecting() => 'pleaseWaitWhileConnecting'.tr();
  static String grantMicrophonePermission() => 'grantMicrophonePermission'.tr();
  static String chooseConsultationDurationRequired() => 'chooseConsultationDurationRequired'.tr();
  static String consultationTitleRequired() => 'consultationTitleRequired'.tr();
  static String consultationTitleExample() => 'consultationTitleExample'.tr();
  static String consultationDetailsRequired() => 'consultationDetailsRequired'.tr();
  static String unableToLoadPricingPlans() => 'unableToLoadPricingPlans'.tr();
  static String noPricingPlansAvailable() => 'noPricingPlansAvailable'.tr();
  static String pricingPlansUnavailableTryLater() => 'pricingPlansUnavailableTryLater'.tr();
  static String tapToRecordMaxFiveMinutes() => 'tapToRecordMaxFiveMinutes'.tr();
  static String uploadYourFileHere() => 'uploadYourFileHere'.tr();
  static String allowedFileTypesHint() => 'allowedFileTypesHint'.tr();
  static String chooseFile() => 'chooseFile'.tr();
  static String maxFilesReached() => 'maxFilesReached'.tr();
  static String recordingTapStopToFinish() => 'recordingTapStopToFinish'.tr();
  static String voiceNoteWithIcon() => 'voiceNoteWithIcon'.tr();
  static String durationWithValue(Object? value) => 'durationWithValue'.tr(namedArgs: {'value': '$value'});
  static String chooseConsultationType() => 'chooseConsultationType'.tr();
  static String instantConsultations() => 'instantConsultations'.tr();
  static String instantConsultationsDescription() => 'instantConsultationsDescription'.tr();
  static String writtenConsultations() => 'writtenConsultations'.tr();
  static String writtenConsultationsDescription() => 'writtenConsultationsDescription'.tr();
  static String scheduledConsultations() => 'scheduledConsultations'.tr();
  static String scheduledConsultationsDescription() => 'scheduledConsultationsDescription'.tr();
  static String endSession() => 'endSession'.tr();
  static String openDispute() => 'openDispute'.tr();
  static String rateSession() => 'rateSession'.tr();
  static String backToHome() => 'backToHome'.tr();
  static String requestConfirmed() => 'requestConfirmed'.tr();
  static String requestSentReviewWithin72Hours() => 'requestSentReviewWithin72Hours'.tr();
  static String disputeReasonRequired() => 'disputeReasonRequired'.tr();
  static String writeDisputeReason() => 'writeDisputeReason'.tr();
  static String disputeDetailsRequired() => 'disputeDetailsRequired'.tr();
  static String pleaseFillAllRequiredFields() => 'pleaseFillAllRequiredFields'.tr();
  static String sendDisputeFailed(Object? error) => 'sendDisputeFailed'.tr(namedArgs: {'error': '$error'});
  static String sendNowExclamation() => 'sendNowExclamation'.tr();
  static String rateYourExperienceAlt() => 'rateYourExperienceAlt'.tr();
  static String howWasYourExperienceTellUsAlt() => 'howWasYourExperienceTellUsAlt'.tr();
  static String pleaseChooseRating() => 'pleaseChooseRating'.tr();
  static String sendRatingFailed(Object? error) => 'sendRatingFailed'.tr(namedArgs: {'error': '$error'});
  static String sessionTimeEnded() => 'sessionTimeEnded'.tr();
  static String consultationTimeEnded() => 'consultationTimeEnded'.tr();
  static String lawyerDetails() => 'lawyerDetails'.tr();
  static String createConsultationFailed() => 'createConsultationFailed'.tr();
  static String userLabel() => 'userLabel'.tr();
  static String startsFrom() => 'startsFrom'.tr();
  static String experienceAndQualifications() => 'experienceAndQualifications'.tr();
  static String ratings() => 'ratings'.tr();
  static String ratingsWithCount(Object? totalCount) => 'ratingsWithCount'.tr(namedArgs: {'totalCount': '$totalCount'});
  static String previousExperience() => 'previousExperience'.tr();
  static String noExperienceInfo() => 'noExperienceInfo'.tr();
  static String aboutTheLawyer() => 'aboutTheLawyer'.tr();
  static String noBio() => 'noBio'.tr();
  static String noRegisteredSpecializations() => 'noRegisteredSpecializations'.tr();
  static String noLicenseImage() => 'noLicenseImage'.tr();
  static String bookNowAction() => 'bookNowAction'.tr();
  static String requestConfirmedConnectingLawyer(Object? secondsLeft) => 'requestConfirmedConnectingLawyer'.tr(namedArgs: {'secondsLeft': '$secondsLeft'});
  static String appointmentBookedSuccessfully() => 'appointmentBookedSuccessfully'.tr();
  static String backToHomeAlt() => 'backToHomeAlt'.tr();
  static String okAction() => 'okAction'.tr();
  static String consultationMustBeCreatedFirst() => 'consultationMustBeCreatedFirst'.tr();
  static String errorDuringPayment() => 'errorDuringPayment'.tr();
  static String paymentLinkNotReceived() => 'paymentLinkNotReceived'.tr();
  static String checkingPaymentStatus() => 'checkingPaymentStatus'.tr();
  static String paymentFailedTryAgain() => 'paymentFailedTryAgain'.tr();
  static String errorCheckingPaymentStatus() => 'errorCheckingPaymentStatus'.tr();
  static String processingPayment() => 'processingPayment'.tr();
  static String checkingPaymentStatusMayTakeMinutes() => 'checkingPaymentStatusMayTakeMinutes'.tr();
  static String payment() => 'payment'.tr();
  static String payNowToConfirmAppointment() => 'payNowToConfirmAppointment'.tr();
  static String payNowToStartChat() => 'payNowToStartChat'.tr();
  static String consultationDetails() => 'consultationDetails'.tr();
  static String consultationType() => 'consultationType'.tr();
  static String subSpecialization() => 'subSpecialization'.tr();
  static String listSeparator() => 'listSeparator'.tr();
  static String sessionDate() => 'sessionDate'.tr();
  static String lawyerData() => 'lawyerData'.tr();
  static String nameLabel() => 'nameLabel'.tr();
  static String rating() => 'rating'.tr();
  static String paymentSummary() => 'paymentSummary'.tr();
  static String consultationPrice() => 'consultationPrice'.tr();
  static String myFatoorah() => 'myFatoorah'.tr();
  static String myWallet() => 'myWallet'.tr();
  static String payNow() => 'payNow'.tr();
  static String instantConsultationPlain() => 'instantConsultationPlain'.tr();
  static String microphone() => 'microphone'.tr();
  static String andSeparator() => 'andSeparator'.tr();
  static String permissionRequired() => 'permissionRequired'.tr();
  static String appNeedsPermissions() => 'appNeedsPermissions'.tr();
  static String permissionPermanentlyDenied(Object? permissionNames) => 'permissionPermanentlyDenied'.tr(namedArgs: {'permissionNames': '$permissionNames'});
  static String videoCallPermissionRequired(Object? permissionNames) => 'videoCallPermissionRequired'.tr(namedArgs: {'permissionNames': '$permissionNames'});
  static String openSettings() => 'openSettings'.tr();
  static String allowPermissions() => 'allowPermissions'.tr();
  static String confirmEnd() => 'confirmEnd'.tr();
  static String endSessionNowQuestion() => 'endSessionNowQuestion'.tr();
  static String waitingForLawyerToJoin() => 'waitingForLawyerToJoin'.tr();
  static String reconnectingAttempts(Object? attempts, Object? max) => 'reconnectingAttempts'.tr(namedArgs: {'attempts': '$attempts', 'max': '$max'});
  static String connectionError() => 'connectionError'.tr();
  static String fetchSessionDataFailed(Object? value) => 'fetchSessionDataFailed'.tr(namedArgs: {'value': '$value'});
  static String getChatTokenFailed(Object? value) => 'getChatTokenFailed'.tr(namedArgs: {'value': '$value'});
  static String fetchChatDataFailed(Object? value) => 'fetchChatDataFailed'.tr(namedArgs: {'value': '$value'});
  static String serverConnectionFailed(Object? value) => 'serverConnectionFailed'.tr(namedArgs: {'value': '$value'});
  static String sendSummaryFailed(Object? error) => 'sendSummaryFailed'.tr(namedArgs: {'error': '$error'});
  static String getCallTokenFailed(Object? value) => 'getCallTokenFailed'.tr(namedArgs: {'value': '$value'});
  static String callEngineInitFailed(Object? e) => 'callEngineInitFailed'.tr(namedArgs: {'e': '$e'});
  static String connectionErrorWithCode(Object? err, Object? msg) => 'connectionErrorWithCode'.tr(namedArgs: {'err': '$err', 'msg': '$msg'});
  static String reconnectFailedAfterAttempts(Object? kMaxReconnectAttempts) => 'reconnectFailedAfterAttempts'.tr(namedArgs: {'kMaxReconnectAttempts': '$kMaxReconnectAttempts'});
  static String renewCallTokenFailed() => 'renewCallTokenFailed'.tr();
  static String excellent() => 'excellent'.tr();
  static String good() => 'good'.tr();
  static String weak() => 'weak'.tr();
  static String bad() => 'bad'.tr();
  static String callSummaryMinLength() => 'callSummaryMinLength'.tr();
  static String callSummary() => 'callSummary'.tr();
  static String writeCallSummary() => 'writeCallSummary'.tr();
  static String writeCallSummaryHint() => 'writeCallSummaryHint'.tr();
  static String chooseLawyerAssignmentMethod() => 'chooseLawyerAssignmentMethod'.tr();
  static String recommendTheBest() => 'recommendTheBest'.tr();
  static String iChooseTheLawyer() => 'iChooseTheLawyer'.tr();
  static String durationMinutes(Object? duration) => 'durationMinutes'.tr(namedArgs: {'duration': '$duration'});
  static String writtenConsultationPlain() => 'writtenConsultationPlain'.tr();
  static String scheduledConsultationPlain() => 'scheduledConsultationPlain'.tr();
  static String unableToLoadAppointments() => 'unableToLoadAppointments'.tr();
  static String noAppointmentsWithStatus(Object? value) => 'noAppointmentsWithStatus'.tr(namedArgs: {'value': '$value'});
  static String noAppointmentsInCategory() => 'noAppointmentsInCategory'.tr();
  static String noAppointments() => 'noAppointments'.tr();
  static String statusDisputed() => 'statusDisputed'.tr();
  static String pendingAlt() => 'pendingAlt'.tr();
  static String unknownAlt() => 'unknownAlt'.tr();
  static String attendanceDelay() => 'attendanceDelay'.tr();
  static String sampleDisputeDetails() => 'sampleDisputeDetails'.tr();
  static String appointmentDetails() => 'appointmentDetails'.tr();
  static String sampleLawyerName() => 'sampleLawyerName'.tr();
  static String sampleSpecializationLabel() => 'sampleSpecializationLabel'.tr();
  static String consultationDescriptionLabel() => 'consultationDescriptionLabel'.tr();
  static String sampleLawyerBio() => 'sampleLawyerBio'.tr();
  static String dateTimeAndDuration() => 'dateTimeAndDuration'.tr();
  static String sampleStartTime() => 'sampleStartTime'.tr();
  static String sessionDuration() => 'sessionDuration'.tr();
  static String sampleDuration() => 'sampleDuration'.tr();
  static String pleaseChooseNewAppointmentDate() => 'pleaseChooseNewAppointmentDate'.tr();
  static String pleaseChooseNewAppointmentTime() => 'pleaseChooseNewAppointmentTime'.tr();
  static String newAppointmentMustBeInFuture() => 'newAppointmentMustBeInFuture'.tr();
  static String rescheduledSuccessfully() => 'rescheduledSuccessfully'.tr();
  static String reviewConsultationDetailsAnytime() => 'reviewConsultationDetailsAnytime'.tr();
  static String rescheduleConsultation() => 'rescheduleConsultation'.tr();
  static String chooseNewAppointmentRequired() => 'chooseNewAppointmentRequired'.tr();
  static String currentAppointment() => 'currentAppointment'.tr();
  static String sampleSpecialization() => 'sampleSpecialization'.tr();
  static String sampleStartTimeAlt() => 'sampleStartTimeAlt'.tr();
  static String samplePrice() => 'samplePrice'.tr();
  static String specializationWithValue(Object? specialization) => 'specializationWithValue'.tr(namedArgs: {'specialization': '$specialization'});
  static String suitableLawyerWillBeRecommended() => 'suitableLawyerWillBeRecommended'.tr();
  static String paidPrice() => 'paidPrice'.tr();
  static String bankAccountDeletedSuccessfully() => 'bankAccountDeletedSuccessfully'.tr();
  static String updateData() => 'updateData'.tr();
  static String dataUpdatedSuccessfullyExclamation() => 'dataUpdatedSuccessfullyExclamation'.tr();
  static String sendCode() => 'sendCode'.tr();
  static String verificationCodeSentToPhoneNumber(Object? phone) => 'verificationCodeSentToPhoneNumber'.tr(namedArgs: {'phone': '$phone'});
  static String pleaseEnterVerificationCode() => 'pleaseEnterVerificationCode'.tr();
  static String errorLoadingContactData() => 'errorLoadingContactData'.tr();
  static String contactUsSubtitle() => 'contactUsSubtitle'.tr();
  static String contactViaSupportNumber() => 'contactViaSupportNumber'.tr();
  static String contactViaEmail() => 'contactViaEmail'.tr();
  static String contactViaWhatsapp() => 'contactViaWhatsapp'.tr();
  static String followUsOn(Object? platform) => 'followUsOn'.tr(namedArgs: {'platform': '$platform'});
  static String unableToLoadTransactions() => 'unableToLoadTransactions'.tr();
  static String noTransactionsAlt() => 'noTransactionsAlt'.tr();
  static String noNotes() => 'noNotes'.tr();
  static String transactionDetailsWithColon() => 'transactionDetailsWithColon'.tr();
  static String transactionType() => 'transactionType'.tr();
  static String referenceNumber() => 'referenceNumber'.tr();
  static String dateTime() => 'dateTime'.tr();
  static String balanceBeforeTransaction() => 'balanceBeforeTransaction'.tr();
  static String balanceAfterTransaction() => 'balanceAfterTransaction'.tr();
  static String additionalNotes() => 'additionalNotes'.tr();
  static String saudiArabiaWithCity(Object? city) => 'saudiArabiaWithCity'.tr(namedArgs: {'city': '$city'});
  static String saudiArabiaLabel() => 'saudiArabiaLabel'.tr();
  static String editPersonalDataAlt() => 'editPersonalDataAlt'.tr();
  static String electronicWalletAlt() => 'electronicWalletAlt'.tr();
  static String supportAndHelp() => 'supportAndHelp'.tr();
  static String logoutConfirmation() => 'logoutConfirmation'.tr();
  static String unableToLoadFaqs() => 'unableToLoadFaqs'.tr();
  static String noQuestionsAvailable() => 'noQuestionsAvailable'.tr();
  static String deleteAccountConfirmation() => 'deleteAccountConfirmation'.tr();
  static String termsOfUseAlt() => 'termsOfUseAlt'.tr();
  static String termsOfUseSummary() => 'termsOfUseSummary'.tr();
  static String securityAndCommunication() => 'securityAndCommunication'.tr();
  static String securitySummary() => 'securitySummary'.tr();
  static String privacySummary() => 'privacySummary'.tr();
  static String yourLawyerRatingsWillAppearHere() => 'yourLawyerRatingsWillAppearHere'.tr();
  static String lawyerReplied() => 'lawyerReplied'.tr();
  static String myComment() => 'myComment'.tr();
  static String youLeftNoComment() => 'youLeftNoComment'.tr();
  static String lawyerReply() => 'lawyerReply'.tr();
  static String pleaseChooseCityAlt2() => 'pleaseChooseCityAlt2'.tr();
  static String completeYourProfileTitle() => 'completeYourProfileTitle'.tr();
  static String completeProfileSubtitle() => 'completeProfileSubtitle'.tr();
  static String fullNameAlt2() => 'fullNameAlt2'.tr();
  static String sampleTermsText() => 'sampleTermsText'.tr();
  static String termsAndConditions() => 'termsAndConditions'.tr();
  static String otpDialogTimer(Object? minutes, Object? remainingSeconds) => 'otpDialogTimer'.tr(namedArgs: {'minutes': '$minutes', 'remainingSeconds': '$remainingSeconds'});
  static String verificationCodeSentToLabel() => 'verificationCodeSentToLabel'.tr();
  static String pleaseEnterFullCode() => 'pleaseEnterFullCode'.tr();
  static String casesAndTransactionsDescription(Object? names) => 'casesAndTransactionsDescription'.tr(namedArgs: {'names': '$names'});
  static String chooseSubSpecializationAlt() => 'chooseSubSpecializationAlt'.tr();
  static String madinah() => 'madinah'.tr();
  static String newLabel() => 'newLabel'.tr();
  static String squareText() => 'squareText'.tr();
  static String chooseSpecialtyTitle() => 'chooseSpecialtyTitle'.tr();
  static String mainSpecializationLabel() => 'mainSpecializationLabel'.tr();
  static String chooseMainSpecialization() => 'chooseMainSpecialization'.tr();
  static String lawsuitTypeLabel() => 'lawsuitTypeLabel'.tr();
  static String chooseLawsuitType() => 'chooseLawsuitType'.tr();
  static String searchMainSpecializationHint() => 'searchMainSpecializationHint'.tr();
  static String searchSubSpecializationHint() => 'searchSubSpecializationHint'.tr();
  static String searchLawsuitTypeHint() => 'searchLawsuitTypeHint'.tr();
  static String specializationsEmptyMessage() => 'specializationsEmptyMessage'.tr();
  static String noSubSpecializationsTitle() => 'noSubSpecializationsTitle'.tr();
  static String noSubSpecializationsMessage() => 'noSubSpecializationsMessage'.tr();
  static String noLawsuitTypesTitle() => 'noLawsuitTypesTitle'.tr();
  static String noLawsuitTypesMessage() => 'noLawsuitTypesMessage'.tr();
}
