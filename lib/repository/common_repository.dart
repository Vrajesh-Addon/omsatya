import 'dart:convert';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/report/ap_details_response.dart';
import 'package:omsatya/models/report/today_machine_expiry_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';

class CommonRepository{

  Future<ApDetailsResponse> getApDetailsData({int? month, String? userId, int? page}) async {
    Map<String, String> postBody = {
      "month": month.toString(),
      "page": page.toString(),
    };
    if (userId != null) {
      postBody.addAll({"engineer_id": userId});
    }
    String url = "${AppConfig.baseUrl}/ap-details";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return apDetailsResponseFromJson(response.body);
  }

  Future<TodayMachineExpiryResponse> getTodayMachineExpiryData(String? partyId) async {
    partyId ??= "";
    var postBody = jsonEncode({
      "party_id": partyId
    });
    String url = "${AppConfig.baseUrl}/today-expiry";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return todayMachineExpiryResponseFromJson(response.body);
  }
}