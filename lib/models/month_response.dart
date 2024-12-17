import 'dart:convert';

MonthResponse monthResponseFromJson(String str) => MonthResponse.fromJson(json.decode(str));

String monthResponseToJson(MonthResponse data) => json.encode(data.toJson());

class MonthResponse {
  bool success;
  String message;
  List<MonthData> data;

  MonthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MonthResponse.fromJson(Map<String, dynamic> json) => MonthResponse(
    success: json["success"],
    message: json["message"],
    data: List<MonthData>.from(json["data"].map((x) => MonthData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MonthData {
  int id;
  String name;
  int newid;
  int tag;
  dynamic createdAt;
  dynamic updatedAt;

  MonthData({
    required this.id,
    required this.name,
    required this.newid,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthData.fromJson(Map<String, dynamic> json) => MonthData(
    id: json["id"],
    name: json["name"],
    newid: json["newid"],
    tag: json["tag"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "newid": newid,
    "tag": tag,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
