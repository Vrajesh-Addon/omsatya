import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/models/get_all_attendance_data_response.dart';
import 'package:omsatya/models/global_models.dart';
import 'package:omsatya/repository/attendance_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EngineerDataSource extends DataGridSource {

  /// Creates the employee data source class with required details.
  EngineerDataSource(
      {required BuildContext buildContext, required List<GetAllAttendanceData> lstEngineerData,}) {

    context = buildContext;
    engineerDataList = lstEngineerData;

    _engineerData = lstEngineerData
        .asMap()
        .entries
        .map((e) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'sn', value: e.key + 1),
        DataGridCell<String>(columnName: 'name', value: e.value.name),
        DataGridCell<String>(columnName: 'a/p', value: e.value.ap!.isEmpty ? e.value.attendanceStatus : e.value.ap ?? ""),
        DataGridCell<String>(columnName: 'in', value: e.value.inTime!.isEmpty ? "N/A" : e.value.inTime ?? "N/A"),
        DataGridCell<String>(columnName: 'out', value: e.value.outTime!.isEmpty ? "N/A" : e.value.outTime ?? "N/A"),
        DataGridCell<String>(columnName: 'pending', value: e.value.pendingComplaintsCount.toString()),
        DataGridCell<String>(columnName: 'inProgress', value: e.value.inProgressComplaintsCount.toString()),
        DataGridCell<String>(columnName: 'closed', value: e.value.closedComplaintsCount.toString()),
        const DataGridCell<Widget>(columnName: 'edit', value: Icon(Icons.edit, color: AppColors.primary,)),
        DataGridCell<String>(columnName: 'inAddress', value: e.value.inAddress!.isEmpty ? "N/A" : e.value.inAddress ?? "N/A"),
        DataGridCell<String>(columnName: 'outAddress', value: e.value.outAddress!.isEmpty ? "N/A" : e.value.outAddress ?? "N/A"),
        DataGridCell<String>(columnName: 'role', value: e.value.roles!.isEmpty ? "N/A" : e.value.roles!.first.name ?? "N/A"),
      ]);
    }).toList();
  }

  List<DataGridRow> _engineerData = [];
  List<GetAllAttendanceData> engineerDataList = [];
  Function(int index)? openDialog;
  BuildContext? context;

  @override
  List<DataGridRow> get rows => _engineerData;


  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String ap = row.getCells()[2].value;
    final int index = effectiveRows.indexOf(row);

    Color getRowBackgroundColor() {
      if (index % 2 != 0) {
        return Colors.grey.withOpacity(0.1);
      }
      return Colors.transparent;
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          Color? getColors() {
            if (ap == 'L') {
              return AppColors.error.withOpacity(0.2);
            }
            return null;
          }

          TextStyle? getTextStyle() {
            if (e.columnName == 'a/p' || e.columnName == 'name') {
              if (e.value == 'P') {
                return const TextStyle(color: Colors.black, fontWeight: FontWeight.w500);
              } else if (e.value == 'A') {
                return const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500);
              } else if (e.value == 'H') {
                return const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w500);
              } else {
                return const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500);
              }
            }
            return null;
          }

          TextStyle? getNameTextStyle() {
            if (e.columnName == 'name') {
              if (ap == 'A') {
                return const TextStyle(color: AppColors.error);
              } else if (ap == 'L') {
                return const TextStyle(color: AppColors.error);
              }
            }
            return null;
          }

          return e.columnName == 'edit'
              ? IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary // Active color
                      ),
                  onPressed: () {
                    showMessage("e.value ==> $index");
                    _showEditDialog(row, index);
                    // openDialog?.call(index);
                  },
                )
              : Container(
            alignment: e.columnName == "name" ? Alignment.centerLeft : Alignment.center,
            padding: const EdgeInsets.all(
              AppDimen.paddingSmall,
            ),
            child: Text(
              e.value.toString(),
              style: e.columnName == "name" ? getNameTextStyle() : getTextStyle(),
            ),
          );
        }).toList());
  }


 void _showEditDialog(DataGridRow row, int index) {
    // Extract details from the row for editing
    final name = row.getCells()[1].value.toString();
    final apStatus = row.getCells()[2].value.toString();
    final inTime = row.getCells()[3].value.toString();
    final outTime = row.getCells()[4].value.toString();
    LeaveType? selectedLeaveType;

    final dropdownComplainStatusItems = buildDropdownLeaveTypeItems(LeaveType.getLeaveTypeList());

    for (int x = 0; x < dropdownComplainStatusItems.length; x++) {
      if (dropdownComplainStatusItems![x].value!.type == row.getCells()[2].value.toString()) {
        selectedLeaveType = dropdownComplainStatusItems[x].value;
      }
    }


    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Engineer Details'),
          content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(text:
                    TextSpan(
                      text: "Name: ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                            text: name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              letterSpacing: 1,
                              fontWeight: FontWeight.normal,
                            ),
                        ),
                      ]
                    ),
                    ),
                    const FieldSpace(SpaceType.small),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<LeaveType>(
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black,
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            color: Colors.white,
                          ),
                        ),
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.3,
                          padding: const EdgeInsets.only(
                            left: AppDimen.paddingSmall,
                            right: AppDimen.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            border: Border.all(
                              color: AppColors.primary,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.05,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimen.padding, vertical: 0),
                        ),
                        value: selectedLeaveType,
                        items: dropdownComplainStatusItems,
                        onChanged: (LeaveType? leaveType) {
                          setState(() {
                            selectedLeaveType = leaveType;
                          });
                        },
                      ),
                    ),
                  ],
                );
              }
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add logic to update the data grid
                Navigator.of(context).pop();

                _updateEngineerData(row, index, selectedLeaveType);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<LeaveType>> buildDropdownLeaveTypeItems(List<LeaveType> lstLeaveType) {
    List<DropdownMenuItem<LeaveType>> items = [];
    for (LeaveType item in lstLeaveType as Iterable<LeaveType>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.type,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }

  Future<void> _updateEngineerData(DataGridRow row, int index, LeaveType? selectedLeaveType) async {
    try {
      var response = await AttendanceRepository().updateAttendance(data: engineerDataList[index], leaveType: selectedLeaveType);

      if (response.success) {
        AppGlobals.showMessage(response.message, MessageType.success);
        final index = _engineerData.indexOf(row);

        _engineerData[index] = DataGridRow(cells: [
          DataGridCell<int>(columnName: 'sn', value: index + 1),
          DataGridCell<String>(columnName: 'name', value: engineerDataList[index].name),
          DataGridCell<String>(columnName: 'a/p', value: selectedLeaveType!.type),
          DataGridCell<String>(columnName: 'in', value: engineerDataList[index].inTime!.isEmpty ? "N/A" : engineerDataList[index].inTime),
          DataGridCell<String>(columnName: 'out', value: engineerDataList[index].outTime!.isEmpty ? "N/A" : engineerDataList[index].outTime),
          DataGridCell<String>(columnName: 'pending', value: engineerDataList[index].pendingComplaintsCount.toString()),
          DataGridCell<String>(columnName: 'inProgress', value: engineerDataList[index].inProgressComplaintsCount.toString()),
          DataGridCell<String>(columnName: 'closed', value: engineerDataList[index].closedComplaintsCount.toString()),
          const DataGridCell<Widget>(columnName: 'edit', value: Icon(Icons.edit)),
          DataGridCell<String>(columnName: 'inAddress', value: engineerDataList[index].inAddress!.isEmpty ? "N/A" : engineerDataList[index].inAddress),
          DataGridCell<String>(columnName: 'outAddress', value: engineerDataList[index].outAddress!.isEmpty ? "N/A" : engineerDataList[index].outAddress),
          DataGridCell<String>(columnName: 'role', value: engineerDataList[index].roles!.isEmpty ? "N/A" : engineerDataList[index].roles!.first.name ?? "N/A"),
        ]);

        notifyListeners();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

}

