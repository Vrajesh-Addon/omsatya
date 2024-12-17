import 'dart:convert';

AddTodoTeamResponse addTodoTeamResponseFromJson(String str) => AddTodoTeamResponse.fromJson(json.decode(str));

String addTodoTeamResponseToJson(AddTodoTeamResponse data) => json.encode(data.toJson());

class AddTodoTeamResponse {
  String? message;
  AddTodoTeamData? data;

  AddTodoTeamResponse({
    this.message,
    this.data,
  });

  factory AddTodoTeamResponse.fromJson(Map<String, dynamic> json) => AddTodoTeamResponse(
    message: json["message"],
    data: json["data"] == null ? null : AddTodoTeamData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class AddTodoTeamData {
  String? name;
  int? id;

  AddTodoTeamData({
    this.name,
    this.id,
  });

  factory AddTodoTeamData.fromJson(Map<String, dynamic> json) => AddTodoTeamData(
    name: json["name"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
  };
}
