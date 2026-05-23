abstract class AppConfig {
  static String baseUrl = "http://89.117.60.202:3050/api/v1/";
  static String baseImgUrl = "http://89.117.60.202:3050";

  static String version = 'v1/';
}

///firebase
const firebaseApiKey = 'AIzaSyAiJDY15P4hRNQcZKn8fIekoA9COcUIeDU';
const firebaseAppId = '1:1051843546353:android:b820677e74be5beafc2d50';
const firebaseMessagingSenderId = '1051843546353';
const firebaseMessagingProjectId = 'test-c8634';

abstract class EndPoints {
























  /// Login
  static String loginWithPhone = 'user-management/login/otp';
  static String postponed_contract = 'OrderStatusHistory';
  static String loginWithNationalId = 'user-management/login';
  static String refreshToken = 'user-management/refresh-token';
  static String downloadContract = 'ContractReport/GetMotquenaContract';
  static String checkLoginOtp = 'user-management/confirm-login/otp';
  static String registerFirstStep = 'user-management/register';
  static String initializeRegisterationOtp = "OTPAuthentication/InitializeOTP";
  static String checkRegisterationOtp = "OTPAuthentication/ConfirmRegisterOTP";
  static String homeData = "home-page/GetHomePageData";
  static String allServices = "Services/GetAll";
  static String getUserProfile = "User/ClientUserProfile";
  // auth
  static String loginWithDataBase = 'user-management/login';
  static String profileDataWithDataBase = 'clients/profile';
  static String serviceContract({required String serviceId}) =>
      'OrderReport/GetServiceContract/$serviceId';
  static String contractsWithDataBase = 'Order/GetOrderContracts';
  static String advertismentWithDataBase = 'content/public/banners';
  static String userCurrentOrders = 'Order/GetUserCurrentOrder';
  static String userEndOrders = 'Order/GetUserEndOrder';
  static String nextVisits = 'Order/GetUserEndOrder';

  static String order = 'Order';

  static String updateProfileWithDataBase = 'clients/profile';

  static String updateUserWithDataBase = 'profile';
/////////////////////////////////////////////////////////
  //shifts
  static String getShifts = 'Shift/GetAll';
/////////////////////////////
  //nationalities
  static String getNationalities = 'Nationality/GetAll';
  static String getAllNationalityWorkers = 'Worker/GetAll';
  static String orderMedService = 'Order';
  /////////////////////////////////////////////////
  // servicePerHour
  static String getServicePerHourNearCompanies({
    required String serviceId,
    required int distance,
    required String addressId,
  }) =>
      'ServicePriceHead/GetNearbyServices?SystemOfServiceId=$serviceId&DistanceInKilometers=$distance';
  ///////////////////////////////////////////////
  //order
  static String addOrder = 'Order';
  static String addContracts = 'my-contacts';

  static String updateContracts({required int id}) => 'my-contacts/$id';

  static String countries = 'location/countries';

  static String placeOfWOrk = 'work-categories';

  static String uploadContact = 'my-contacts/upload';

  static String unCompletedContact = 'my-contacts/uncompleted';

  static String getProfile = "profile";

  static String getRecentlyProfileImages = "profile-photo-history";

  static String aboutApp = "about-app";
  static String mediationSubServices = "TypeOfService/GetAll";

  static String getFriendConnections = "connections";

  static String chatWithAi = "assistant";

  static String deleteFriendConnections(int id) => "connections/$id";

  static String deleteManyContacts({required List<int> contactIds}) {
    return 'my-contacts/destroy/many?${Uri(
      queryParameters: {
        for (var i = 0; i < contactIds.length; i++)
          'ids[$i]': contactIds[i].toString()
      },
    )}';
  }

  //////////////////////////////
  //////////////UserAddres

  static String getAllAddress = 'Addres/GetByUserId';
  static String getAllCountries = 'Country/GetAll';
  static String getAllCities = 'City/GetAll';
  static String getAllDistricts = 'District/GetAll';
  static String listValuePortTypes = 'ListValuePropertyTypes/GetAll';

  static String getAllWorkers = 'Worker/GetAll';

  /*static String getAllAddress(String userId) => 'Addres/GetByUserId/$userId';*/
  static String addAddress = 'Addres';

  static String code = ''; // todo
  static String logout = ''; // todo
  static String updateDeviceToken = ''; // todo

  static String getSystemServiceEndPoint = "SystemOfService/GetAll";

  static String updatePhoneNumberInitializeOtp = "User/update-phone-number/initialize-otp";

  static String updatePhoneNumberConfirmOtp = "User/update-phone-number/confirm-otp";

  static String deleteContractsWithDataBase({required String contractId}) =>
      'Order?id=$contractId';
}
