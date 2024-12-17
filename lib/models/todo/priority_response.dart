class PriorityResponse {
  int? id;
  String? priority;

  PriorityResponse({
    this.id,
    this.priority,
  });

  factory PriorityResponse.fromJson(Map<String, dynamic> json) => PriorityResponse(
    id: json["id"],
    priority: json["priority"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "priority": priority,
  };
}