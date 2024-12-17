import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/global_models.dart';
import 'package:omsatya/models/roles/roles_response.dart';
import 'package:omsatya/models/todo/add_todo_team_response.dart';
import 'package:omsatya/models/todo/get_todo_all_data.dart';
import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/models/todo/todo_filter_response.dart';
import 'package:omsatya/models/todo/todo_task.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/repository/auth_repository.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/repository/todo_repository.dart';
import 'package:omsatya/screen/todo/add_todo.dart';
import 'package:omsatya/screen/todo/todo_previous_history_pdf.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  final TextEditingController txtTeamNameController = TextEditingController();
  final TextEditingController txtUserNameController = TextEditingController();

  final GlobalKey<FormState> _teamFormKey = GlobalKey<FormState>();

  GetAllTodoData? getAllTodoData;
  GetTodoFilterResponse? getTodoFilter;

  List<GetTodoData> lstTodoData = [];
  List<TodoAssignUserElement> lstTodoAssignUser = [];
  List<GetTodoData> lstUpcomingTodoData = [];
  List<TodoAssignUserElement> lstUpcomingTodoAssignUser = [];
  List<GetTodoData> lstPastTodoData = [];
  List<TodoAssignUserElement> lstPastTodoAssignUser = [];
  List<GetTodoData> lstFilterTodoData = [];
  List<TodoAssignUserElement> lstFilterTodoAssignUser = [];

  List<UserResponse> allUserList = [];
  List<PriorityResponse> priorityList = [];
  List<TodoStatus> statusList = TodoStatus.getDeliveryStatusList();

  List<DropdownMenuItem<PriorityResponse>>? _dropdownPriorityItems;
  List<DropdownMenuItem<TodoStatus>>? _dropdownStatusItems;
  List<DropdownMenuItem<UserResponse>>? _dropdownAllUser;

  PriorityResponse? _selectedPriority;
  TodoStatus? _selectedStatus;
  UserResponse? _selectedUser;

  List<UserResponse> roleUserList = [];
  List<RolesData> rolesList = [];
  List<DropdownMenuItem<UserResponse>>? _dropdownRoleUser;
  List<DropdownMenuItem<RolesData>>? _dropdownRoles;
  UserResponse? _selectedRoleUser;
  RolesData? _selectedRoles;

  int defaultComplainStatusKey = 1;

  bool isInitial = false;
  bool isUpcoming = false;
  bool isPast = false;
  bool isPriority = false;
  bool isDone = false;
  bool isUser = false;
  bool isFilter = false;

  ScrollController scrollController = ScrollController();
  bool isFabExtended = true;

  DateTime? selectedDate;

  List<UserResponse> selectedAddMember = [];

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_toggleFab);
    init();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_toggleFab);
    scrollController.dispose();
    textEditingController.dispose();
    txtDateController.dispose();
    txtUserNameController.dispose();
    txtTeamNameController.dispose();
    super.dispose();
  }

  init() async {
    // await fetchRoles();
    // _dropdownRoles = buildDropdownRolesItems(rolesList);
    //
    // for (int x = 0; x < _dropdownRoles!.length; x++) {
    //   if (_dropdownRoles![x].value!.id == 6) {
    //     _selectedRoles = _dropdownRoles![x].value;
    //   }
    // }
    //
    // await fetchRolesUser();

    await fetchPriorityData();
    if (AppGlobals.user!.roles!.first.id == 2) {
      await fetchAllUser();
    }

    _dropdownPriorityItems = buildDropdownPriorityItems(priorityList);
    _dropdownStatusItems = buildDropdownStatusItems(statusList);
    _dropdownAllUser = buildDropdownUserItems(allUserList);

    // for (int x = 0; x < _dropdownPriorityItems!.length; x++) {
    //   if (_dropdownPriorityItems![x].value!.id == defaultComplainStatusKey) {
    //     _selectedPriority = _dropdownPriorityItems![x].value;
    //   }
    // }

    // for (int x = 0; x < _dropdownPartyNameItems!.length; x++) {
    //   if (_dropdownPartyNameItems![x].value!.id == defaultPartyNameKey) {
    //     _selectedPartyName = _dropdownPartyNameItems![x].value;
    //   }
    // }

    await fetchGetAllTodo();
    // await fetchGetAllUpcomingTodo();
    await fetchGetAllPastTodo();
  }

  void _toggleFab() {
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (isFabExtended) {
        setState(() {
          isFabExtended = false;
        });
      }
    } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!isFabExtended) {
        setState(() {
          isFabExtended = true;
        });
      }
    }
  }

  clearFilter() {
    if(selectedDate != null || _selectedStatus != null || _selectedPriority != null || _selectedUser != null) {
      selectedDate = null;
      _selectedStatus = null;
      _selectedPriority = null;
      txtDateController.clear();
      lstFilterTodoData.clear();
      lstFilterTodoAssignUser.clear();
      getTodoFilter = null;
      _selectedUser = null;
      reset();
    }
  }

  Future<void> resetFilter() async {
    lstTodoData.clear();
    lstTodoAssignUser.clear();
    lstUpcomingTodoData.clear();
    lstUpcomingTodoAssignUser.clear();
    lstPastTodoData.clear();
    lstPastTodoAssignUser.clear();
    fetchFilterTodoData();
  }

  Future<void> reset() async {
    lstTodoData.clear();
    lstTodoAssignUser.clear();
    lstUpcomingTodoData.clear();
    lstUpcomingTodoAssignUser.clear();
    lstPastTodoData.clear();
    lstPastTodoAssignUser.clear();
    _selectedUser = null;
    fetchGetAllTodo();
    // fetchGetAllUpcomingTodo();
    fetchGetAllPastTodo();
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
        roleUserList = response.data!;
        selectedAddMember.clear();

        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {});
    } finally {
      setState(() {});
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

  fetchPriorityData() async {
    try {
      setState(() {
        isPriority = true;
      });

      var response = await TodoRepository().getPriorityResponse(priority: 1, status: 0);

      if (response.success) {
        priorityList = response.data;
        isPriority = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isPriority = false;
      });
    } finally {
      setState(() {
        isPriority = false;
      });
    }
  }

  addTeam() async {
    ProgressDialog progressDialog = ProgressDialog();
    try {
      if (!_teamFormKey.currentState!.validate()) {
        return;
      }

      selectedAddMember.add(AppGlobals.user!);
      List<int> ids = selectedAddMember.map<int>((user) => user.id as int).toList();

      Map<String, dynamic> body = {
        "name": txtTeamNameController.text,
        "users": ids
      };

      var response = await TodoRepository().createTodoTeam(
        body: body
      );


      if (response.statusCode == 201) {
        AddTodoTeamResponse addTodoTeamResponse = addTodoTeamResponseFromJson(response.body);
        AppGlobals.showMessage(jsonDecode(response.body)['message'], MessageType.success);
      } else {
        AppGlobals.showMessage(jsonDecode(response.body)['message'], MessageType.success);
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {

      });
    } finally {
      setState(() {

      });
    }
  }

  fetchFilterTodoData() async {
    try {
      setState(() {
        isFilter = true;
      });

      var response = await TodoRepository().getFilterTodoData(
        date: txtDateController.text.isEmpty ? null : txtDateController.text,
        status: _selectedStatus?.id.toString(),
        priorityId: _selectedPriority?.id.toString(),
        assignUserId: _selectedUser?.id.toString(),
      );

      if (response.success!) {
        getTodoFilter = response;
        lstFilterTodoData = response.data!.todo!;
        lstFilterTodoAssignUser = response.data!.todoAssignUser!;
      } else {
        getTodoFilter = response;
        lstFilterTodoData.clear();
        lstFilterTodoAssignUser.clear();
      }
      isFilter = false;
      setState(() {});
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isFilter = false;
      });
    } finally {
      setState(() {
        isFilter = false;
      });
    }
  }

  fetchGetAllTodo() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await TodoRepository().getTodoDataAll(
        role: AppGlobals.user!.roles!.first.id,
        userId: _selectedUser?.id,
        isToday: 1,
        status: _selectedStatus?.id.toString(),
        priorityId: _selectedPriority?.id.toString(),
      );

      if (response.success!) {
        getAllTodoData = response.data!;
        lstTodoData = response.data!.todo!;
        lstTodoAssignUser = response.data!.todoAssignUser!;
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

  fetchGetAllUpcomingTodo() async {
    try {
      setState(() {
        isUpcoming = true;
      });

      var response = await TodoRepository().getUpcomingTodoData(
        role: AppGlobals.user!.id,
        userId: _selectedUser?.id,
        isUpcoming: 1,
        status: _selectedStatus?.id.toString(),
        priorityId: _selectedPriority?.id.toString(),
      );

      if (response.success!) {
        getAllTodoData = response.data!;
        lstUpcomingTodoData = response.data!.todo!;
        lstUpcomingTodoAssignUser = response.data!.todoAssignUser!;
        isUpcoming = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isUpcoming = false;
      });
    } finally {
      setState(() {
        isUpcoming = false;
      });
    }
  }

  fetchGetAllPastTodo() async {
    try {
      setState(() {
        isPast = true;
      });

      var response = await TodoRepository().getPastTodoData(
        role: AppGlobals.user!.id,
        userId: _selectedUser?.id,
        isPast: 1,
        status: _selectedStatus?.id.toString(),
        priorityId: _selectedPriority?.id.toString(),
      );

      if (response.success!) {
        getAllTodoData = response.data!;
        lstPastTodoData = response.data!.todo!;
        lstPastTodoAssignUser = response.data!.todoAssignUser!;
        isPast = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isPast = false;
      });
    } finally {
      setState(() {
        isPast = false;
      });
    }
  }

  _deleteTodo(BuildContext context, int? todoId) async {
    try {
      var response = await TodoRepository().deleteTodoDataById(todoId: todoId);

      if (response.status) {
        Navigator.pop(context);
        AppGlobals.showMessage(response.message, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  updateTodoTaskIsDone(BuildContext context, int? todoId, int? status, {bool? isBack}) async {
    try {
      var response = await TodoRepository().updateTodoStatusById(todoId: todoId, status: status);

      if (response.status!) {
        if (isBack != null) {
          Navigator.pop(context);
        }
        AppGlobals.showMessage(response.message!, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  favouriteTodo(int? todoId, int? status) async {
    try {
      var response = await TodoRepository().todoFavouriteResponse(todoId: todoId, status: status);

      if (response.status!) {
        AppGlobals.showMessage(response.message!, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        txtDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        resetFilter();
      });
    }
  }

  _tabOption(int index, listIndex, context, GetTodoData todoData) async {
    switch (index) {
      case 0:
        AppGlobals.navigate(
          context,
          TodoPreviousHistoryPDF(todoId: todoData.id),
          false,
        );
        break;
      case 1:
        showDeleteDialog(todoId: todoData.id);
        break;
      case 2:
        showUpdateStatusDialog(todoId: todoData.id, status: todoData.status == 0 ? 1 : 0);
        // if(todoData.status == 0){
        //   showUpdateStatusDialog(todoId: todoData.id);
        // } else {
        //   return;
        // }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     bool? result = await AppGlobals.navigateAndReturn(context, const AddTodo(), false);
      //     if (result != null && result) reset();
      //   },
      //   label: const Text(AppString.addTodo),
      //   icon: const Icon(Icons.add),
      // ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isFabExtended ? 160.0 : 56.0,
        height: 56.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            bool? result = await AppGlobals.navigateAndReturn(context, const AddTodo(), false);
            if (result != null && result) reset();
          },
          isExtended: isFabExtended,
          label: isFabExtended ? const Column(
            children: [
              Text(AppString.addTodo),
            ],
          ) : Container(),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => reset(),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppDimen.paddingSmall),
            child: ListView(
              // controller: scrollController,
              shrinkWrap: true,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFilterDropDown(context),
                const FieldSpace(SpaceType.small),
                isFilter
                    ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: ShimmerHelper().buildListShimmer(
                    itemCount: 6,
                    itemHeight: 120.0,
                  ),
                )
                    : SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (lstFilterTodoData.isNotEmpty)
                      //   const Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                      //     child: Text(
                      //       "Created",
                      //       style: TextStyle(
                      //         color: Colors.grey,
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // if (lstFilterTodoData.isNotEmpty) const FieldSpace(SpaceType.small),
                      ListView.separated(
                        separatorBuilder: (context, index) {
                          return const FieldSpace(SpaceType.small);
                        },
                        itemCount: lstFilterTodoData.length,
                        scrollDirection: Axis.vertical,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return buildFilterTodoItemCard(index, lstFilterTodoData[index], false);
                        },
                      ),
                      const FieldSpace(SpaceType.small),
                      // if (lstFilterTodoAssignUser.isNotEmpty)
                      //   const Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                      //     child: Text(
                      //       "Assigned",
                      //       style: TextStyle(
                      //         color: Colors.grey,
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // if (lstFilterTodoAssignUser.isNotEmpty) const FieldSpace(SpaceType.small),
                      ListView.separated(
                        separatorBuilder: (context, index) {
                          return const FieldSpace(SpaceType.small);
                        },
                        itemCount: lstFilterTodoAssignUser.length,
                        scrollDirection: Axis.vertical,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (lstFilterTodoAssignUser[index].todoDetail!.userId == AppGlobals.user!.id) {
                            return const SizedBox();
                          }
                          return buildFilterTodoItemCard(
                              index, lstFilterTodoAssignUser[index].todoDetail!, true);
                        },
                      ),
                    ],
                  ),
                ),
                if(getTodoFilter != null && !getTodoFilter!.success!)
                  const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        AppString.noTodoAssign,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                // if(lstFilterTodoData.isNotEmpty || lstFilterTodoAssignUser.isNotEmpty)
                // buildFilterTodoList(),
                if(getTodoFilter == null)
                  const Text(
                    "Today",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if(getTodoFilter == null)
                  const FieldSpace(SpaceType.small),
                if(getTodoFilter == null)
                  buildTodoList(),
                /*const FieldSpace(SpaceType.small),
                    const Text(
                      "UpComing",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const FieldSpace(SpaceType.small),
                    buildUpComingTodoList(),*/
                if(getTodoFilter == null)
                  const FieldSpace(SpaceType.small),
                if(getTodoFilter == null)
                  const Text(
                    "Past",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if(getTodoFilter == null)
                  const FieldSpace(SpaceType.small),
                if(getTodoFilter == null)
                  buildPastTodoList(),
              ],
            ),
            // child: Stack(
            //   children: [
            //     Positioned(
            //       bottom: 0,
            //       child: InkWell(
            //         onTap: () {
            //           showAddTeamDialog();
            //         },
            //         child: const Padding(
            //           padding: EdgeInsets.symmetric(vertical: AppDimen.paddingSmall, horizontal: AppDimen.paddingSmall),
            //           child: Row(
            //             children: [
            //               Icon(Icons.add_rounded),
            //               FieldSpace(SpaceType.medium),
            //               Text("New Team"),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView buildFilterDropDown(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppString.date,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const FieldSpace(SpaceType.extraSmall),
              Container(
                height: MediaQuery.of(context).size.height * 0.046,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimen.textRadius),
                ),
                child: TextFormField(
                  controller: txtDateController,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: AppString.selectDate,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    _selectDate();
                  },
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true);
                    // if (!isValid) {
                    //   return AppString.selectDate;
                    // }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isUser
                  ? ShimmerHelper().buildBasicShimmer(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.height * 0.015,
                  radius: 4)
                  : const Text(
                AppString.user,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const FieldSpace(SpaceType.extraSmall),
              isUser
                  ? ShimmerHelper().buildBasicShimmer(
                  width: MediaQuery.of(context).size.width * 0.52,
                  height: MediaQuery.of(context).size.height * 0.048,
                  radius: AppDimen.textRadius)
                  : SizedBox(
                height: MediaQuery.of(context).size.height * 0.048,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<UserResponse>(
                    isExpanded: true,
                    hint: Text(
                      AppString.selectUser,
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
                      width: MediaQuery.of(context).size.width * 0.52,
                      maxHeight: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimen.textRadius),
                        color: Colors.white,
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      width: MediaQuery.of(context).size.width * 0.52,
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
                      height: MediaQuery.of(context).size.height * 0.045,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                    ),
                    value: _selectedUser,
                    items: _dropdownAllUser,
                    onChanged: (UserResponse? userResponse) {
                      setState(() {
                        _selectedUser = userResponse;
                      });
                      resetFilter();
                    },
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingController.clear();
                      }
                    },
                    dropdownSearchData: DropdownSearchData(
                      searchController: textEditingController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: textEditingController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: AppString.searchForUser,
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value!.name!.toLowerCase().contains(searchValue);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPriority
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.priority,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isPriority
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.048,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.048,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<PriorityResponse>(
                          isExpanded: true,
                          hint: Text(
                            AppString.selectPriority,
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
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
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
                            height: MediaQuery.of(context).size.height * 0.05,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedPriority,
                          items: _dropdownPriorityItems,
                          onChanged: (PriorityResponse? selectedPriority) {
                            setState(() {
                              _selectedPriority = selectedPriority;
                            });
                            resetFilter();
                          },
                        ),
                      ),
                    ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDone
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.status,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isDone
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.048,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.048,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<TodoStatus>(
                          hint: Text(
                            AppString.selectStatus,
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
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
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
                            height: MediaQuery.of(context).size.height * 0.05,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedStatus,
                          items: _dropdownStatusItems,
                          onChanged: (TodoStatus? selectedStatus) {
                            setState(() {
                              _selectedStatus = selectedStatus;
                            });
                            resetFilter();
                          },
                        ),
                      ),
                    ),
            ],
          ),
          /* if (AppGlobals.user!.roles!.first.id == 2) const FieldSpace(SpaceType.small),
          if (AppGlobals.user!.roles!.first.id == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isUser
                    ? ShimmerHelper().buildBasicShimmer(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.015,
                        radius: 4)
                    : const Text(
                        AppString.user,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                const FieldSpace(SpaceType.extraSmall),
                isUser
                    ? ShimmerHelper().buildBasicShimmer(
                        width: MediaQuery.of(context).size.width * 0.56,
                        height: MediaQuery.of(context).size.height * 0.045,
                        radius: AppDimen.textRadius)
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.045,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<UserResponse>(
                            hint: Text(
                              AppString.selectUser,
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
                              width: MediaQuery.of(context).size.width * 0.56,
                              maxHeight: MediaQuery.of(context).size.height / 1.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                                color: Colors.white,
                              ),
                            ),
                            buttonStyleData: ButtonStyleData(
                              width: MediaQuery.of(context).size.width * 0.56,
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
                              height: MediaQuery.of(context).size.height * 0.045,
                              padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                            ),
                            value: _selectedUser,
                            items: _dropdownAllUser,
                            isExpanded: true,
                            onChanged: (UserResponse? selectedFilter) {
                              setState(() {
                                _selectedUser = selectedFilter;
                              });
                              reset();
                            },
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                textEditingController.clear();
                              }
                            },
                            dropdownSearchData: DropdownSearchData(
                              searchController: textEditingController,
                              searchInnerWidgetHeight: 50,
                              searchInnerWidget: Container(
                                height: 50,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                  right: 8,
                                  left: 8,
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: textEditingController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: AppString.searchForName,
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value!.name!.toLowerCase().contains(searchValue);
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),*/
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppString.clear,
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => clearFilter(),
                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                highlightColor: AppColors.primary.withOpacity(0.2),
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.045,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                  child: Text(
                    AppString.clear,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildFilterTodoList() {
    if (isFilter && (lstFilterTodoData.isEmpty || lstFilterTodoAssignUser.isEmpty)) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 6,
          itemHeight: 120.0,
        ),
      );
    } else if (lstFilterTodoData.isNotEmpty || lstFilterTodoAssignUser.isNotEmpty) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (lstFilterTodoData.isNotEmpty)
            //   const Padding(
            //     padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
            //     child: Text(
            //       "Created",
            //       style: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // if (lstFilterTodoData.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstFilterTodoData.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildFilterTodoItemCard(index, lstFilterTodoData[index], false);
              },
            ),
            const FieldSpace(SpaceType.small),
            // if (lstFilterTodoAssignUser.isNotEmpty)
            //   const Padding(
            //     padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
            //     child: Text(
            //       "Assigned",
            //       style: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // if (lstFilterTodoAssignUser.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstFilterTodoAssignUser.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (lstFilterTodoAssignUser[index].todoDetail!.userId == AppGlobals.user!.id) {
                  return const SizedBox();
                }
                return buildFilterTodoItemCard(index, lstFilterTodoAssignUser[index].todoDetail!, true);
              },
            ),
          ],
        ),
      );
    } else if (!isFilter && (lstFilterTodoData.isEmpty || lstFilterTodoAssignUser.isEmpty)) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noTodoAssign,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  buildTodoList() {
    if (isInitial && (lstTodoData.isEmpty || lstTodoAssignUser.isEmpty)) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 2,
          itemHeight: 120.0,
        ),
      );
    } else if (lstTodoData.isNotEmpty || lstTodoAssignUser.isNotEmpty) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lstTodoData.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  "Created",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lstTodoData.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstTodoData.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildTodoItemCard(index, lstTodoData[index], false);
              },
            ),
            const FieldSpace(SpaceType.small),
            if (lstTodoAssignUser.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  "Assigned",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lstTodoAssignUser.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstTodoAssignUser.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (lstTodoAssignUser[index].todoDetail!.userId == AppGlobals.user!.id) {
                  return const SizedBox();
                }
                return buildTodoItemCard(index, lstTodoAssignUser[index].todoDetail!, true);
              },
            ),
          ],
        ),
      );
    } else if (!isInitial && (lstTodoData.isEmpty || lstTodoAssignUser.isEmpty)) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noTodoAssign,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  buildUpComingTodoList() {
    if (isUpcoming && (lstUpcomingTodoData.isEmpty || lstUpcomingTodoAssignUser.isEmpty)) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 2,
          itemHeight: 120.0,
        ),
      );
    } else if (lstUpcomingTodoData.isNotEmpty || lstUpcomingTodoAssignUser.isNotEmpty) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lstUpcomingTodoData.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  "Created",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lstUpcomingTodoData.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstUpcomingTodoData.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildUpcomingTodoItemCard(index, lstUpcomingTodoData[index], false);
              },
            ),
            const FieldSpace(SpaceType.small),
            if (lstUpcomingTodoAssignUser.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  "Assigned",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lstUpcomingTodoAssignUser.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstUpcomingTodoAssignUser.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (lstUpcomingTodoAssignUser[index].todoDetail!.userId == AppGlobals.user!.id) {
                  return const SizedBox();
                }
                return buildUpcomingTodoItemCard(index, lstUpcomingTodoAssignUser[index].todoDetail!, true);
              },
            ),
          ],
        ),
      );
    } else if (!isUpcoming && (lstUpcomingTodoData.isEmpty || lstUpcomingTodoAssignUser.isEmpty)) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noTodoAssign,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  buildPastTodoList() {
    if (isPast && (lstPastTodoData.isEmpty || lstPastTodoAssignUser.isEmpty)) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 2,
          itemHeight: 120.0,
        ),
      );
    } else if (lstPastTodoData.isNotEmpty || lstPastTodoAssignUser.isNotEmpty) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lstPastTodoData.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  "Created",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lstPastTodoData.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstPastTodoData.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildPastTodoItemCard(index, lstPastTodoData[index], false);
              },
            ),
            const FieldSpace(SpaceType.small),
            if (lstPastTodoAssignUser.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  "Assigned",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (lstPastTodoAssignUser.isNotEmpty) const FieldSpace(SpaceType.small),
            ListView.separated(
              separatorBuilder: (context, index) {
                return const FieldSpace(SpaceType.small);
              },
              itemCount: lstPastTodoAssignUser.length,
              scrollDirection: Axis.vertical,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (lstPastTodoAssignUser[index].todoDetail!.userId == AppGlobals.user!.id) {
                  return const SizedBox();
                }
                return buildPastTodoItemCard(index, lstPastTodoAssignUser[index].todoDetail!, true);
              },
            ),
          ],
        ),
      );
    } else if (!isPast && (lstPastTodoData.isEmpty || lstPastTodoAssignUser.isEmpty)) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noTodoAssign,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  buildFilterTodoItemCard(index, GetTodoData todoData, bool isAssignUserTodo) {
    DateTime dateTime = DateTime.parse(todoData.assignDateTime!);
    DateFormat formatter = DateFormat('E, d MMM, y');
    String formattedDate = formatter.format(dateTime);

    return GestureDetector(
      onTap: () async {
        // bool? result;
        // if (isAssignUserTodo) {
        //   result = lstFilterTodoAssignUser[index]
        //       .todoDetail!
        //       .todoAssignUsers
        //       ?.any((element) => element.assignUserId == AppGlobals.user!.id);
        // } else {
        //   result = lstFilterTodoData[index].todoAssignUsers!.any((element) => element.assignUserId == AppGlobals.user!.id);
        // }
        // if (result!) {
          // if (todoData.status != 1) {
          bool result = await AppGlobals.navigateAndReturn(
            context,
            AddTodo(todoData: todoData),
            false,
          );
          if (result) reset();
          // } else {
          //   AppGlobals.showMessage("After status done you can't update this record.", MessageType.error);
          // }
        // }
      },
      onLongPress: () {
        showDeleteDialog(todoId: todoData.id);
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3), // Adjust the offset as needed
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
          clipBehavior: Clip.hardEdge,
          child: ExpansionPanelList(
            elevation: 1,
            expansionCallback: (int itemIndex, bool isExpanded) {
              if (isAssignUserTodo) {
                if (lstFilterTodoAssignUser[index].todoDetail!.isExpanded) {
                  lstFilterTodoAssignUser[index].todoDetail!.isExpanded = false;
                } else {
                  lstFilterTodoAssignUser[index].todoDetail!.isExpanded = true;
                }
              } else {
                if (lstFilterTodoData[index].isExpanded) {
                  lstFilterTodoData[index].isExpanded = false;
                } else {
                  lstFilterTodoData[index].isExpanded = true;
                }
              }
              setState(() {});
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: todoData.status == 0 ? false : true,
                            onChanged: (value) {
                              if (todoData.userId == AppGlobals.user!.id) {
                               updateTodoTaskIsDone(context, todoData.id, todoData.status == 0 ? 1 : 0);
                              } else {
                                AppGlobals.showMessage(
                                    "Only the user who created the task can mark it as completed.", MessageType.error);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${todoData.title!} (${todoData.description!})",
                                maxLines: 2,
                                style: TextStyle(
                                  decoration: todoData.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const FieldSpace(SpaceType.extraSmall),
                                  Text(
                                    formattedDate,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              // if (todoData.priority != null)
                              //   Row(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const Text(
                              //         AppString.priority,
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 12,
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
                              //       Text(
                              //         todoData.priority!.priority!,
                              //         maxLines: 2,
                              //         style: const TextStyle(
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // const FieldSpace(SpaceType.extraSmall),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     RichText(
                              //       text: TextSpan(
                              //         text: "Assigned By: ",
                              //         style: const TextStyle(
                              //           fontSize: 10,
                              //           color: Colors.black,
                              //         ),
                              //         children: [
                              //           TextSpan(
                              //             text: todoData.todoUser!.name!,
                              //             style: const TextStyle(
                              //               fontSize: 10,
                              //               color: AppColors.primary,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //     // GestureDetector(
                              //     //   onTap: () {
                              //     //       favouriteTodo(todoData.id, todoData.favorite == 0 ? 1 : 0);
                              //     //   },
                              //     //   child: Icon(
                              //     //     todoData.favorite == 1 ? Icons.star_rounded : Icons.star_border_rounded,
                              //     //     color: AppColors.primary,
                              //     //   ),
                              //     // ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                body: Stack(
                  children: [
                    Column(
                      children: [
                        if (todoData.priority != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppString.priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
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
                                Text(
                                  todoData.priority!.priority!,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const FieldSpace(SpaceType.extraSmall),
                        ListView.builder(
                          itemCount: todoData.todoAssignUsers!.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (context, subIndex) {
                            TodoAssignUser assignUser = todoData.todoAssignUsers![subIndex];

                            TodoTask todoTask = todoData.todoTasks!.lastWhere((element) {
                              return element.userId == assignUser.assignUserId;
                            });

                            return buildCommentSection(todoTask, todoData, index);
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: showOptions(listIndex: index, context: context, todoData: todoData),
                    ),
                  ],
                ),
                isExpanded:
                isAssignUserTodo ? lstFilterTodoAssignUser[index].todoDetail!.isExpanded : lstFilterTodoData[index].isExpanded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildTodoItemCard(index, GetTodoData todoData, bool isAssignUserTodo) {
    DateTime dateTime = DateTime.parse(todoData.assignDateTime!);
    DateFormat formatter = DateFormat('E, d MMM, y');
    String formattedDate = formatter.format(dateTime);

    return GestureDetector(
      onTap: () async {
        // bool? result;
        // if (isAssignUserTodo) {
        //   result = lstTodoAssignUser[index]
        //       .todoDetail!
        //       .todoAssignUsers
        //       ?.any((element) => element.assignUserId == AppGlobals.user!.id);
        // } else {
        //   result = lstTodoData[index].todoAssignUsers!.any((element) => element.assignUserId == AppGlobals.user!.id);
        // }
        // if (result!) {
          // if (todoData.status != 1) {
          bool result = await AppGlobals.navigateAndReturn(
            context,
            AddTodo(todoData: todoData),
            false,
          );
          if (result) reset();
          // } else {
          //   AppGlobals.showMessage("After status done you can't update this record.", MessageType.error);
          // }
        // }
      },
      onLongPress: () {
        showDeleteDialog(todoId: todoData.id);
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3), // Adjust the offset as needed
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
          clipBehavior: Clip.hardEdge,
          child: ExpansionPanelList(
            elevation: 1,
            expansionCallback: (int itemIndex, bool isExpanded) {
              if (isAssignUserTodo) {
                if (lstTodoAssignUser[index].todoDetail!.isExpanded) {
                  lstTodoAssignUser[index].todoDetail!.isExpanded = false;
                } else {
                  lstTodoAssignUser[index].todoDetail!.isExpanded = true;
                }
              } else {
                if (lstTodoData[index].isExpanded) {
                  lstTodoData[index].isExpanded = false;
                } else {
                  lstTodoData[index].isExpanded = true;
                }
              }
              setState(() {});
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: todoData.status == 0 ? false : true,
                            onChanged: (value) {
                              if (todoData.userId == AppGlobals.user!.id) {
                                updateTodoTaskIsDone(context, todoData.id, todoData.status == 0 ? 1 : 0);
                              } else {
                                AppGlobals.showMessage(
                                    "Only the user who created the task can mark it as completed.", MessageType.error);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${todoData.title!} (${todoData.description!})",
                                maxLines: 2,
                                style: TextStyle(
                                  decoration: todoData.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_rounded,
                                    color: AppColors.primary,
                                    size: 15,
                                  ),
                                  const FieldSpace(SpaceType.extraSmall),
                                  Text(
                                    formattedDate,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              // if (todoData.priority != null)
                              //   Row(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const Text(
                              //         AppString.priority,
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 12,
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
                              //       Text(
                              //         todoData.priority!.priority!,
                              //         maxLines: 2,
                              //         style: const TextStyle(
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // const FieldSpace(SpaceType.extraSmall),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     RichText(
                              //       text: TextSpan(
                              //         text: "Assigned By: ",
                              //         style: const TextStyle(
                              //           fontSize: 10,
                              //           color: Colors.black,
                              //         ),
                              //         children: [
                              //           TextSpan(
                              //             text: todoData.todoUser!.name!,
                              //             style: const TextStyle(
                              //               fontSize: 10,
                              //               color: AppColors.primary,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //     // GestureDetector(
                              //     //   onTap: () {
                              //     //       favouriteTodo(todoData.id, todoData.favorite == 0 ? 1 : 0);
                              //     //   },
                              //     //   child: Icon(
                              //     //     todoData.favorite == 1 ? Icons.star_rounded : Icons.star_border_rounded,
                              //     //     color: AppColors.primary,
                              //     //   ),
                              //     // ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                body: Stack(
                  children: [
                    Column(
                      children: [
                        if (todoData.priority != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppString.priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
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
                                Text(
                                  todoData.priority!.priority!,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const FieldSpace(SpaceType.extraSmall),
                        ListView.builder(
                          itemCount: todoData.todoAssignUsers!.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (context, subIndex) {
                            TodoAssignUser assignUser = todoData.todoAssignUsers![subIndex];

                            TodoTask todoTask = todoData.todoTasks!.lastWhere((element) {
                              return element.userId == assignUser.assignUserId;
                            });

                            return buildCommentSection(todoTask, todoData, index);
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: showOptions(listIndex: index, context: context, todoData: todoData),
                    ),
                  ],
                ),
                isExpanded:
                    isAssignUserTodo ? lstTodoAssignUser[index].todoDetail!.isExpanded : lstTodoData[index].isExpanded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildUpcomingTodoItemCard(index, GetTodoData todoData, bool isAssignUserTodo) {
    DateTime dateTime = DateTime.parse(todoData.assignDateTime!);
    DateFormat formatter = DateFormat('E, d MMM, y');
    String formattedDate = formatter.format(dateTime);

    return GestureDetector(
      onTap: () async {
        // bool? result;
        // if (isAssignUserTodo) {
        //   result = lstUpcomingTodoAssignUser[index]
        //       .todoDetail!
        //       .todoAssignUsers
        //       ?.any((element) => element.assignUserId == AppGlobals.user!.id);
        // } else {
        //   result =
        //       lstUpcomingTodoData[index].todoAssignUsers!.any((element) => element.assignUserId == AppGlobals.user!.id);
        // }
        // if (result!) {
          // if (todoData.status != 1) {
          bool result = await AppGlobals.navigateAndReturn(
            context,
            AddTodo(todoData: todoData),
            false,
          );
          if (result) reset();
          // } else {
          //   AppGlobals.showMessage("After status done you can't update this record.", MessageType.error);
          // }
        // }
      },
      onLongPress: () {
        showDeleteDialog(todoId: todoData.id);
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3), // Adjust the offset as needed
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
          clipBehavior: Clip.hardEdge,
          child: ExpansionPanelList(
            elevation: 1,
            expansionCallback: (int itemIndex, bool isExpanded) {
              if (isAssignUserTodo) {
                if (lstUpcomingTodoAssignUser[index].todoDetail!.isExpanded) {
                  lstUpcomingTodoAssignUser[index].todoDetail!.isExpanded = false;
                } else {
                  lstUpcomingTodoAssignUser[index].todoDetail!.isExpanded = true;
                }
              } else {
                if (lstUpcomingTodoData[index].isExpanded) {
                  lstUpcomingTodoData[index].isExpanded = false;
                } else {
                  lstUpcomingTodoData[index].isExpanded = true;
                }
              }
              setState(() {});
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: todoData.status == 0 ? false : true,
                            onChanged: (value) {
                              if (todoData.userId == AppGlobals.user!.id) {
                                updateTodoTaskIsDone(context, todoData.id, todoData.status == 0 ? 1 : 0);
                              } else {
                                AppGlobals.showMessage(
                                    "Only the user who created the task can mark it as completed.", MessageType.error);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${todoData.title!} (${todoData.description!})",
                                maxLines: 2,
                                style: TextStyle(
                                  decoration: todoData.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_rounded,
                                    color: AppColors.primary,
                                    size: 15,
                                  ),
                                  const FieldSpace(SpaceType.extraSmall),
                                  Text(
                                    formattedDate,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              if (todoData.priority != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      AppString.priority,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
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
                                    Text(
                                      todoData.priority!.priority!,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              const FieldSpace(SpaceType.extraSmall),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: "Assigned By: ",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: todoData.todoUser!.name!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     favouriteTodo(todoData.id, todoData.favorite == 0 ? 1 : 0);
                                  //   },
                                  //   child: Icon(
                                  //     todoData.favorite == 1 ? Icons.star_rounded : Icons.star_border_rounded,
                                  //     color: AppColors.primary,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                body: Stack(
                  children: [
                    ListView.builder(
                      itemCount: todoData.todoAssignUsers!.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, subIndex) {
                        TodoAssignUser assignUser = todoData.todoAssignUsers![subIndex];

                        TodoTask todoTask = todoData.todoTasks!.lastWhere((element) {
                          return element.userId == assignUser.assignUserId;
                        });

                        return buildCommentSection(todoTask, todoData, index);
                      },
                    ),
                    Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: showOptions(listIndex: index, context: context, todoData: todoData),
                    ),
                  ],
                ),
                isExpanded: isAssignUserTodo
                    ? lstUpcomingTodoAssignUser[index].todoDetail!.isExpanded
                    : lstUpcomingTodoData[index].isExpanded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildPastTodoItemCard(index, GetTodoData todoData, bool isAssignUserTodo) {
    DateTime dateTime = DateTime.parse(todoData.assignDateTime!);
    DateFormat formatter = DateFormat('E, d MMM, y');
    String formattedDate = formatter.format(dateTime);

    return GestureDetector(
      onTap: () async {
        // bool? result;
        // if (isAssignUserTodo) {
        //   result = lstPastTodoAssignUser[index]
        //       .todoDetail!
        //       .todoAssignUsers
        //       ?.any((element) => element.assignUserId == AppGlobals.user!.id);
        // } else {
        //   result =
        //       lstPastTodoData[index].todoAssignUsers!.any((element) => element.assignUserId == AppGlobals.user!.id);
        // }
        // if (result!) {
          // if (todoData.status != 1) {
          bool result = await AppGlobals.navigateAndReturn(
            context,
            AddTodo(todoData: todoData),
            false,
          );
          if (result) reset();
          // } else {
          //   AppGlobals.showMessage("After status done you can't update this record.", MessageType.error);
          // }
        // }
      },
      onLongPress: () {
        showDeleteDialog(todoId: todoData.id);
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3), // Adjust the offset as needed
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
          clipBehavior: Clip.hardEdge,
          child: ExpansionPanelList(
            elevation: 1,
            expansionCallback: (int itemIndex, bool isExpanded) {
              if (isAssignUserTodo) {
                if (lstPastTodoAssignUser[index].todoDetail!.isExpanded) {
                  lstPastTodoAssignUser[index].todoDetail!.isExpanded = false;
                } else {
                  lstPastTodoAssignUser[index].todoDetail!.isExpanded = true;
                }
              } else {
                if (lstPastTodoData[index].isExpanded) {
                  lstPastTodoData[index].isExpanded = false;
                } else {
                  lstPastTodoData[index].isExpanded = true;
                }
              }
              setState(() {});
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: todoData.status == 0 ? false : true,
                            onChanged: (value) {
                              if (todoData.userId == AppGlobals.user!.id) {
                                updateTodoTaskIsDone(context, todoData.id, todoData.status == 0 ? 1 : 0);
                              } else {
                                AppGlobals.showMessage(
                                    "Only the user who created the task can mark it as completed.", MessageType.error);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${todoData.title!} (${todoData.description!})",
                                maxLines: 2,
                                style: TextStyle(
                                  decoration: todoData.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const FieldSpace(SpaceType.extraSmall),
                                  Text(
                                    formattedDate,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              // if (todoData.priority != null)
                              //   Row(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const Text(
                              //         AppString.priority,
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 12,
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
                              //       Text(
                              //         todoData.priority!.priority!,
                              //         maxLines: 2,
                              //         style: const TextStyle(
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // const FieldSpace(SpaceType.extraSmall),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     RichText(
                              //       text: TextSpan(
                              //         text: "Assigned By: ",
                              //         style: const TextStyle(
                              //           fontSize: 10,
                              //           color: Colors.black,
                              //         ),
                              //         children: [
                              //           TextSpan(
                              //             text: todoData.todoUser!.name!,
                              //             style: const TextStyle(
                              //               fontSize: 10,
                              //               color: AppColors.primary,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //     // GestureDetector(
                              //     //   onTap: () {
                              //     //     favouriteTodo(todoData.id, todoData.favorite == 0 ? 1 : 0);
                              //     //   },
                              //     //   child: Icon(
                              //     //     todoData.favorite == 1 ? Icons.star_rounded : Icons.star_border_rounded,
                              //     //     color: AppColors.primary,
                              //     //   ),
                              //     // ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                body: Stack(
                  children: [
                    Column(
                      children: [
                        if (todoData.priority != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppString.priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
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
                                Text(
                                  todoData.priority!.priority!,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const FieldSpace(SpaceType.extraSmall),
                        ListView.builder(
                          itemCount: todoData.todoAssignUsers!.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (context, subIndex) {
                            TodoAssignUser assignUser = todoData.todoAssignUsers![subIndex];

                            TodoTask todoTask = todoData.todoTasks!.lastWhere((element) {
                              return element.userId == assignUser.assignUserId;
                            });

                            return buildCommentSection(todoTask, todoData, index);
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: showOptions(listIndex: index, context: context, todoData: todoData),
                    ),
                  ],
                ),
                isExpanded: isAssignUserTodo
                    ? lstPastTodoAssignUser[index].todoDetail!.isExpanded
                    : lstPastTodoData[index].isExpanded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*GestureDetector buildTodoItemCard(index, GetTodoData todoData) {
    return GestureDetector(
      onTap: () async {
        // if(AppGlobals.user!.roles!.first.id == 2 || todoData.userId != AppGlobals.user!.id)

        if(todoData.status != 1) {
          bool result = await AppGlobals.navigateAndReturn(
            context,
            AddTodo(todoData: todoData),
            false,
          );
          if (result) reset();
        } else {
          AppGlobals.showMessage("After status done you can't update this record.", MessageType.error);
        }

        // if(todoData.userId != AppGlobals.user!.id) {
        //   bool result = await AppGlobals.navigateAndReturn(
        //     context,
        //     AddTodo(todoData: todoData),
        //     false,
        //   );
        //   if (result) reset();
        // } else {
        //   // AppGlobals.showMessage("You created", MessageType.error);
        // }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
        ),
        elevation: 2,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                          "${todoData.assignDateTime!}",
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
                          todoData.todoAssignUsers!.map((user) => user.assignUserDetail!.name).join(", "),
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    itemCount: todoData.todoAssignUsers!.length,
                    shrinkWrap: true,
                    primary: false,
                    // separatorBuilder: (context, index) {
                    //   return const SizedBox(
                    //     height: 6,
                    //   );
                    // },
                    itemBuilder: (context, subIndex) {
                      TodoAssignUser assignUser = todoData.todoAssignUsers![subIndex];
                      TodoTask todoTask = todoData
                          .todoTasks!
                          .lastWhere((element) => element.userId == assignUser.assignUserId);
                      return buildCommentSection(todoTask);
                    },
                  ),
                  */ /*if(todoData.todoTasks!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "Next Date/Time",
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
                            "${todoData.todoTasks!.first.date} ${todoData.todoTasks!.first.time}",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if(todoData.todoTasks!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "Comment 1",
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
                            todoData.todoTasks!.first.commentFirst!,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if(todoData.todoTasks!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "Comment 2",
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
                            todoData.todoTasks!.first.commentSecond!,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),*/ /*
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.status,
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
                          todoData.status == 0 ? "Pending" : "Done",
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: todoData.status == 0
                                ? Colors.red
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             Positioned(
              right: 0.0,
              top: 0.0,
              child: showOptions(listIndex: index, context: context, todoData: todoData),
            ),
          ],
        ),
      ),
    );
  }*/

  buildCommentSection(TodoTask todoTask, GetTodoData todoData, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
      child: Column(
        children: [
          if (todoTask.todoTaskUser!.name != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    todoTask.todoTaskUser!.name!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (todoTask.date != null && todoTask.time != null)
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
                    "${todoTask.date} ${AppGlobals.convertTo12HourFormat(todoTask.time!)}",
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          if (todoTask.commentFirst != null)
            Row(
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
                    todoTask.commentFirst!,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          /*if (todoTask.priorityResponse != null)
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
                    todoTask.priorityResponse!.priority!,
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
            ),*/
        ],
      ),
    );
  }

  Widget showOptions({listIndex, context, GetTodoData? todoData}) {
    return PopupMenuButton<TodoMenuOptions>(
      offset: const Offset(-25, 0),
      onSelected: (TodoMenuOptions result) {
        _tabOption(result.index, listIndex, context, todoData!);
      },
      splashRadius: 25,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TodoMenuOptions>>[
        const PopupMenuItem<TodoMenuOptions>(
          value: TodoMenuOptions.previousDetails,
          child: Text("Previous History"),
        ),
        if (todoData!.userId == AppGlobals.user!.id)
          const PopupMenuItem<TodoMenuOptions>(
            value: TodoMenuOptions.delete,
            child: Text("Delete"),
          ),
        if (todoData.userId == AppGlobals.user!.id && todoData.status != 1)
          const PopupMenuItem<TodoMenuOptions>(
            value: TodoMenuOptions.edit,
            child: Text("Done"),
          ),
      ],
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimen.paddingSmall,
            vertical: AppDimen.paddingSmall,
          ),
          alignment: Alignment.topRight,
          child: const Icon(Icons.more_vert_rounded),
        ),
      ),
    );
  }

  List<DropdownMenuItem<TodoStatus>> buildDropdownStatusItems(List<TodoStatus> statusList) {
    List<DropdownMenuItem<TodoStatus>> items = [];
    for (TodoStatus item in statusList as Iterable<TodoStatus>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name.toCapitalize(),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<PriorityResponse>> buildDropdownPriorityItems(List<PriorityResponse> priorityList) {
    List<DropdownMenuItem<PriorityResponse>> items = [];
    for (PriorityResponse item in priorityList as Iterable<PriorityResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.priority!.toCapitalize(),
            style: const TextStyle(fontSize: 15),
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

  showDeleteDialog({int? todoId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // contentPadding: EdgeInsets.zero,
          // titlePadding: EdgeInsets.zero,
          title: const Text(
            AppString.deleteTitle,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppString.deleteSubtitleTodo,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () => _deleteTodo(context, todoId),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  showUpdateStatusDialog({int? todoId, int? status}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // contentPadding: EdgeInsets.zero,
          // titlePadding: EdgeInsets.zero,
          title: const Text(
            AppString.confirmTodoDone,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppString.todoDoneTask,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () => updateTodoTaskIsDone(context, todoId, status, isBack: true),
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  showAddTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // contentPadding: EdgeInsets.zero,
          // titlePadding: EdgeInsets.zero,
          title: const Text(
            AppString.addTeam,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          content: Form(
            key: _teamFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: txtTeamNameController,
                  decoration: const InputDecoration(
                    labelText: AppString.name,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    bool isValid = Validations.validateInput(value, true, ValidationType.none);
                    if (!isValid) {
                      return AppString.enterTeam;
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
                    selectedAddMember.clear();
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
                  value: selectedAddMember.isEmpty ? null : selectedAddMember.last,
                  items: roleUserList.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      // label: item.name,
                      child: Row(
                        children: [
                          StatefulBuilder(
                              builder: (context, menuSetState) {
                                return Checkbox(
                                  value: selectedAddMember.contains(item),
                                  onChanged: (bool? checked) {
                                    if (checked != null) {
                                      menuSetState(() {
                                        if (checked) {
                                          selectedAddMember.add(item);
                                        } else {
                                          selectedAddMember.remove(item);
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
                    // if (value == null) {
                    //   return AppString.select;
                    // }
                    return null;
                  },
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      txtUserNameController.clear();
                    }
                  },
                  dropdownSearchData: DropdownSearchData(
                    searchController: txtUserNameController,
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
                        controller: txtUserNameController,
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () => addTeam(),
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }
}
