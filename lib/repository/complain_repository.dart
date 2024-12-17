import 'dart:convert';
import 'dart:io';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/admin_today_report/admin_today_report_response.dart';
import 'package:omsatya/models/all_complain_no_response.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/complain_types_response.dart';
import 'package:omsatya/models/customer_add_response.dart';
import 'package:omsatya/models/get_complain_no_response.dart';
import 'package:omsatya/models/machine_no_response.dart';
import 'package:omsatya/models/party_name_response.dart';
import 'package:omsatya/models/previous_complain_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:http/http.dart' as http;
import 'package:omsatya/widgets/general_widgets.dart';

class ComplainRepository{

  Future<ComplainStatusResponse> getComplainStatusResponse() async {
    String url = "${AppConfig.baseUrl}/statuses";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return complainStatusResponseFromJson(response.body);
  }

  Future<PartyNameResponse> getPartyNameResponse() async {
    String url = "${AppConfig.baseUrl}/parties";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return partyNameResponseFromJson(response.body);
  }

  Future<PartyNameResponse> getAllPartyResponse() async {
    String url = "${AppConfig.baseUrl}/party";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return partyNameResponseFromJson(response.body);
  }

  Future<ComplainResponse> getComplainListResponse(
      {int? statusId, dynamic partyId, int? engineerId, int? isAssign, int? page, int? complainNo}) async {
    String url;
    String endPoints;
    if(AppGlobals.user!.roles!.first.id == 2){
      endPoints = "complaints";
      if (partyId == null && engineerId == null && complainNo == null) {
        url = "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&page=$page";
      } else if (partyId != null && engineerId == null && complainNo == null) {
        url =
            "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&party_id=$partyId&page=$page";
      } else if (engineerId != null && partyId == null && complainNo == null) {
        url =
            "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&engineer_id=$engineerId&page=$page";
      } else if (complainNo != null && partyId == null && engineerId == null) {
        url =
            "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&complaint_no=$complainNo&page=$page";
      } else if (complainNo != null && engineerId != null && partyId == null) {
        url =
            "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&engineer_id=$engineerId&complaint_no=$complainNo&page=$page";
      } else if (complainNo != null && partyId != null && engineerId == null) {
        url =
            "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&party_id=$partyId&complaint_no=$complainNo&page=$page";
      } else {
        url =
            "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&is_assigned=$isAssign&party_id=$partyId&engineer_id=$engineerId&complaint_no=$complainNo&page=$page";
      }
    } else {
      endPoints = "engineer-complaints";
      if(partyId == null && complainNo == null) {
        url = "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&party_id=&complaint_no=&page=$page";
      } else if (partyId == null && complainNo != null){
        url = "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&party_id=&complaint_no=$complainNo&c&page=$page";
      } else if (partyId != null && complainNo == null) {
        url = "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&party_id=$partyId&complaint_no=&page=$page";
      }  else {
        url = "${AppConfig.baseUrl}/$endPoints?status_id=$statusId&party_id=$partyId&complaint_no=$complainNo&page=$page";
      }
    }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return complainResponseFromJson(response.body);
  }

  Future<PreviousComplainResponse> getPreviousComplain(int complainId) async {
    String url = "${AppConfig.baseUrl}/get-complaint/$complainId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return previousComplainResponseFromJson(response.body);
  }

  Future<ComplainTypesResponse> getComplainTypesResponse() async {
    String url = "${AppConfig.baseUrl}/complaint-types";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return complainTypesFromJson(response.body);
  }

  Future<MachineNoResponse> getMachineNoResponse(int partyId) async {
    var postBody = jsonEncode({
      "party_id": partyId,
    });
    String url = "${AppConfig.baseUrl}/machine-number";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return machineNoFromJson(response.body);
  }

  Future<GetComplainNoResponse> generateComplainNo() async {
    String url = "${AppConfig.baseUrl}/complaint-number";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getComplainNoResponseFromJson(response.body);
  }

  Future<AllComplainNoResponse> getAllComplainNo() async {
    String url = "${AppConfig.baseUrl}/complaint-no";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return allComplainNoResponseFromJson(response.body);
  }

  Future<ComplainAddResponse> getComplainAddResponse({partyId, date, time, complainTypeId, int? jointEngineerId, salesEntryId, serviceTypeId,
    statusId, productId, remarks, File? image, File? video, File? audio, complainNo, engineerId}) async {

    String url;

    if(AppGlobals.user!.roles!.first.id == 3){
      url = "${AppConfig.baseUrl}/customer-complaint-store";
    } else {
      url = "${AppConfig.baseUrl}/complaint-store";
    }

    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields.addAll({
      'party_id': partyId,
      'date': date,
      'time': time,
      'complaint_no': complainNo,
      'complaint_type_id': complainTypeId,
      'sales_entry_id': salesEntryId,
      'service_type_id': serviceTypeId,
      'status_id': '1',
      'product_id': productId,
      'is_customer_complaint': AppGlobals.user!.roles!.first.id == 3 ? "1" : "0",
    });
    if(engineerId != null) {
      request.fields.addAll({'engineer_id': engineerId.toString()});
    }
    if(jointEngineerId != null){
      request.fields.addAll({'jointengg': jointEngineerId.toString()});
    }
    if(image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    if(video != null) {
      request.files.add(await http.MultipartFile.fromPath('video', video.path));
    }
    if(audio != null) {
      request.files.add(await http.MultipartFile.fromPath('audio', audio.path));
    }

    request.headers.addAll(headerMap);

    http.StreamedResponse streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    showMessage("Url ==> ${request.url}");
    showMessage("Header ==> ${request.headers}");
    showMessage("Request ==> ${request.files}");
    showMessage("Request ==> ${request.fields}");
    showMessage("body ==> ${response.body}");

   return complainAddResponseFromJson(response.body);
  }

  Future<AdminTodayReportResponse> getTodayReportData(String date) async {
    String url = "${AppConfig.baseUrl}/report-today/$date";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return adminTodayReportResponseFromJson(response.body);
  }
}