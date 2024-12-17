import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

PreviousComplainResponse previousComplainResponseFromJson(String str) => PreviousComplainResponse.fromJson(json.decode(str));

String previousComplainResponseToJson(PreviousComplainResponse data) => json.encode(data.toJson());

class PreviousComplainResponse {
  bool success;
  String message;
  Data? data;

  PreviousComplainResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PreviousComplainResponse.fromJson(Map<String, dynamic> json) => PreviousComplainResponse(
    success: json["success"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data!.toJson(),
  };
}

class Data {
  List<ComplainData> pastComplaints;

  Data({
    required this.pastComplaints,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pastComplaints: List<ComplainData>.from(json["past_complaints"].map((x) => ComplainData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "past_complaints": List<dynamic>.from(pastComplaints.map((x) => x.toJson())),
  };
}
