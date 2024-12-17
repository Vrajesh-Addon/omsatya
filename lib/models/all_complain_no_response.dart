import 'dart:convert';

AllComplainNoResponse allComplainNoResponseFromJson(String str) => AllComplainNoResponse.fromJson(json.decode(str));

String allComplainNoResponseToJson(AllComplainNoResponse data) => json.encode(data.toJson());

class AllComplainNoResponse {

  final bool success;
  final String message;
  final List<AllComplainNoData> data;


  AllComplainNoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AllComplainNoResponse.fromJson(Map<String, dynamic> json) => AllComplainNoResponse(
      success: json["success"],
      message: json["message"],
      data: List<AllComplainNoData>.from(json["data"]!.map((x) => AllComplainNoData.fromJson(x))),
    );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };

}

class AllComplainNoData {

  AllComplainNoData({
    required this.complaintNo,
  });

  final String? complaintNo;

  factory AllComplainNoData.fromJson(Map<String, dynamic> json) => AllComplainNoData(
      complaintNo: json["complaint_no"],
  );

  Map<String, dynamic> toJson() => {
    "complaint_no": complaintNo,
  };

}
