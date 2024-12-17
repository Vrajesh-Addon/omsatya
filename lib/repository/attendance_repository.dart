import 'dart:convert';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/admin_get_today_attendance.dart';
import 'package:omsatya/models/attendance_response.dart';
import 'package:omsatya/models/get_all_attendance_data_response.dart';
import 'package:omsatya/models/global_models.dart';
import 'package:omsatya/models/month_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class AttendanceRepository{

  Future<MonthResponse> getAllMonthResponse() async {
    String url = "${AppConfig.baseUrl}/months";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return monthResponseFromJson(response.body);
  }

  Future<AttendanceResponse> getEngineerAttendance({
    int? engineerId,
  }) async {
    var body = jsonEncode({
      "engineer_id": engineerId,
    });
    String url = "${AppConfig.baseUrl}/attendance-today";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return attendanceResponseFromJson(response.body);
  }

  Future<AttendanceResponse> engineerAttendanceStore({
    int? firmId,
    int? engineerId,
    int? yearId,
    String? inDate,
    String? inTime,
    String? ap,
    double? pDays,
    double? lateHrs,
    double? inLat,
    double? inLong,
    String? address,
  }) async {
    var body = jsonEncode({
      "firm_id": firmId,
      "engineer_id": engineerId,
      "year_id": yearId,
      "in_date": inDate,
      "in_time": inTime,
      "ap": ap,
      "late_hrs": lateHrs,
      "pdays": pDays,
      "in_late": inLat,
      "in_long": inLong,
      "in_address": address,
    });
    String url = "${AppConfig.baseUrl}/attendance-store";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return attendanceResponseFromJson(response.body);
  }

  Future<AttendanceResponse> engineerAttendanceUpdate({
    int? id,
    String? outDate,
    String? outTime,
    String? ap,
    double? earlyGoingHrs,
    double? workingHrs,
    double? pDays,
    double? outLat,
    double? outLong,
    String? outAddress,
  }) async {
    var body = jsonEncode({
      "id": id,
      "out_date": outDate,
      "out_time": outTime,
      "ap": ap,
      "earligoing_hrs": earlyGoingHrs,
      "working_hrs": workingHrs,
      "pdays": pDays,
      "out_late": outLat,
      "out_long": outLong,
      "out_address": outAddress,
    });
    String url = "${AppConfig.baseUrl}/attendance-update";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return attendanceResponseFromJson(response.body);
  }

  Future<GetAllAttendanceDataResponse> getAllDailyAttendance({String? date}) async {
    String url = "${AppConfig.baseUrl}/engineer-attendance-by-date/$date";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllAttendanceDataResponseFromJson(response.body);
  }

  Future<AttendanceResponse> updateAttendance({GetAllAttendanceData? data, LeaveType? leaveType}) async {
    double pDays;
    if(leaveType!.type == "H"){
      pDays = 0.5;
    } else if (leaveType.type == "P"){
      pDays = 1;
    } else {
      pDays = 0;
    }

    var body = jsonEncode({
      "ap": leaveType != null ? leaveType.type : data!.ap,
      "pdays": pDays,
    });
    String url = "${AppConfig.baseUrl}/attendance-half-day/${data!.engineerId}";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return attendanceResponseFromJson(response.body);
  }

}