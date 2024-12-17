import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/models/roles/roles_response.dart';
import 'package:omsatya/models/todo/get_todo_all_data.dart';
import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/models/todo/todo_data_by_id.dart';
import 'package:omsatya/models/todo/todo_task.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/repository/todo_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/btn.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class AddTodo extends StatefulWidget {
  final GetTodoData? todoData;

  const AddTodo({super.key, this.todoData});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final TextEditingController _txtDateTimeController = TextEditingController();
  final TextEditingController _txtTitleController = TextEditingController();
  final TextEditingController _txtDescriptionController = TextEditingController();
  final TextEditingController _txtRemindDateController = TextEditingController();
  final TextEditingController _txtRemindTimeController = TextEditingController();
  final TextEditingController _txtCommentFirstController = TextEditingController();
  final TextEditingController _txtCommentSecondController = TextEditingController();
  final TextEditingController _txtUserNameController = TextEditingController();
  final TextEditingController _txtSearchPriorityController = TextEditingController();

  final GlobalKey<FormState> _formKeyAddTodo = GlobalKey<FormState>();

  List<PriorityResponse> priorityList = [];
  List<UserResponse> allUserList = [];
  List<RolesData> rolesList = [];
  List<File> selectedFiles = [];

  List<DropdownMenuItem<PriorityResponse>>? _dropdownPriority;
  List<DropdownMenuItem<UserResponse>>? _dropdownAllUser;
  List<DropdownMenuItem<RolesData>>? _dropdownRoles;

  PriorityResponse? _selectedPriority;
  UserResponse? _selectedUser;
  RolesData? _selectedRoles;

  TodoDataById? todoData;

  double latitude = 0.0;
  double longitude = 0.0;
  String? locationAddress;

  bool isLoading = false;
  bool isTodoData = false;
  bool isAddMember = false;

  DateTime? selectedReminderDate;
  TimeOfDay selectedRemainderTime = TimeOfDay.now();
  DateTime? picked;
  DateTime selectedCurrentTime = DateTime.now();

  String date = "";
  String time = "";
  String pickedTime = "";

  List<UserResponse> selectedUsers = [];
  List<UserResponse> selectedAddMember = [];

  int i = 0;

  @override
  void initState() {
    date = AppGlobals().getCurrentDate();
    time = AppGlobals().getCurrentTime();
    _txtDateTimeController.text = "$date $time";
    // _txtNextDateController.text = AppGlobals().getCurrentDate();
    // _txtNextTimeController.text = AppGlobals().getCurrentTime();

    init();
    super.initState();
  }

  @override
  void dispose() {
    _txtDateTimeController.dispose();
    _txtTitleController.dispose();
    _txtDescriptionController.dispose();
    _txtRemindDateController.dispose();
    _txtRemindTimeController.dispose();
    _txtCommentFirstController.dispose();
    _txtCommentSecondController.dispose();
    _txtUserNameController.dispose();
    _txtSearchPriorityController.dispose();
    selectedUsers.clear();
    super.dispose();
  }

  init() async {
    // if(widget.todoId != null){
    //   await fetchTodoDataByID();
    // }
    // if(widget.todoData == null) {
    // }
    await fetchRoles();
    _dropdownRoles = buildDropdownRolesItems(rolesList);

    for (int x = 0; x < _dropdownRoles!.length; x++) {
      if (_dropdownRoles![x].value!.id == 6) {
        _selectedRoles = _dropdownRoles![x].value;
      }
    }

    await fetchRolesUser();
    await fetchPriority();

    _dropdownPriority = buildDropdownPriorityItems(priorityList);
    _dropdownAllUser = buildDropdownUserItems(allUserList);

    if(widget.todoData == null) {
      _selectedUser = allUserList.firstWhere((element) => element.id == AppGlobals.user!.id, orElse: () => UserResponse());
      if(_selectedUser != null && _selectedUser!.id != null) {
        selectedUsers.add(_selectedUser!);
      }
      showMessage("selected User ==> $selectedUsers");

      // for (int x = 0; x < allUserList.length; x++) {
      //   if (allUserList[x].id == AppGlobals.user!.id) {
      //     _selectedUser = UserResponse(
      //         id: allUserList[x].id,
      //         areaId: allUserList[x].areaId,
      //         dutyEnd: allUserList[x].dutyEnd,
      //         dutyHours: allUserList[x].dutyHours,
      //         dutyStart: allUserList[x].dutyStart,
      //         email: allUserList[x].email,
      //         isActive: allUserList[x].isActive,
      //         name: allUserList[x].name,
      //         phoneNo: allUserList[x].phoneNo,
      //         roles: allUserList[x].roles);
      //   }
      // }
    }

    if (widget.todoData != null) {
      _txtDateTimeController.text = "${widget.todoData!.assignDateTime!}";
      _txtTitleController.text = widget.todoData!.title!;
      _txtDescriptionController.text = widget.todoData!.description!;

      TodoTask todoTask = widget.todoData!.todoTasks!.lastWhere((element) {
        return element.userId == AppGlobals.user!.id;
      });
      _txtRemindDateController.text = todoTask.date!;
      _txtRemindTimeController.text = AppGlobals.convertTo12HourFormat(todoTask.time!);


      for(int i = 0; i < widget.todoData!.todoAssignUsers!.length; i++){
        UserResponse userResponse = allUserList.firstWhere((element) => element.id == widget.todoData!.todoAssignUsers![i].assignUserDetail!.id, orElse: () => UserResponse());
        if(userResponse != null && userResponse.id != null) {
          selectedAddMember.add(userResponse);
        }
      }
    }
  }

  Future<FilePickerResult?> pickMultipleFile() async {
    return await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: [
      "jpg",
      "jpeg",
      "png",
      "mp4",
      "mov",
      "mkv",
      "pdf"
    ]);
  }

  chooseAndUploadFile(context) async {
    FilePickerResult? result = await pickMultipleFile();
    if (result == null) {
      AppGlobals.showMessage(
        "No file selected",
        MessageType.error,
      );
      return;
    } else {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
        showMessage("Selected files ==> $selectedFiles");
      });
    }
  }

  fetchTodoDataByID() async {
    try {
      setState(() {
        isTodoData = true;
      });

      var response = await TodoRepository().getTodoDataById(todoId: widget.todoData!.id);

      if (response.status!) {
        todoData = response.data!;
        isTodoData = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isTodoData = false;
      });
    } finally {
      setState(() {
        isTodoData = false;
      });
    }
  }

  fetchPriority() async {
    try {
      var response = await TodoRepository().getPriorityResponse(priority: 1, status: 0);

      if (response.success) {
        priorityList = response.data;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {});
    } finally {
      setState(() {});
    }
  }

  fetchRoles() async {
    try {
      var response = await DashboardRepository().getRolesResponse();

      if (response.success!) {
        // rolesList = response.data!;
        for (var element in response.data!) {
          if(element.id == 4 || element.id == 5 || element.id == 6) {
            rolesList.add(element);
          }
        }
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {});
    } finally {
      setState(() {});
    }
  }

  fetchRolesUser() async {
    try {
      String? isEmb;
      String? isCir;
      if(_selectedRoles!.name! == "Sales"){
        isEmb = "1";
        isCir = "1";
      }
      var response = await DashboardRepository().getRolesUserData(name: _selectedRoles!.name!, isEmb: isEmb, isCir: isCir);

      if (response.success!) {
        allUserList = response.data!;
        selectedAddMember.clear();
        if(widget.todoData == null) {
          _selectedUser = allUserList.firstWhere((element) => element.id == AppGlobals.user!.id, orElse: () => UserResponse());
          if(_selectedUser != null && _selectedUser!.id != null) {
            selectedUsers.add(_selectedUser!);
          }
        } else {
          for (int i = 0; i < widget.todoData!.todoAssignUsers!.length; i++) {
            UserResponse userResponse = allUserList.firstWhere((element) =>
            element.id == widget.todoData!.todoAssignUsers![i].assignUserDetail!.id, orElse: () => UserResponse());
            if (userResponse != null && userResponse.id != null) {
              selectedAddMember.add(userResponse);
            }
          }
        }
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {});
    } finally {
      setState(() {});
    }
  }

  Future<void> _selectReminderDate() async {
    final DateTime? picked = await showDatePicker(
        context: context, initialDate: selectedReminderDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedReminderDate) {
      setState(() {
        selectedReminderDate = picked;
        _txtRemindDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
      content: TimePickerSpinner(
        is24HourMode: false,
        normalTextStyle: const TextStyle(
            fontSize: 24,
            color: Colors.black
        ),
        highlightedTextStyle: const TextStyle(
            fontSize: 24,
            color: AppColors.primary,
        ),
        time: DateTime.now(),
        // isShowSeconds: true,
        spacing: 50,
        itemHeight: 80,
        isForce2Digits: true,
        // minutesInterval: 5,
        onTimeChange: (time) {
          showMessage("Time picker ==> $time");
          setState(() {
            // _dateTime = time;
            picked = time;
          });
        },
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(onPressed: () {
            if (picked != null && picked != selectedCurrentTime) {
              setState(() {
                pickedTime = _formatTime(picked!);
                _txtRemindTimeController.text = pickedTime;
              });
            }
            Navigator.of(context).pop();
          }, child: const Text("Done"),),
      ],
    ),);


    // final TimeOfDay? picked = await showTimePicker(
    //   context: context,
    //   initialTime: selectedRemainderTime,
    //   builder: (BuildContext context, Widget? child) {
    //     return MediaQuery(
    //       data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
    //       child: child!,
    //     );
    //   },
    // );
    // if (picked != null && picked != selectedRemainderTime) {
    //   setState(() {
    //     pickedTime = _formatTime(picked);
    //     _txtRemindTimeController.text = pickedTime;
    //   });
    // }
  }

  // String _formatTime(TimeOfDay time) {
  //   final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  //   final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  //   return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  // }

  String _formatTime(DateTime dateTime) {
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }

  // String _formatTime(TimeOfDay time) {
  //   final hour = time.hour.toString().padLeft(2, '0');
  //   final minute = time.minute.toString().padLeft(2, '0');
  //   return '$hour:$minute:00';
  // }

  addTodoData() async {
    try {
      if (!_formKeyAddTodo.currentState!.validate()) {
        return;
      }

      if(selectedUsers.isEmpty){
        AppGlobals.showMessage(AppString.selectLeadUser, MessageType.error);
        return;
      }

      setState(() {
        isLoading = true;
      });

      Map<String, String> body = {
        'title': _txtTitleController.text.trim(),
        'description': _txtDescriptionController.text.trim(),
        'user_id': widget.todoData != null ? widget.todoData!.userId.toString() : AppGlobals.user!.id!.toString(),
        // 'assign_user_id':
        //     widget.todoData != null ? widget.todoData!.assignUserId.toString() : _selectedUser!.id.toString(),
        'assign_date_time': _txtDateTimeController.text.trim(),
        'priority_id': _selectedPriority!.id.toString(),
      };

      String time = AppGlobals.convertTo24HourFormat(_txtRemindTimeController.text);

      // if (widget.todoData == null) {
        for (i = 0; i < selectedUsers.length; i++) {
          body.addAll({
            'assign_users[$i][assign_user_id]': selectedUsers[i].id.toString(),
            'todo_task[$i][date]': _txtRemindDateController.text.isEmpty ? "-" : _txtRemindDateController.text,
            'todo_task[$i][time]': _txtRemindTimeController.text.isEmpty ? "-" : time,
            'todo_task[$i][comment_first]': (selectedUsers[i].id == AppGlobals.user!.id) ? _txtCommentFirstController.text : "-",
            // 'todo_task[$i][comment_first]': _txtCommentFirstController.text.isEmpty ? "-" : _txtCommentFirstController.text,
            'todo_task[$i][comment_second]': _txtCommentSecondController.text.isEmpty ? "-" : _txtCommentSecondController.text,
            'todo_task[$i][priority_id]': _selectedPriority!.id.toString(),
            'todo_task[$i][user_id]': selectedUsers[i].id.toString(),
          });
        }

      // showMessage("_txtRemindDateController.text ==> ${_txtRemindDateController.text}");
      //   return;

      // } else {
      //   widget.todoData!.todoTasks!.add(TodoTask(
      //     date: _txtRemindDateController.text,
      //     time: _txtRemindTimeController.text,
      //     commentFirst: _txtCommentFirstController.text,
      //     commentSecond: _txtCommentSecondController.text.isEmpty ? "-" : _txtCommentSecondController.text,
      //     priorityId: _selectedPriority!.id,
      //   ));
      //
      //   for (i = 0; i < widget.todoData!.todoTasks!.length; i++) {
      //     TodoTask data = widget.todoData!.todoTasks![i];
      //     body.addAll({
      //       'todo_task[$i][date]': data.date!,
      //       'todo_task[$i][time]': data.time!,
      //       'todo_task[$i][comment_first]': data.commentFirst!,
      //       'todo_task[$i][comment_second]': data.commentSecond!,
      //       'todo_task[$i][priority_id]': data.priorityId!.toString(),
      //     });
      //   }
      // }

      var response = await TodoRepository().todoDataStore(
        body: body,
        todoId: widget.todoData?.id,
      );

      if (response.status!) {
        AppGlobals.showMessage(response.message!, MessageType.success);
        isLoading = false;
        setState(() {});
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

  addTodoTaskComment() async {
    try {
      if (!_formKeyAddTodo.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      UserResponse? userResponse;
      List<UserResponse> newUsers = [];

      showMessage("selectedAddMember ==> ${selectedAddMember.toList()}");

      if(selectedAddMember.isNotEmpty) {
        List<int> todoAssignUserIds = widget.todoData!
            .todoAssignUsers!
            .map((user) => user.assignUserId as int)
            .toList();

        List<int> addMemberIds = selectedAddMember.map((user) => user.id as int).toList();

        List<int> newUserIds = addMemberIds.where((id) => !todoAssignUserIds.contains(id)).toList();
        // userResponse = selectedAddMember.firstWhere((user) => newUserIds.contains(user.id));
        newUsers = selectedAddMember.where((user) => newUserIds.contains(user.id)).toList();

      }

      int i = 0;
      Map<String, String> body = {};
      if(newUsers.isEmpty) {
        showMessage("newUsers 1 ==> ");
        body = {
          'todo_id[$i][todo_id]': widget.todoData!.id.toString(),
          'todo_id[$i][date]': _txtRemindDateController.text,
          'todo_id[$i][time]': AppGlobals.convertTo24HourFormat(_txtRemindTimeController.text),
          'todo_id[$i][comment_first]': _txtCommentFirstController.text.trim(),
          'todo_id[$i][comment_second]': _txtCommentSecondController.text.isEmpty ? "-" : _txtCommentSecondController
              .text.trim(),
          'todo_id[$i][priority_id]': _selectedPriority?.id.toString() ?? widget.todoData?.priorityId.toString() ?? "",
          'todo_id[$i][user_id]': AppGlobals.user!.id.toString(),
          // 'assign_date_time': _txtDateTimeController.text.trim(),
        };
      } else {
        for (int i = 0; i < newUsers.length; i++) {
          showMessage("newUsers 2 ==> ${newUsers[i].name}");
          body.addAll({
            'todo_id[$i][todo_id]': widget.todoData!.id.toString(),
            'todo_id[$i][date]': _txtRemindDateController.text,
            'todo_id[$i][time]': AppGlobals.convertTo24HourFormat(_txtRemindTimeController.text),
            'todo_id[$i][comment_first]': _txtCommentFirstController.text.trim(),
            'todo_id[$i][comment_second]': _txtCommentSecondController.text.isEmpty ? "-" : _txtCommentSecondController.text.trim(),
            'todo_id[$i][priority_id]': _selectedPriority?.id.toString() ?? widget.todoData?.priorityId.toString() ?? "",
            'todo_id[$i][user_id]': newUsers[i].id.toString(),
            'add_member[$i][assign_todo_id]': widget.todoData!.id.toString(),
            'add_member[$i][assign_user_id]': newUsers[i].id.toString(),
          });
        }
      }


      showMessage("Body Data ==> $body");
      // return;

      var response = await TodoRepository().todoTaskCommentStore(
        body: body,
        isNewMember: newUsers.isNotEmpty ? 1 : 0
      );

      if (response.success!) {
        AppGlobals.showMessage(response.message!, MessageType.success);
        isLoading = false;
        setState(() {});
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimen.screenPadding),
          child: Form(
            key: _formKeyAddTodo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.todoData == null) mainFields(),
                if (widget.todoData != null) buildTodoItemCard(widget.todoData!),
                if (widget.todoData != null) const FieldSpace(),
                TextFormField(
                  controller: _txtRemindDateController,
                  decoration: const InputDecoration(
                    labelText: AppString.remindDate,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    _selectReminderDate();
                  },
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true);
                    // if (!isValid) {
                    //   return AppString.selectNextDate;
                    // }
                    return null;
                  },
                ),
                const FieldSpace(),
                TextFormField(
                  controller: _txtRemindTimeController,
                  decoration: const InputDecoration(
                    labelText: AppString.remindTime,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    _selectReminderTime(context);
                  },
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true);
                    // if (!isValid) {
                    //   return AppString.selectNextTime;
                    // }
                    return null;
                  },
                ),
                const FieldSpace(),
                TextFormField(
                  controller: _txtCommentFirstController,
                  decoration: const InputDecoration(
                    labelText: AppString.comment,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true, ValidationType.none);
                    // if (!isValid) {
                    //   return AppString.enterCommentFirst;
                    // }
                    return null;
                  },
                ),
                // if (widget.todoData != null) const FieldSpace(),
                // if (widget.todoData != null)
                //   TextFormField(
                //     controller: _txtCommentSecondController,
                //     decoration: const InputDecoration(
                //       labelText: AppString.commentSecond,
                //     ),
                //     textInputAction: TextInputAction.next,
                //     keyboardType: TextInputType.text,
                //     validator: (value) {
                //       bool isValid = Validations.validateInput(value, true, ValidationType.none);
                //       if (!isValid) {
                //         return AppString.enterCommentSecond;
                //       }
                //       return null;
                //     },
                //   ),
                const FieldSpace(),
                if (widget.todoData == null)
                DropdownButtonFormField2<PriorityResponse>(
                  value: _selectedPriority,
                  items: _dropdownPriority,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: AppString.priority,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimen.textRadius),
                      color: Colors.white,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return AppString.selectPriority;
                    }
                    return null;
                  },
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      _txtSearchPriorityController.clear();
                    }
                  },
                  dropdownSearchData: DropdownSearchData(
                    searchController: _txtSearchPriorityController,
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
                        controller: _txtSearchPriorityController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimen.padding,
                            vertical: AppDimen.paddingSmall,
                          ),
                          hintText: AppString.searchForPriority,
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn:
                        (DropdownMenuItem<PriorityResponse>? item, searchValue) {
                      return item!.value!.priority!.toLowerCase().contains(searchValue);
                    },
                  ),
                ),
                if (widget.todoData == null)
                const FieldSpace(),
               /* if (widget.todoData != null && selectedFiles.isEmpty)
                  Btn.basic(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.primary, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height! * 0.06,
                    onPressed: () async {
                      // chooseAndUploadFile(context);
                      FilePickerResult? result = await pickMultipleFile();
                      if (result == null) {
                        AppGlobals.showMessage(
                          AppString.noFileSelected,
                          MessageType.error,
                        );
                        return;
                      } else {
                        selectedFiles = result.paths.map((path) => File(path!)).toList();
                        showMessage("Selected files ==> $selectedFiles");
                        // lengthNotify.value = selectedFiles.length;
                      }
                    },
                    child: const Text(
                      AppString.selectFiles,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (widget.todoData != null && selectedFiles.isEmpty)
                const FieldSpace(),
                if (selectedFiles.isNotEmpty)
                  Container(
                    height: 100,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: selectedFiles.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) => const FieldSpace(SpaceType.extraSmall),
                      itemBuilder: (context, index) {
                        final filePath = selectedFiles[index];
                        final extension =
                        AppGlobals.getExtensionTypes(AppGlobals.getFileExtension(filePath.path));

                        if (extension == ExtensionType.jpeg ||
                            extension == ExtensionType.jpg ||
                            extension == ExtensionType.png) {
                          return buildReturnImageView(filePath, index);
                        } else {
                          return FutureBuilder(
                            future: AppGlobals.getVideoThumbnail(filePath),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Container();
                              } else if (snapshot.hasData) {
                                return buildReturnImageView(File(snapshot.data!), index);
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                const FieldSpace(),*/
                if(widget.todoData != null && !isAddMember && widget.todoData!.userId == AppGlobals.user!.id)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimen.paddingSmall,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () async {
                    if(isAddMember){
                      isAddMember = false;
                    } else {
                      isAddMember = true;
                    }
                    setState(() {

                    });
                  },
                  child: const Text(
                    AppString.addMember,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
                if(widget.todoData != null && isAddMember && widget.todoData!.userId == AppGlobals.user!.id)
                DropdownButtonFormField2<RolesData>(
                  value: _selectedRoles,
                  items: _dropdownRoles,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedRoles = value;
                    });
                    fetchRolesUser();
                  },
                  decoration: const InputDecoration(
                    labelText: AppString.selectCategory,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimen.textRadius),
                      color: Colors.white,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return AppString.selectCategory;
                    }
                    return null;
                  },
                ),
                if(widget.todoData != null && isAddMember && widget.todoData!.userId == AppGlobals.user!.id)
                const FieldSpace(),
                if(widget.todoData != null && isAddMember && widget.todoData!.userId == AppGlobals.user!.id)
                DropdownButtonFormField2(
                  // value: _selectedUser,
                  // items: _dropdownAllUser,
                  value: selectedAddMember.isEmpty ? null : selectedAddMember.last,
                    items: allUserList
                        .where((item) => selectedAddMember.contains(item)) // Selected items
                        .toList()
                        .followedBy(
                          allUserList.where((item) => !selectedAddMember.contains(item)), // Unselected items
                        )
                        .map(
                      (item) {
                        return DropdownMenuItem(
                      value: item,
                      child: Row(
                        children: [
                          StatefulBuilder(
                              builder: (context, menuSetState) {
                                return Checkbox(
                                  value: selectedAddMember.contains(item),
                                  onChanged: /*selectedAddMember.contains(item) // Disable if already selected
                                      ? null // Prevent interaction
                                      :*/
                                      (bool? checked) {
                                    if (checked != null) {
                                      menuSetState(() {
                                        if (checked) {
                                          // if (widget.todoData!.todoAssignUsers!.length == selectedAddMember.length) {
                                            selectedAddMember.add(item);
                                          // } else {
                                          //   AppGlobals.showMessage(
                                          //       "At a time you will be add one member", MessageType.error);
                                          // }
                                        } else {
                                          selectedAddMember.remove(item);
                                        }
                                      });
                                      setState(() {});
                                    }
                                  },
                                  checkColor: Colors.white, // Color of the checkmark inside the checkbox
                                  activeColor:  AppColors.primary, // Color of the checkbox border when unchecked
                                  shape: const RoundedRectangleBorder(),
                                );
                              }
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  item.name!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },).toList(),
                  selectedItemBuilder: (context) {
                    return allUserList.map(
                          (item) {
                        return Container(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            selectedAddMember.map((e) => e.name).toList().join(', '),
                            style: const TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        );
                      },
                    ).toList();
                  },
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: AppString.leadAssign,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.zero,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: MediaQuery.of(context).size.height * 0.64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimen.textRadius),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                  ),
                  onChanged: (value) {
                    // setState(() {
                    //   _selectedUser = value;
                    // });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppString.selectLeadUser;
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
                          hintText: AppString.searchForName,
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (DropdownMenuItem<UserResponse>? item, searchValue) {
                      return item!.value!.name!.toLowerCase().contains(searchValue);
                    },
                  ),
                ),
                const FieldSpace(),
                if(widget.todoData == null)
                Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: isLoading ? null : addTodoData,
                            text: AppString.submit,
                          ),
                        ),
                      ],
                    ),
                    if (isLoading) const ButtonLoader(),
                  ],
                ),
                if(widget.todoData != null)
                Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: isLoading ? null : addTodoTaskComment,
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

  mainFields() {
    return Column(
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
        const FieldSpace(),
        TextFormField(
          controller: _txtTitleController,
          decoration: const InputDecoration(
            labelText: AppString.title,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          validator: (value) {
            bool isValid = Validations.validateInput(value, true, ValidationType.none);
            if (!isValid) {
              return AppString.enterTitle;
            }
            return null;
          },
        ),
        const FieldSpace(),
        TextFormField(
          controller: _txtDescriptionController,
          decoration: const InputDecoration(
            labelText: AppString.description,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          validator: (value) {
            bool isValid = Validations.validateInput(value, true, ValidationType.none);
            if (!isValid) {
              return AppString.enterDescription;
            }
            return null;
          },
        ),
        const FieldSpace(),
        DropdownButtonFormField2<RolesData>(
          value: _selectedRoles,
          items: _dropdownRoles,
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedRoles = value;
            });
            selectedUsers.clear();
            fetchRolesUser();
          },
          decoration: const InputDecoration(
            labelText: AppString.selectCategory,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimen.textRadius),
              color: Colors.white,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return AppString.selectCategory;
            }
            return null;
          },
        ),
        const FieldSpace(),
        DropdownButtonFormField2(
          // value: _selectedUser,
          // items: _dropdownAllUser,
          value: selectedUsers.isEmpty ? null : selectedUsers.last,
          items: allUserList.map((item) {
            return DropdownMenuItem(
              value: item,
              // label: item.name,
              child: Row(
                children: [
                  StatefulBuilder(
                      builder: (context, menuSetState) {
                        return Checkbox(
                          value: selectedUsers.contains(item),
                          onChanged: (bool? checked) {
                            if (checked != null) {
                              menuSetState(() {
                                if (checked) {
                                    selectedUsers.add(item);
                                } else {
                                  selectedUsers.remove(item);
                                }
                              });
                              setState((){});
                            }
                          },
                          checkColor: Colors.white, // Color of the checkmark inside the checkbox
                          activeColor:  AppColors.primary, // Color of the checkbox border when unchecked
                          shape: const RoundedRectangleBorder(),
                        );
                      }
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          item.name!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },).toList(),
          selectedItemBuilder: (context) {
            return allUserList.map(
                  (item) {
                return Container(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    selectedUsers.map((e) => e.name).toList().join(', '),
                    style: const TextStyle(
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                );
              },
            ).toList();
          },
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: AppString.leadAssign,
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: MediaQuery.of(context).size.height * 0.64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimen.textRadius),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
          ),
          onChanged: (value) {
            // setState(() {
            //   _selectedUser = value;
            // });
          },
          validator: (value) {
            if (value == null) {
              return AppString.selectLeadUser;
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
                  hintText: AppString.searchForName,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (DropdownMenuItem<UserResponse>? item, searchValue) {
              return item!.value!.name!.toLowerCase().contains(searchValue);
            },
          ),
        ),
        const FieldSpace(),
      ],
    );
  }

  Card buildTodoItemCard(GetTodoData todoData) {

    showMessage("todoData ==> ${widget.todoData!.todoAssignUsers!}");
    // TodoAssignUser? userDetails;

    // if(widget.todoData!.todoAssignUsers!.any((element) => element.assignUserDetail!.id != AppGlobals.user!.id)) {
    TodoAssignUser userDetails =
      widget.todoData!.todoAssignUsers!.firstWhere((element) {
        showMessage("element.assignUserDetail!.id ==> ${element.assignUserDetail!.id == AppGlobals.user!.id}");
        return element.assignUserDetail!.id == AppGlobals.user!.id;
      }, orElse: () => TodoAssignUser());
    // }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimen.textRadius),
      ),
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimen.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        "Todo No",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${todoData.id!}",
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        AppString.dateTime,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppGlobals.convertTo12HourDateTimeFormat(todoData.assignDateTime!),
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        "Title",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        todoData.title!,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        todoData.description!,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        "Assign to",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        userDetails != null && userDetails.assignUserDetail != null ? userDetails.assignUserDetail!.name! : AppGlobals.user!.name!,
                        // /*userDetails == null ? todoData.todoAssignUsers!.map((e) => e.assignUserDetail!.name).join(", ") :*/ userDetails.assignUserDetail!.name!,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        AppString.priority,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      child: Text(
                        ":",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        todoData.todoTasks!.last.priorityResponse!.priority!,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          // color: AppGlobals().getStatus(complainData.statusId).toLowerCase() ==
                          //     "pending"
                          //     ? Colors.red
                          //     : AppGlobals().getStatus(complainData.statusId).toLowerCase() ==
                          //     "in progress"
                          //     ? Colors.purple
                          //     : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                // if(todoData.todoTasks!.first.date != null && todoData.todoTasks!.first.time != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Reminder Date/Time",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "${todoData.todoTasks!.last.date} ${AppGlobals.convertTo12HourFormat(todoData.todoTasks!.last.time!)}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                // if (todoData.todoTasks!.first.commentFirst != null)
                  /*Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Comment",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          todoData.todoTasks!.last.commentFirst ?? "-",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),*/
                ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: todoData.todoTasks!.length,
                  separatorBuilder: (context, index) {
                    return const FieldSpace(SpaceType.small);
                  },
                  itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          // "Comment",
                          "${todoData.todoTasks![index].todoTaskUser!.name!} comment",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          todoData.todoTasks![index].commentFirst ?? "-",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  );
                },),
                // if (todoData.todoTasks!.isNotEmpty)
                //   Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Expanded(
                //         child: Text(
                //           "Comment 2",
                //           style: TextStyle(
                //             color: Colors.black,
                //             fontSize: 13,
                //           ),
                //         ),
                //       ),
                //       const Padding(
                //         padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                //         child: Text(
                //           ":",
                //           style: TextStyle(
                //             color: Colors.black,
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         flex: 2,
                //         child: Text(
                //           todoData.todoTasks!.first.commentSecond!,
                //           maxLines: 2,
                //           style: const TextStyle(
                //             color: Colors.black,
                //             fontSize: 13,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
          /* Positioned(
            right: 0.0,
            top: 0.0,
            child: showOptions(listIndex: index, context: context),
          ),*/
        ],
      ),
    );
  }

  Widget buildReturnImageView(File filePath, int index) {
    return Stack(
      children: [
        Image.file(filePath, width: 80, height: 80,),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () {
              selectedFiles.removeAt(index);
              setState(() {});
            },
            child: Card(
              color: Colors.white,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<PriorityResponse>> buildDropdownPriorityItems(List<PriorityResponse> priorityList) {
    List<DropdownMenuItem<PriorityResponse>> items = [];
    for (PriorityResponse item in priorityList as Iterable<PriorityResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.priority!.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<UserResponse>> buildDropdownUserItems(List<UserResponse> userList) {
    List<DropdownMenuItem<UserResponse>> items = [];
    for (UserResponse item in userList as Iterable<UserResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<RolesData>> buildDropdownRolesItems(List<RolesData> roleList) {
    List<DropdownMenuItem<RolesData>> items = [];
    for (RolesData item in roleList as Iterable<RolesData>) {
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
