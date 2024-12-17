import 'dart:convert';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/dashboard_response.dart';
import 'package:omsatya/models/holiday_response.dart';
import 'package:omsatya/models/roles/roles_response.dart';
import 'package:omsatya/models/roles/roles_user_response.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/widgets/general_widgets.dart';

import 'api_request.dart';

class DashboardRepository {

  Future<DashboardResponse> getDashboardResponse(int roleId) async {
    String url;
    if(roleId == 4){
      url = "${AppConfig.baseUrl}/engineer-dashboard";
    } else {
      url = "${AppConfig.baseUrl}/adminDashboard";
    }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return dashboardResponseFromJson(response.body);
  }

  Future<DashboardResponse> getCustomerDashboardResponse(int partyId) async {
    String url = "${AppConfig.baseUrl}/dashboard-complain-counter/$partyId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return dashboardResponseFromJson(response.body);
  }

  Future<HolidayResponse> getHolidayResponse(String date) async {
    var postBody = jsonEncode({
      "date": date,
    });
    String url = "${AppConfig.baseUrl}/check-holiday";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return holidayResponseFromJson(response.body);
  }

  Future<RolesResponse> getRolesResponse() async {
    String url = "${AppConfig.baseUrl}/roles";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return rolesResponseFromJson(response.body);
  }

  Future<RolesUserResponse> getRolesUserData({String? name, String? isEmb, String? isCir}) async {
    String? url;
    if(isEmb != null && isCir != null) {
      showMessage("nfhbfbsjhfds ==> $isEmb ==== $isCir");
      url = "${AppConfig.baseUrl}/role-wise-users?role_name=$name&is_emb=$isEmb&is_cir=$isCir";
    } else {
      url = "${AppConfig.baseUrl}/role-wise-users?role_name=$name";
    }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return rolesUserResponseFromJson(response.body);
  }
}
