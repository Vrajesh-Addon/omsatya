import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/engineer_data_source.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/get_all_attendance_data_response.dart';
import 'package:omsatya/models/global_models.dart';
import 'package:omsatya/repository/attendance_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DailyAttendance extends StatefulWidget {
  final int complainStatusKey;

  const DailyAttendance({super.key, this.complainStatusKey = 1});

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  TextEditingController textEditingController = TextEditingController();
  final TextEditingController _txtDateController = TextEditingController();
  final TextEditingController _txtNameController = TextEditingController();

  List<GetAllAttendanceData> allEngAttendanceList = [];

  List<DropdownMenuItem<LeaveType>>? _dropdownLeaveTypeItems;
  List<DropdownMenuItem<Role>>? _dropdownRolesItems;

  LeaveType? _selectedLeaveType;
  Role? _selectedRole;

  DateTime? selectedReminderDate;

  int defaultComplainStatusKey = 1;
  int roleId = 0;

  bool isInitial = false;
  bool isMonth = true;
  bool isEngineer = true;

  EngineerDataSource? engineerDataSource;
  Timer? _debounce;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    init();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    textEditingController.dispose();
    _txtDateController.dispose();
    super.dispose();
  }

  init() async {
    roleId = AppGlobals.user!.roles!.first.id!;
    showMessage("RoleId ==> $roleId");
    String date = AppGlobals().getCurrentDate();
    _txtDateController.text = date;
    await fetchDailyAttendance();

    _dropdownLeaveTypeItems = buildDropdownLeaveTypeItems(LeaveType.getLeaveTypeList());
    _dropdownRolesItems = buildDropdownRolesItems(getRolesList());
  }

  reset() {
    allEngAttendanceList.clear();
    fetchDailyAttendance();
  }

  clear() {
    _txtNameController.clear();
    setState(() {
      if (mounted) {
        engineerDataSource = EngineerDataSource(
          buildContext: context,
          lstEngineerData: allEngAttendanceList,
        );
      }
    });
  }

  fetchDailyAttendance() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response =
          await AttendanceRepository().getAllDailyAttendance(date: _txtDateController.text);

      if (response.success!) {
        allEngAttendanceList = response.data!;
        if (mounted) {
          engineerDataSource = EngineerDataSource(
            buildContext: context,
            lstEngineerData: allEngAttendanceList,
          );
        }
        isInitial = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isInitial = false;
      });
    } finally {
      setState(() {
        isInitial = false;
      });
    }
  }

  _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      showMessage("value ==> $value");

      if (value.isNotEmpty) {
        final filteredList = allEngAttendanceList.where((engineer) {
          return engineer.name!.toLowerCase().contains(value.toLowerCase());
        }).toList();

        setState(() {
          if (mounted) {
            engineerDataSource = EngineerDataSource(
              buildContext: context,
              lstEngineerData: filteredList,
            );
          }
        });
      } else {
        clear();
      }
    });
  }

  apFilter() {
    final filteredList = allEngAttendanceList.where((engineer) {
      if (_selectedLeaveType!.type.toLowerCase() == "p" ||
          _selectedLeaveType!.type.toLowerCase() == "h") {
        return engineer.ap!.toLowerCase().contains(_selectedLeaveType!.type.toLowerCase());
      } else {
        return engineer.attendanceStatus!
            .toLowerCase()
            .contains(_selectedLeaveType!.type.toLowerCase());
      }
    }).toList();

    setState(() {
      isInitial = false;
      if (mounted) {
        engineerDataSource = EngineerDataSource(
          buildContext: context,
          lstEngineerData: filteredList,
        );
      }
    });
  }

  roleFilters() {
    final filteredList = allEngAttendanceList.where((engineer) {
      return engineer.roles!.first.name!.toLowerCase().contains(_selectedRole!.name!.toLowerCase());
    }).toList();

    setState(() {
      isInitial = false;
      if (mounted) {
        engineerDataSource = EngineerDataSource(
          buildContext: context,
          lstEngineerData: filteredList,
        );
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedReminderDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedReminderDate) {
      setState(() {
        selectedReminderDate = picked;
        _txtDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      fetchDailyAttendance();
    }
  }

  clearFilter() {
    if (_selectedLeaveType != null || _txtNameController.text.isNotEmpty || _selectedRole != null) {
      setState(() {
        isInitial = true;
      });
      _selectedLeaveType = null;
      _selectedRole = null;
      _txtNameController.clear();
      setState(() {
        if (mounted) {
          isInitial = false;
          engineerDataSource = EngineerDataSource(
            buildContext: context,
            lstEngineerData: allEngAttendanceList,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.paddingSmall),
          child: Column(
            children: [
              buildFilterDropDown(context),
              const FieldSpace(SpaceType.small),
              isInitial || allEngAttendanceList.isEmpty
                  ? Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            FieldSpace(),
                            Text(AppString.pleaseWait),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: SfDataGrid(
                        source: engineerDataSource!,
                        shrinkWrapRows: true,
                        showVerticalScrollbar: true,
                        showHorizontalScrollbar: true,
                        verticalScrollPhysics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        horizontalScrollPhysics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        gridLinesVisibility: GridLinesVisibility.both,
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        // columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: MediaQuery.of(context).size.height * 0.1,
                        columns: <GridColumn>[
                          GridColumn(
                            columnName: 'sr',
                            width: MediaQuery.of(context).size.width * 0.07,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text(
                                'SR',
                              ),
                            ),
                          ),
                          GridColumn(
                            columnName: 'name',
                            width: MediaQuery.of(context).size.width * 0.25,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Name'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'a/p',
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('A/P'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'in',
                            width: MediaQuery.of(context).size.width * 0.12,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('In Time'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'out',
                            width: MediaQuery.of(context).size.width * 0.12,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Out Time'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'pending',
                            width: MediaQuery.of(context).size.width * 0.09,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Pending'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'inProgress',
                            width: MediaQuery.of(context).size.width * 0.12,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('In Progress'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'todayClosed',
                            width: MediaQuery.of(context).size.width * 0.09,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Closed'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'edit',
                            width: MediaQuery.of(context).size.width * 0.07,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Edit'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'inAddress',
                            width: MediaQuery.of(context).size.width * 0.2,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('In Address'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'outAddress',
                            width: MediaQuery.of(context).size.width * 0.2,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Out Address'),
                            ),
                          ),
                          GridColumn(
                            columnName: 'role',
                            width: MediaQuery.of(context).size.width * 0.15,
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppDimen.paddingSmall,
                                  horizontal: AppDimen.paddingSmall),
                              alignment: Alignment.center,
                              child: const Text('Role'),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildFilterDropDown(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimen.paddingSmall,
              vertical: AppDimen.paddingExtraSmall,
            ),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const FieldSpace(),
        GestureDetector(
          onTap: () => reset(),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const FieldSpace(SpaceType.extraSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                clearFilter();
              },
              borderRadius: BorderRadius.circular(AppDimen.textRadius),
              highlightColor: AppColors.primary.withOpacity(0.2),
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.1,
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                child: Text(
                  AppString.clear,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        const FieldSpace(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimen.textRadius),
                  ),
                  child: TextFormField(
                    controller: _txtDateController,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      labelText: AppString.date,
                      prefixIcon: Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall, vertical: 0),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    onTap: () {
                      _selectDate();
                    },
                    validator: (value) {
                      bool isValid = Validations.validateInput(value, true);
                      if (!isValid) {
                        return AppString.selectDate;
                      }
                      return null;
                    },
                  ),
                ),
                const FieldSpace(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.17,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<LeaveType>(
                      hint: Text(
                        AppString.selectAP,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: MediaQuery.of(context).size.width * 0.17,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          color: Colors.white,
                        ),
                      ),
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.17,
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
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                      ),
                      value: _selectedLeaveType,
                      items: _dropdownLeaveTypeItems,
                      isExpanded: true,
                      onChanged: (LeaveType? leaveType) {
                        setState(() {
                          _selectedLeaveType = leaveType;
                          isInitial = true;
                        });

                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () {
                            apFilter();
                          },
                        );
                      },
                    ),
                  ),
                ),
                const FieldSpace(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.17,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<Role>(
                      hint: Text(
                        AppString.selectRole,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: MediaQuery.of(context).size.width * 0.17,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          color: Colors.white,
                        ),
                      ),
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.17,
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
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                      ),
                      value: _selectedRole,
                      items: _dropdownRolesItems,
                      isExpanded: true,
                      onChanged: (Role? role) {
                        setState(() {
                          _selectedRole = role;
                          isInitial = true;
                        });

                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () {
                            roleFilters();
                          },
                        );
                      },
                    ),
                  ),
                ),
                const FieldSpace(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimen.textRadius),
                  ),
                  child: TextFormField(
                    controller: _txtNameController,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: AppString.searchName,
                      hintStyle: const TextStyle(
                        fontSize: 13,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => clear(),
                        child: const Icon(Icons.clear_rounded),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.paddingSmall, vertical: 0),
                    ),
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    inputFormatters: [NameInputFormatter()],
                    maxLines: 1,
                    onChanged: (value) => _onSearch(value),
                  ),
                ),
                const FieldSpace(),
              ],
            ),
          ),
        ),
      ],
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
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Role>> buildDropdownRolesItems(List<Role> lstRoles) {
    List<DropdownMenuItem<Role>> items = [];
    for (Role item in lstRoles as Iterable<Role>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      );
    }
    return items;
  }
}
