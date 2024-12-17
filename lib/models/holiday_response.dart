import 'dart:convert';

HolidayResponse holidayResponseFromJson(String str) => HolidayResponse.fromJson(json.decode(str));

String holidayResponseToJson(HolidayResponse data) => json.encode(data.toJson());

class HolidayResponse {
  bool? success;
  String? message;
  HolidayData? data;

  HolidayResponse({
    this.success,
    this.message,
    this.data,
  });

  factory HolidayResponse.fromJson(Map<String, dynamic> json) => HolidayResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] is List && json["data"].isEmpty ? null : HolidayData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class HolidayData {
  int? id;
  String? date;
  String? description;

  HolidayData({
    this.id,
    this.date,
    this.description,
  });

  factory HolidayData.fromJson(Map<String, dynamic> json) => HolidayData(
    id: json["id"],
    date: json["date"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "description": description,
  };
}
