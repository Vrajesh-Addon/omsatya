import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/holiday_response.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/screen/admin/home.dart';
import 'package:omsatya/screen/sales_person/sales.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class DashHomeScreen extends StatefulWidget {
  final Function(int index, int complainStatus)? changeIndexWithStatus;
  final Function(int index)? changeIndex;

  const DashHomeScreen({super.key, this.changeIndexWithStatus, this.changeIndex});

  @override
  State<DashHomeScreen> createState() => _DashHomeScreenState();
}

class _DashHomeScreenState extends State<DashHomeScreen> {
  int touchedIndex = -1;
  int roleId = 0;
  HolidayData? holidayData;

  @override
  void initState() {
    init();
    fetchHolidayData();
    super.initState();
  }

  init() {
    roleId = AppGlobals.user!.roles!.first.id!;
  }

  fetchHolidayData() async {
    try {
      String date = AppGlobals().getCurrentDate();
      var response = await DashboardRepository().getHolidayResponse(date);

      if (response.success!) {
        holidayData = response.data;
      } else {
        holidayData = null;
      }
      setState(() {});
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.padding),
          child: ListView(
            shrinkWrap: true,
            primary: false,
            // mainAxisSize: MainAxisSize.min,
            children: [
              const FieldSpace(),
              Card(
                color: const Color(0xFFD3D6DD),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall, horizontal: AppDimen.paddingSmall),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Image.asset(
                        AppImages.calender,
                        width: 80,
                        height: 80,
                      ),
                      const FieldSpace(),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: AppDimen.paddingSmall),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat("dd MMM yyyy").format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2A3654),
                                    ),
                                  ),
                                  StreamBuilder(
                                    stream: Stream.periodic(const Duration(seconds: 1)),
                                    builder: (context, snapshot) {
                                      final currentTime = DateTime.now();
                                      final hour = currentTime.hour % 12 == 0 ? 12 : currentTime.hour % 12;
                                      final minute = currentTime.minute.toString().padLeft(2, '0');
                                      final second = currentTime.second.toString().padLeft(2, '0');
                                      final period = currentTime.hour >= 12 ? 'PM' : 'AM';

                                      return Text(
                                        '$hour:$minute $period',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2A3654),),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const FieldSpace(),
                            Padding(
                              padding: const EdgeInsets.only(right: AppDimen.paddingSmall),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat("EEEE").format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2A3654),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const FieldSpace(),
              if(holidayData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingExtraSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppDimen.paddingSmall, horizontal: AppDimen.padding),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD3D6DD), width: 1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          holidayData!.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if(holidayData != null)
              const FieldSpace(),
              // buildPieChart(),
              // dashboardResponse == null
              //     ? displayShimmerEffect()
              //     : Row(
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         // onTap: () => widget.changeIndexWithStatus?.call(1, 1),
              //         onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 1), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           bgColor: AppColors.primary,
              //           counter: "${dashboardResponse!.data.pendingComplaints}",
              //           text: AppString.pending,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 2), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           bgColor: Colors.purple,
              //           counter: "${dashboardResponse!.data.inProgressComplaints}",
              //           text: AppString.inProgress,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 3), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           bgColor: AppColors.success,
              //           counter: "${dashboardResponse!.data.closedComplaints}",
              //           text: AppString.todayClosed,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const FieldSpace(SpaceType.extraSmall),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => AppGlobals.navigate(context, const HomeScreen(type: AppString.administrative), false),
                    child: buildDashboardHomeCard(
                      context: context,
                      text: AppString.administrative,
                      image: AppImages.administrative,
                    ),
                  ),
                  const FieldSpace(),
                  GestureDetector(
                    onTap: () => AppGlobals.navigate(context, const Sales(isAdmin: true), false),
                    child: buildDashboardHomeCard(
                      context: context,
                      text: AppString.sales,
                      image: AppImages.sales,
                    ),
                  ),
                  const FieldSpace(),
                  GestureDetector(
                    onTap: () => AppGlobals.navigate(context, const HomeScreen(type: AppString.services), false),
                    child: buildDashboardHomeCard(
                      context: context,
                      text: AppString.services,
                      image: AppImages.services,
                    ),
                  ),
                ],
              ),
              // dashboardResponse == null
              //     ? displayShimmerEffect()
              //     : Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const AdminAddComplain(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.addComplain,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 1), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.complain,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const AddPartyAddress(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.locationAddress,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const FieldSpace(SpaceType.extraSmall),
              // dashboardResponse == null
              //     ? displayShimmerEffect()
              //     : Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const AddAttendance(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.addAttendance,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const LeaveScreen(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.leave,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () {},
              //         child: buildDashboardCard(
              //           context: context,
              //           cardBg: Colors.grey.shade300,
              //           text: AppString.attendanceDetails,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // dashboardResponse == null
              //     ? displayShimmerEffect()
              //     : Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const AdminTodayReport(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.adminTodayReport,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () {},
              //         child: buildDashboardCard(
              //           context: context,
              //           cardBg: Colors.grey.shade300,
              //           text: AppString.mcExpireToday,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const DailyAttendance(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.dailyAttendance,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // dashboardResponse == null
              //     ? displayShimmerEffect()
              //     : Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const FreeEngineer(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.freeEngineer,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const Sales(isAdmin: true), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.sales,
              //         ),
              //       ),
              //     ),
              //     const FieldSpace(SpaceType.extraSmall),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () => AppGlobals.navigate(context, const Todo(), false),
              //         child: buildDashboardCard(
              //           context: context,
              //           text: AppString.todo,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const FieldSpace(),
              // PrimaryButton(
              //   text: AppString.logout,
              //   onPressed: () => widget.changeIndex?.call(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Padding displayShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(AppDimen.paddingExtraSmall),
      child: Row(
        children: [
          Expanded(
            child: ShimmerHelper().buildBasicShimmerCustomRadius(
              radius: BorderRadius.circular(AppDimen.textRadius),
              height: 100,
            ),
          ),
          const FieldSpace(SpaceType.small),
          Expanded(
            child: ShimmerHelper().buildBasicShimmerCustomRadius(
              radius: BorderRadius.circular(AppDimen.textRadius),
              height: 100,
            ),
          ),
          const FieldSpace(SpaceType.small),
          Expanded(
            child: ShimmerHelper().buildBasicShimmerCustomRadius(
              radius: BorderRadius.circular(AppDimen.textRadius),
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}

