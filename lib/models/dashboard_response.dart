import 'dart:convert';

DashboardResponse dashboardResponseFromJson(String str) => DashboardResponse.fromJson(json.decode(str));

String dashboardResponseToJson(DashboardResponse data) => json.encode(data.toJson());

class DashboardResponse {
  bool success;
  String message;
  DashboardData data;

  DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => DashboardResponse(
    success: json["success"],
    message: json["message"],
    data: DashboardData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class DashboardData {
  int totalComplaints;
  int pendingComplaints;
  int inProgressComplaints;
  int closedComplaints;

  DashboardData({
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.inProgressComplaints,
    required this.closedComplaints,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    totalComplaints: json["total_complaints"],
    pendingComplaints: json["pending_complaints"],
    inProgressComplaints: json["in_progress_complaints"],
    closedComplaints: json["closed_complaints"],
  );

  Map<String, dynamic> toJson() => {
    "total_complaints": totalComplaints,
    "pending_complaints": pendingComplaints,
    "in_progress_complaints": inProgressComplaints,
    "closed_complaints": closedComplaints,
  };
}
