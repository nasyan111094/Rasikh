
import 'package:rasikh/core/utils/api/api_handler.dart';

import 'package:dartz/dartz.dart';


import '../../../../config/app_config.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../models/advertising_response_model.dart';

class HomeRepo {
  HomeRepo();

  Future<Either<String, AdvertismentResponseModel>> getAdvertisingData() async {
    //String? token = await di<CacheHelper>().get(kUserToken);
    // الوقت الحالي UTC
    final now = DateTime.now().toUtc();

    // تحويله لصيغة ISO 8601 زي المثال
    final isoString = now.toIso8601String();
    var requestData = {
      "page": 1,
      "pageSize": 1000,
      "sortColumn": "date",
      "sortColumnDirection": "desc",
      "readDto": {"from": isoString}
    };

    print(requestData.toString());

    final result = await getIt.get<ApiHandler>().dioAdapterBase.post(
          EndPoints.advertismentWithDataBase,
          body: requestData,
        );
    if (result.isLeft) {
      return Left(result.left.toString());
    } else {
      AdvertismentResponseModel orderContractsResponseModel =
          AdvertismentResponseModel.fromJson(result.right.data);
      return Right(orderContractsResponseModel);
    }
  }
}
