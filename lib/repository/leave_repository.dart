import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/delete_response.dart';
import 'package:omsatya/models/leave/add_leave_response.dart';
import 'package:omsatya/models/leave/get_all_leave_response.dart';
import 'package:omsatya/models/leave/leave_approve_reject_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';

class LeaveRepository{

  Future<GetAllLeaveResponse> getAllLeaveData() async {
    String url = "${AppConfig.baseUrl}/leaves";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllLeaveResponseFromJson(response.body);
  }

  Future<AddLeaveResponse> getAddLeaveData({dynamic body, int? leaveId}) async {
    String url;
    if(leaveId == null) {
      url = "${AppConfig.baseUrl}/leaves";
    } else {
      url = "${AppConfig.baseUrl}/leaves/$leaveId";
      body!.addAll({"_method":"PUT"});
    }
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return addLeaveResponseFromJson(response.body);
  }

  Future<DeleteTodoResponse> deleteTodoDataById({int? leaveId}) async {
    String url = "${AppConfig.baseUrl}/leaves/$leaveId";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.delete(url: url, header: headerMap);
    return deleteTodoResponseFromJson(response.body);
  }

  Future<LeaveApprovedRejectResponse> leaveAcceptRejectById({int? leaveId}) async {
    String url = "${AppConfig.baseUrl}/leaves-accept-reject/$leaveId";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return leaveApprovedRejectResponseFromJson(response.body);
  }

}