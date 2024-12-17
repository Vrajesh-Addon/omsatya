import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/leave/apply_leave_data.dart';
import 'package:omsatya/repository/leave_repository.dart';
import 'package:omsatya/screen/add_leave/add_leave.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {

  List<ApplyLeaveData> lstLeaveList = [];

  List<ComplainStatusData> complainStatusList = [];
  List<DropdownMenuItem<ComplainStatusData>>? _dropdownComplainStatusItems;

  ComplainStatusData? _selectedComplainStatus;

  bool isInitial = false;
  bool isStatus = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    showMessage("AppGlobals.user!.roles!.first.id ==> ${AppGlobals.user!.roles!.first.id}");
    await fetchAddLeaveList();
  }

  Future<void> reset() async {
    lstLeaveList.clear();
    fetchAddLeaveList();
  }

  fetchAddLeaveList() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await LeaveRepository().getAllLeaveData();

      if (response.status) {
        lstLeaveList = response.data;
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

  _deleteTodo(BuildContext context, int? leaveId) async {
    try {
      var response = await LeaveRepository().deleteTodoDataById(leaveId: leaveId);

      if (response.status) {
        Navigator.pop(context);
        AppGlobals.showMessage(response.message, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  _leaveApprovedReject(int? leaveId) async {
    try {
      var response = await LeaveRepository().leaveAcceptRejectById(leaveId: leaveId);

      if (response.status) {
        AppGlobals.showMessage(response.message, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  _tabOption(int index, listIndex, context) async {
    switch (index) {
      case 0:
        bool result = await AppGlobals.navigateAndReturn(
          context,
          AddLeave(applyLeaveData: lstLeaveList[listIndex]),
          false,
        );
        if(result) reset();
        break;
      case 1:
        showDeleteDialog(todoId: lstLeaveList[listIndex].id);
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => reset(),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppDimen.paddingSmall),
            child: Column(
              children: [
                buildFilterDropDown(context),
                const FieldSpace(SpaceType.small),
                Expanded(
                  child: buildLeaveList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildFilterDropDown(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // margin: const EdgeInsets.only(top: AppDimen.margin),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimen.padding,
                vertical: AppDimen.paddingSmall,
              ),
            ),
            onPressed: () async {
              bool? result = await AppGlobals.navigateAndReturn(context, const AddLeave(), false);
              if (result != null && result) reset();
            },
            child: const Text(
              AppString.addLeave,
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildLeaveList() {
    if (isInitial && lstLeaveList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (lstLeaveList.isNotEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 6,
            );
          },
          itemCount: lstLeaveList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
              return buildLeaveCard(index, lstLeaveList[index]);
          },
        ),
      );
    } else if (!isInitial && lstLeaveList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noLeaveAdded,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  GestureDetector buildLeaveCard(index, ApplyLeaveData applyLeaveData) {
    return GestureDetector(
      onTap: () async {
        bool result = await AppGlobals.navigateAndReturn(
          context,
          AddLeave(applyLeaveData: applyLeaveData),
          false,
        );
        if(result) reset();
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
                          AppString.leaveNo,
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
                          "${applyLeaveData.id}",
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
                          applyLeaveData.dateTime!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(AppGlobals.user!.roles!.first.id == 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.name,
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
                          applyLeaveData.userResponse!.name!,
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
                          AppString.leaveFrom,
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
                          applyLeaveData.leaveFrom!,
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
                          AppString.leaveTo,
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
                          applyLeaveData.leaveTill!,
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
                          AppString.totalDays,
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
                          "${applyLeaveData.totalLeave}",
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
                          AppString.reason,
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
                          applyLeaveData.reason!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(AppGlobals.user!.roles!.first.id != 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.isApproved,
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
                          AppGlobals().getLeaveStatus(applyLeaveData.isApproved),
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: applyLeaveData.isApproved == 0
                                ? Colors.red
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(AppGlobals.user!.roles!.first.id == 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.isApproved,
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
                        child: Container(
                          margin: EdgeInsets.zero,
                          child: Switch(
                            onChanged: (value) {
                              int index = lstLeaveList.indexWhere((element) => element.id == applyLeaveData.id);
                              if (index != -1) {
                                lstLeaveList[index].isApproved = value ? 1 : 0;
                              }
                              setState(() {});
                              _leaveApprovedReject(lstLeaveList[index].id);
                            },
                            value: lstLeaveList[index].isApproved == 0 ? false : true,
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
              child: showOptions(listIndex: index, context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget showOptions({listIndex, productId, context}) {
    return PopupMenuButton<MenuOptions>(
      offset: const Offset(-25, 0),
      onSelected: (MenuOptions result) {
        _tabOption(result.index, listIndex, context);
      },
      splashRadius: 25,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
        const PopupMenuItem<MenuOptions>(
          value: MenuOptions.edit,
          child: Text("Edit"),
        ),
        const PopupMenuItem<MenuOptions>(
          value: MenuOptions.delete,
          child: Text("Delete"),
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

  List<DropdownMenuItem<ComplainStatusData>> buildDropdownComplainStatusItems(
      List<ComplainStatusData> complainStatusList) {
    List<DropdownMenuItem<ComplainStatusData>> items = [];
    for (ComplainStatusData item in complainStatusList as Iterable<ComplainStatusData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!.toCapitalize(),
            style: const TextStyle(fontSize: 15),
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
                "Are you sure you want to delete this leave.",
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
              onPressed: () =>  _deleteTodo(context, todoId),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
