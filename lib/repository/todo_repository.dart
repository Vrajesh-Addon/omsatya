import 'dart:convert';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/delete_response.dart';
import 'package:omsatya/models/todo/add_comment_response.dart';
import 'package:omsatya/models/todo/add_todo_team_response.dart';
import 'package:omsatya/models/todo/get_all_priority_response.dart';
import 'package:omsatya/models/todo/get_todo_all_data.dart';
import 'package:omsatya/models/todo/todo_data_by_id.dart';
import 'package:omsatya/models/todo/todo_favourite_response.dart';
import 'package:omsatya/models/todo/todo_filter_response.dart';
import 'package:omsatya/models/todo/todo_response.dart';
import 'package:omsatya/models/todo/todo_status_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:http/http.dart' as http;

class TodoRepository{

  Future<TodoResponse> todoDataStore({
    Map<String, String>? body,
    int? todoId,
  }) async {
    // String json = jsonEncode(body);

    String url;
    if(todoId == null) {
       url = "${AppConfig.baseUrl}/todos";
    } else {
      url = "${AppConfig.baseUrl}/todos/$todoId";
      body!.addAll({"_method":"PUT"});
    }

    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);

    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return todoResponseFromJson(response.body);
  }

  Future<AddCommentResponse> todoTaskCommentStore({
    Map<String, String>? body,
    int isNewMember = 0,
  }) async {
    String url = "${AppConfig.baseUrl}/todos/add-comment?is_new_member=$isNewMember";

    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);

    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return addCommentResponseFromJson(response.body);
  }

  Future<TodoDataByIdResponse> getTodoDataById({int? todoId}) async {
    String url = "${AppConfig.baseUrl}/todos/$todoId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return todoDataByIdResponseFromJson(response.body);
  }

  Future<GetTodoFilterResponse> getFilterTodoData({String? date, String? status, String? priorityId, String? assignUserId}) async {
    date ??= "";
    status ??= "";
    priorityId ??= "";
    assignUserId ??= "";
    String url = "${AppConfig.baseUrl}/todo/filter?assign_date_time=$date&status=$status&priority_id=$priorityId&assign_user_id=$assignUserId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getTodoFilterResponseFromJson(response.body);
  }

  Future<GetAllTodoResponse> getTodoDataAll({int? userId, int? role, int? isToday, String? status, String? priorityId}) async {
    String url;
    if(priorityId != null || status != null){
      status ??= "";
      priorityId ??= "";
      url = "${AppConfig.baseUrl}/todo/filter?status=$status&priority_id=$priorityId";
    } else {
      url = "${AppConfig.baseUrl}/todos?is_today_record=$isToday&is_upcoming_record=0&is_past_record=0";
    }
    // if(role != 2){
    //   url = "${AppConfig.baseUrl}/todos?is_today_record=$isToday";
    // } else {
    //   if(userId == null){
    //     url = "${AppConfig.baseUrl}/admin-todos";
    //   } else {
    //     url = "${AppConfig.baseUrl}/admin-todos/$userId";
    //   }
    // }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllTodoResponseFromJson(response.body);
  }

  Future<GetAllTodoResponse> getUpcomingTodoData({int? userId, int? role, int? isUpcoming, String? status, String? priorityId}) async {
    String url;
    if(priorityId != null || status != null){
      status ??= "";
      priorityId ??= "";
      url = "${AppConfig.baseUrl}/todo/filter?status=$status&priority_id=$priorityId";
    } else {
      url = "${AppConfig.baseUrl}/todos?is_upcoming_record=$isUpcoming&is_past_record=0&is_today_record=0";
    }
    // if(role != 2){
    //   url = "${AppConfig.baseUrl}/todos?is_upcoming_record=$isToday";
    // } else {
    //   if(userId == null){
    //     url = "${AppConfig.baseUrl}/admin-todos";
    //   } else {
    //     url = "${AppConfig.baseUrl}/admin-todos/$userId";
    //   }
    // }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllTodoResponseFromJson(response.body);
  }

  Future<GetAllTodoResponse> getPastTodoData({int? userId, int? role, int? isPast, String? status, String? priorityId}) async {
    String url;
    if(priorityId != null || status != null){
      status ??= "";
      priorityId ??= "";
      url = "${AppConfig.baseUrl}/todo/filter?status=$status&priority_id=$priorityId";
    } else {
      url = "${AppConfig.baseUrl}/todos?is_past_record=$isPast&is_today_record=0&is_upcoming_record=0";
    }
    // if(role != 2){
    //   url = "${AppConfig.baseUrl}/todos?is_upcoming_record=$isToday";
    // } else {
    //   if(userId == null){
    //     url = "${AppConfig.baseUrl}/admin-todos";
    //   } else {
    //     url = "${AppConfig.baseUrl}/admin-todos/$userId";
    //   }
    // }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllTodoResponseFromJson(response.body);
  }

  Future<TodoStatusResponse> updateTodoStatusById({int? todoId, int? status}) async {
    final postBody = jsonEncode({
      "status": status,
    });
    String url = "${AppConfig.baseUrl}/todo/update-status/$todoId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return todoStatusResponseFromJson(response.body);
  }

  Future<DeleteTodoResponse> deleteTodoDataById({int? todoId}) async {
    String url = "${AppConfig.baseUrl}/todos/$todoId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.delete(url: url, header: headerMap);
    return deleteTodoResponseFromJson(response.body);
  }

  Future<GetAllPriorityResponse> getPriorityResponse({int? priority, int? status}) async {
    String url = "${AppConfig.baseUrl}/priorities?is_priority=$priority&is_status=$status";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllPriorityResponseFromJson(response.body);
  }

  Future<TodoFavouriteResponse> todoFavouriteResponse({int? todoId, int? status}) async {
    final postBody = jsonEncode({
      "id": todoId,
      "favorite": status,
    });
    String url = "${AppConfig.baseUrl}/todos/favorite";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: postBody);
    return todoFavouriteResponseFromJson(response.body);
  }

  Future<http.Response> createTodoTeam({body}) async {
    String url = "${AppConfig.baseUrl}/teams";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return response;
  }
}