import 'dart:convert';

DeviceTokenResponse deviceTokenResponseFromJson(String str) => DeviceTokenResponse.fromJson(json.decode(str));

String deviceTokenResponseToJson(DeviceTokenResponse data) => json.encode(data.toJson());

class DeviceTokenResponse {
  bool success;
  String message;

  DeviceTokenResponse({
    required this.success,
    required this.message,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) => DeviceTokenResponse(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}