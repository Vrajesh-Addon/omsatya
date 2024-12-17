import 'dart:convert';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/common_name_response.dart';
import 'package:omsatya/models/complain_machine_response.dart';
import 'package:omsatya/models/sales_person/get_sales_person_by_id_response.dart';
import 'package:omsatya/models/sales_person/in_out_sales_response.dart';
import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';
import 'package:omsatya/models/product_response.dart';
import 'package:omsatya/models/sales_person/sales_favourite_response.dart';
import 'package:omsatya/models/sales_person/sales_person_add_response.dart';
import 'package:omsatya/models/sales_person/sales_person_response.dart';
import 'package:omsatya/models/delete_response.dart';
import 'package:omsatya/models/sales_person/sales_report_response.dart';
import 'package:omsatya/models/sales_person/sales_user_report_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class SalesRepository{
  Future<CommonNameResponse> getArea() async {
    String url = "${AppConfig.baseUrl}/areas";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return commonNameResponseFromJson(response.body);
  }

  Future<CommonNameResponse> getLeadStage() async {
    String url = "${AppConfig.baseUrl}/lead-stage";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return commonNameResponseFromJson(response.body);
  }

  Future<ProductResponse> getAllProduct() async {
    String url = "${AppConfig.baseUrl}/products";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return productResponseFromJson(response.body);
  }

  Future<ProductResponse> getAllSalesProduct() async {
    String url = "${AppConfig.baseUrl}/products-type-salse";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return productResponseFromJson(response.body);
  }

  Future<CommonNameResponse> getServiceType() async {
    String url = "${AppConfig.baseUrl}/service-type";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return commonNameResponseFromJson(response.body);
  }

  Future<ComplainMachineResponse> getMachineDataByParty(int partyId) async {
    String url = "${AppConfig.baseUrl}/machine-detail-by-part-id/$partyId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return complainMachineResponseFromJson(response.body);
  }

  Future<SalesPersonResponse> getSalesPerson({int? isEmb, int? isCir}) async {
    String url = "${AppConfig.baseUrl}/sales-person-all?is_salse_emb=$isEmb&is_salse_cir=$isCir";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return salesPersonResponseFromJson(response.body);
  }

  Future<SalesPersonAddResponse> addSalesPersonAssign(
  {areaId, productId, leadStageId, salesUId, salesAssignUId, date, time, mobileNo, partyName, address, locationAddress,
  latitude, longitude, remarks, nextDate, nextTime, body, salesId}
      ) async {
    String url;
    if(salesId == null) {
      url = "${AppConfig.baseUrl}/sales-person";
    } else {
      url = "${AppConfig.baseUrl}/sales-person/$salesId";
      body!.addAll({"_method":"PUT"});
    }

    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return salesPersonAddResponseFromJson(response.body);
  }

  Future<LeadSalesPersonResponse> getLeadSalesPerson({String? userId, String? priorityId, String? date, String? closedDate, String? favourite, int? index}) async {
    String url;

    // if(date.isNotEmpty && AppGlobals().isToday(date) && index == 0) {
    //   url = "${AppConfig.baseUrl}/sales-person?date=$date";
    // } else {
    //   url = "${AppConfig.baseUrl}/sales-person";
    // }

    if(userId != null || priorityId != null || ((date != null && date.isNotEmpty) && index == 1) || closedDate != null || favourite != null){
      if(index == 1 && closedDate != null) date = "";
      userId ??= "";
      priorityId ??= "";
      closedDate ??= "";
      favourite ??= "";
      url = "${AppConfig.baseUrl}/assign-salse-person-priority-filter?status_id=$priorityId&sale_assign_user_id=$userId&date=$date&closed_date=$closedDate&favorite=$favourite";
    } else if(date!.isNotEmpty && AppGlobals.isToday(date) && index == 0) {
      url = "${AppConfig.baseUrl}/sales-person?date=$date";
    } else {
      url = "${AppConfig.baseUrl}/sales-person";
    }

    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return leadSalesPersonResponseFromJson(response.body);
  }

  Future<LeadSalesPersonResponse> getSalesLeadFilter({int? userId, int? priorityId}) async {
    String url = "${AppConfig.baseUrl}/sales-person-user-priority-filter/$userId/$priorityId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return leadSalesPersonResponseFromJson(response.body);
  }

  Future<GetSalesPersonByIdResponse> getLeadSalesPersonById({int? id}) async {
    String url = "${AppConfig.baseUrl}/sales-person/$id";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getSalesPersonByIdResponseFromJson(response.body);
  }

  Future<DeleteSalesResponse> deleteSalesDataById({int? id}) async {
    String url = "${AppConfig.baseUrl}/sales-person/$id";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.delete(url: url, header: headerMap);
    return deleteSalesResponseFromJson(response.body);
  }

  Future<SalesFavouriteResponse> favouriteSales({int? salesId, int? favourite}) async {
    final postBody = jsonEncode({
      "id": salesId,
      "favorite": favourite,
    });
    String url = "${AppConfig.baseUrl}/sales-person/favorite";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return salesFavouriteResponseFromJson(response.body);
  }

  Future<SalesReportResponse> getSalesReport({String? date}) async {
    String url = "${AppConfig.baseUrl}/sales-lead/group-wise-sales-lead?date=$date";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return salesReportResponseFromJson(response.body);
  }

  Future<SalesUserReportResponse> getSalesUserReport({String? date, String? userID}) async {
    String url = "${AppConfig.baseUrl}/sales-lead/user-wise-sales-lead?date=$date&sale_user_id=$userID";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return salesUserReportResponseFromJson(response.body);
  }

  Future<InOutSalesResponse> getSalesInResponse({
    int? id,
    String? inAddress,
    String? inDateTime,
  }) async {
    var body = jsonEncode({
      "id": id,
      "in_address": inAddress,
      "in_date_time": inDateTime,
      // "in_address": inDateTime!.toIso8601String(),
    });
    String url = "${AppConfig.baseUrl}/sales-person/in-out";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return inOutSalesResponseFromJson(response.body);
  }

  Future<InOutSalesResponse> getSalesOutResponse({
    // String? id,
    // String? outAddress,
    // String? outDateTime,
    // String? timeDuration,
    // int? statusId,
    // String? comment,
    body,
  }) async {
    // var body = jsonEncode({
    //   "id": id,
    //   "out_date_time": outAddress,
    //   "out_address": outDateTime,
    //   "time_duration": outDateTime,
    //   "status_id": statusId,
    //   "comment": statusId,
    // });
    String url = "${AppConfig.baseUrl}/sales-person/in-out";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return inOutSalesResponseFromJson(response.body);
  }
}