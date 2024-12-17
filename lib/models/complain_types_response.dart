import 'dart:convert';

ComplainTypesResponse complainTypesFromJson(String str) => ComplainTypesResponse.fromJson(json.decode(str));

String complainTypesToJson(ComplainTypesResponse data) => json.encode(data.toJson());

class ComplainTypesResponse {
  bool success;
  String message;
  List<ComplainTypesData> data;

  ComplainTypesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ComplainTypesResponse.fromJson(Map<String, dynamic> json) => ComplainTypesResponse(
    success: json["success"],
    message: json["message"],
    data: List<ComplainTypesData>.from(json["data"].map((x) => ComplainTypesData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ComplainTypesData {
  int id;
  String name;
  String? description;

  ComplainTypesData({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ComplainTypesData.fromJson(Map<String, dynamic> json) => ComplainTypesData(
    id: json["id"],
    name: json["name"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}
