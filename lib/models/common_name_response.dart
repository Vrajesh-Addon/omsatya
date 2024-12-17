import 'dart:convert';

CommonNameResponse commonNameResponseFromJson(String str) => CommonNameResponse.fromJson(json.decode(str));

String commonNameResponseToJson(CommonNameResponse data) => json.encode(data.toJson());

class CommonNameResponse {
  bool success;
  String message;
  List<CommonNameData> data;

  CommonNameResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommonNameResponse.fromJson(Map<String, dynamic> json) => CommonNameResponse(
    success: json["success"],
    message: json["message"],
    data: List<CommonNameData>.from(json["data"].map((x) => CommonNameData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CommonNameData {
  int id;
  String name;

  CommonNameData({
    required this.id,
    required this.name,
  });

  factory CommonNameData.fromJson(Map<String, dynamic> json) => CommonNameData(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
