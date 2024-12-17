import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/models/leave/apply_leave_data.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/repository/auth_repository.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/leave_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class AddLeave extends StatefulWidget {
  final ApplyLeaveData? applyLeaveData;

  const AddLeave({super.key, this.applyLeaveData});

  @override
  State<AddLeave> createState() => _AddLeaveState();
}

class _AddLeaveState extends State<AddLeave> {
  final GlobalKey<FormState> _formKeyAddLeave = GlobalKey<FormState>();
  final TextEditingController _txtDateTimeController = TextEditingController();
  final TextEditingController _txtLeaveFromController = TextEditingController();
  final TextEditingController _txtLeaveToController = TextEditingController();
  final TextEditingController _txtTotalLeaveController = TextEditingController();
  final TextEditingController _txtLeaveReasonController = TextEditingController();
  final TextEditingController _txtUserNameController = TextEditingController();

  List<UserResponse> allUserList = [];

  List<DropdownMenuItem<UserResponse>>? _dropdownAllUser;

  UserResponse? _selectedUser;

  DateTime? selectedLeaveFromDate;
  DateTime? selectedLeaveToDate;
  String date = "";
  String time = "";
  int daysBetween = 0;

  bool isLoading = false;
  bool isUser = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _txtDateTimeController.dispose();
    _txtLeaveFromController.dispose();
    _txtLeaveToController.dispose();
    _txtTotalLeaveController.dispose();
    _txtLeaveReasonController.dispose();
    _txtUserNameController.dispose();
    super.dispose();
  }

  init() async {
    if(AppGlobals.user!.roles!.first.id == 2) {
      await fetchAllUser();
      _dropdownAllUser = buildDropdownUserNameItems(allUserList);
    }
    if(widget.applyLeaveData == null) {
      date = AppGlobals().getCurrentDate();
      time = AppGlobals().getCurrentTime();
      _txtDateTimeController.text = "$date  $time";
    } else {
      _txtDateTimeController.text = widget.applyLeaveData!.dateTime!;
      _txtLeaveFromController.text = widget.applyLeaveData!.leaveFrom!;
      _txtLeaveToController.text = widget.applyLeaveData!.leaveTill!;
      _txtTotalLeaveController.text = widget.applyLeaveData!.totalLeave!.toString();
      _txtLeaveReasonController.text = widget.applyLeaveData!.reason!;

      if(AppGlobals.user!.roles!.first.id == 2) {
        for (int x = 0; x < _dropdownAllUser!.length; x++) {
          if (_dropdownAllUser![x].value!.id == widget.applyLeaveData!.userResponse!.id) {
            _selectedUser = _dropdownAllUser![x].value;
          }
        }
      }

    }
  }

  Future<void> _selectLeaveFromDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedLeaveFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedLeaveFromDate) {
      setState(() {
        selectedLeaveFromDate = picked;
        // if(selectedLeaveToDate != null){
        //   daysBetween = AppGlobals.calculateDaysBetweenTwoDates(firstDate: DateFormat('yyyy-MM-dd').format(selectedLeaveFromDate!), endDate: DateFormat('yyyy-MM-dd').format(selectedLeaveToDate!));
        // }
        _txtLeaveFromController.text = DateFormat('yyyy-MM-dd').format(picked);
        _txtLeaveToController.clear();
      });
    }
  }

  Future<void> _selectLeaveToDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedLeaveToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedLeaveToDate) {
      setState(() {
        selectedLeaveToDate = picked;
        daysBetween = AppGlobals.calculateDaysBetweenTwoDates(
            firstDate: DateFormat('yyyy-MM-dd').format(selectedLeaveFromDate!),
            endDate: DateFormat('yyyy-MM-dd').format(selectedLeaveToDate!));
        _txtLeaveToController.text = DateFormat('yyyy-MM-dd').format(picked);
        _txtTotalLeaveController.text = daysBetween.toString();
      });
    }
  }

  fetchAllUser() async {
    try {
      setState(() {
        isUser = true;
      });

      var response = await AuthRepository().getAllUserData();

      if (response.success) {
        allUserList = response.data;
        isUser = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isUser = false;
      });
    } finally {
      setState(() {
        isUser = false;
      });
    }
  }

  void onSubmit(BuildContext context) async {
    try {
      if (!_formKeyAddLeave.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      var body = {
        "firm_id": "1",
        "year_id": "1",
        "user_id": AppGlobals.user!.roles!.first.id == 2 ? _selectedUser!.id.toString() : AppGlobals.user!.id.toString(),
        "date_time": _txtDateTimeController.text,
        "leave_from": _txtLeaveFromController.text,
        "leave_till": _txtLeaveToController.text,
        "total_leave": _txtTotalLeaveController.text,
        "reason": _txtLeaveReasonController.text,
        "is_approved": "0",
      };

      var response = await LeaveRepository().getAddLeaveData(body: body, leaveId: widget.applyLeaveData?.id);

      if (!response.status) {
        isLoading = false;
        AppGlobals.showMessage(response.message, MessageType.error);
        setState(() {});
        return;
      }

      if (response.status) {
        AppGlobals.showMessage(response.message, MessageType.success);
        isLoading = false;
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(false),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimen.padding),
          child: Form(
            key: _formKeyAddLeave,
            child: Column(
              children: [
                TextFormField(
                  controller: _txtDateTimeController,
                  decoration: const InputDecoration(
                    labelText: AppString.dateTime,
                  ),
                  textInputAction: TextInputAction.next,
                  readOnly: true,
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true);
                    // if (!isValid) {
                    //   return AppString.selectCurrentDateTime;
                    // }
                    return null;
                  },
                ),
                if(AppGlobals.user!.roles!.first.id == 2)
                const FieldSpace(),
                if(AppGlobals.user!.roles!.first.id == 2)
                DropdownButtonFormField2<UserResponse>(
                  value: _selectedUser,
                  items: _dropdownAllUser,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: AppString.user,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimen.textRadius),
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppString.selectAssignEngineer;
                    }
                    return null;
                  },
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      _txtUserNameController.clear();
                    }
                  },
                  dropdownSearchData: DropdownSearchData(
                    searchController: _txtUserNameController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 60,
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 4,
                        right: 8,
                        left: 8,
                      ),
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        controller: _txtUserNameController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimen.padding,
                            vertical: AppDimen.paddingSmall,
                          ),
                          hintText: AppString.searchForUser,
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn:
                        (DropdownMenuItem<UserResponse>? item, searchValue) {
                      return item!.value!.name!.toLowerCase().contains(searchValue);
                    },
                  ),
                ),
                const FieldSpace(),
                TextFormField(
                  controller: _txtLeaveFromController,
                  decoration: const InputDecoration(
                    labelText: AppString.leaveFrom,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    _selectLeaveFromDate();
                  },
                  validator: (value) {
                    bool isValid = Validations.validateInput(value, true);
                    if (!isValid) {
                      return AppString.selectLeaveFromDate;
                    }
                    return null;
                  },
                ),
                const FieldSpace(),
                TextFormField(
                  controller: _txtLeaveToController,
                  decoration: const InputDecoration(
                    labelText: AppString.leaveTo,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    _selectLeaveToDate();
                  },
                  validator: (value) {
                    bool isValid = Validations.validateInput(value, true);
                    if (!isValid) {
                      return AppString.selectLeaveToDate;
                    }
                    return null;
                  },
                ),
                const FieldSpace(),
                TextFormField(
                  controller: _txtTotalLeaveController,
                  decoration: const InputDecoration(
                    labelText: AppString.totalDays,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true, ValidationType.none);
                    // if (!isValid) {
                    //   return AppString.enterLeaveReason;
                    // }
                    return null;
                  },
                ),
                const FieldSpace(),
                TextFormField(
                  controller: _txtLeaveReasonController,
                  decoration: const InputDecoration(
                    labelText: AppString.reason,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    bool isValid = Validations.validateInput(value, true, ValidationType.none);
                    if (!isValid) {
                      return AppString.enterLeaveReason;
                    }
                    return null;
                  },
                ),
                const FieldSpace(SpaceType.extraLarge),
                Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: isLoading ? null : () => onSubmit(context),
                            text: AppString.submit,
                          ),
                        ),
                      ],
                    ),
                    if (isLoading) const ButtonLoader(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<UserResponse>> buildDropdownUserNameItems(
      List<UserResponse> userList) {
    List<DropdownMenuItem<UserResponse>> items = [];
    for (UserResponse item in userList as Iterable<UserResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }
}
