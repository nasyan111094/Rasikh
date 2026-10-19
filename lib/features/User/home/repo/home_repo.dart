
import 'package:rasikh/core/utils/api/api_handler.dart';

import 'package:dartz/dartz.dart';


import '../../../../config/app_config.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../features/common/Auth/models/auth_model.dart';
import '../models/advertising_response_model.dart';

class HomeRepo {
  HomeRepo();

  Future<Either<String, AdvertismentResponseModel>> getAdvertisingData({
    required VendorType vendorType,
  }) async {
    //String? token = await di<CacheHelper>().get(kUserToken);
    // الوقت الحالي UTC
    final now = DateTime.now() .toLocal();

    // تحويله لصيغة ISO 8601 زي المثال
    final isoString = now.toIso8601String();
    
    // Determine bannerType based on vendor
    final bannerType = vendorType == VendorType.lawyer ? 'lawyer' : 'client';
    
    var requestData = {
      "page": 1,
      "pageSize": 1000,
      "sortColumn": "date",
      "sortColumnDirection": "desc",
      "readDto": {"from": isoString}
    };

    print(requestData.toString());

    final result = await getIt.get<ApiHandler>().dioAdapterBase.get(
          EndPoints.advertismentWithDataBase,
          body: requestData,
          queryParameters: {'bannerType': bannerType},
        );
    if (result.isLeft) {
      return Left(result.left);
    } else {
      AdvertismentResponseModel orderContractsResponseModel =
          AdvertismentResponseModel.fromJson(result.right.data);
      return Right(orderContractsResponseModel);
    }
  }
}
