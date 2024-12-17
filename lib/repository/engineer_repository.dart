import 'dart:convert';
import 'dart:io';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/assign_engineer_response.dart';
import 'package:omsatya/models/engineer_in_out_response.dart';
import 'package:omsatya/models/engineer_response.dart';
import 'package:omsatya/models/report/free_engineer_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:omsatya/widgets/general_widgets.dart';

class EngineerRepository {
  Future<EngineerInOutResponse> getEngineerInResponse({
    int? complainId,
    String? inDate,
    String? inTime,
    int? statusId,
    int? actualComplainTypeId,
    String? address,
    File? image, File? video, File? audio,
  }) async {

    String url = "${AppConfig.baseUrl}/engineer-in/$complainId";

    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields.addAll({
      "engineer_in_date": inDate!,
      "engineer_in_time": inTime!,
      "status_id": statusId.toString(),
      "engineer_in_address": address!,
      "complaint_type_id": actualComplainTypeId.toString(),
      "engineer_complaint_id": actualComplainTypeId.toString(),
    });
    if(image != null) {
      request.files.add(await http.MultipartFile.fromPath('engineer_image', image.path));
    }
    if(video != null) {
      request.files.add(await http.MultipartFile.fromPath('engineer_video', video.path));
    }
    if(audio != null) {
      request.files.add(await http.MultipartFile.fromPath('engineer_audio', audio.path));
    }

    request.headers.addAll(headerMap);

    showMessage("Url ==> ${request.url}");
    showMessage("Header ==> ${request.headers}");
    showMessage("Request ==> ${request.files}");
    showMessage("Request ==> ${request.fields}");

    http.StreamedResponse streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    showMessage("body ==> ${response.body}");

    return engineerInOutResponseFromJson(response.body);
  }

  Future<EngineerInOutResponse> getEngineerOutResponse({
    int? complainId,
    String? outDate,
    String? outTime,
    int? statusId,
    String? remarks,
    String? address,
    String? timeDuration,
  }) async {
    var body = jsonEncode({
      "status_id": statusId,
      "engineer_out_date": outDate,
      "engineer_out_time": outTime,
      "remarks": remarks,
      "engineer_out_address": address,
      "engineer_time_duration": timeDuration,
    });
    String url = "${AppConfig.baseUrl}/engineer-out/$complainId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return engineerInOutResponseFromJson(response.body);
  }

  Future<EngineerResponse> getAllEngineerResponse() async {
    String url = "${AppConfig.baseUrl}/engineers";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return engineerResponseFromJson(response.body);
  }

  Future<AssignEngineerResponse> getAssignToEngineerResponse({int? complainId, List<EngineerDataResponse>? lstSelectedEngineer}) async {
    var body = jsonEncode({
      "engineer_id": lstSelectedEngineer!.first.id,
      "id": complainId,
      "jointengg": lstSelectedEngineer.last.id,
    });
    String url = "${AppConfig.baseUrl}/assign-engineer";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return assignEngineerResponseFromJson(response.body);
  }

  Future<FreeEngineerResponse> getAllFreeEngineerResponse() async {
    String url = "${AppConfig.baseUrl}/free-engineers";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return freeEngineerResponseFromJson(response.body);
  }
}
