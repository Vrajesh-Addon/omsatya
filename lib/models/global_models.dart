import 'package:flutter/material.dart';

import 'get_all_attendance_data_response.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class LeaveType {
  String type;

  LeaveType({required this.type});

  static List<LeaveType> getLeaveTypeList() {
    return <LeaveType>[
      LeaveType(type: "P"),
      LeaveType(type: "A"),
      LeaveType(type: "L"),
      LeaveType(type: "H"),
    ];
  }
}

List<Role> getRolesList(){
  return <Role>[
    Role(name: "Complaint Manager"),
    Role(name: "Admin"),
    Role(name: "Customer"),
    Role(name: "Engineer"),
    Role(name: "Sales"),
  ];
}

class TodoStatus {
  int id;
  String name;

  TodoStatus(this.id, this.name);

  static List<TodoStatus> getDeliveryStatusList() {
    return <TodoStatus>[
      TodoStatus(1, "Done"),
      TodoStatus(0, "Not Done"),
    ];
  }
}

class Months {
  int id;
  String name;

  Months(this.id, this.name);

  static List<Months> getMonthsList() {
    return <Months>[
      Months(1, 'January'),
      Months(2, 'February'),
      Months(3, 'March'),
      Months(4, 'April'),
      Months(5, 'May'),
      Months(6, 'June'),
      Months(7, 'July'),
      Months(8, 'August'),
      Months(9, 'September'),
      Months(10, 'October'),
      Months(11, 'November'),
      Months(12, 'December'),
    ];
  }
}