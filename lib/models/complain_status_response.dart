import 'dart:convert';

ComplainStatusResponse complainStatusResponseFromJson(String str) => ComplainStatusResponse.fromJson(json.decode(str));

String complainStatusResponseToJson(ComplainStatusResponse data) => json.encode(data.toJson());

class ComplainStatusResponse {
  bool? success;
  String? message;
  List<ComplainStatusData>? data;

  ComplainStatusResponse({
    this.success,
    this.message,
    this.data,
  });

  factory ComplainStatusResponse.fromJson(Map<String, dynamic> json) => ComplainStatusResponse(
    success: json["success"],
    message: json["message"],
    data: List<ComplainStatusData>.from(json["data"].map((x) => ComplainStatusData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ComplainStatusData {
  int? id;
  String? name;

  ComplainStatusData({
    this.id,
    this.name,
  });

  factory ComplainStatusData.fromJson(Map<String, dynamic> json) => ComplainStatusData(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
