import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/dashboard_response.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/screen/add_leave/leave_screen.dart';
import 'package:omsatya/screen/change_password.dart';
import 'package:omsatya/screen/complain.dart';
import 'package:omsatya/screen/engineer/add_attendance.dart';
import 'package:omsatya/screen/sales_person/add_sales_attendance.dart';
import 'package:omsatya/screen/sales_person/sales.dart';
import 'package:omsatya/screen/todo/todo.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:shimmer/shimmer.dart';

class SalesHome extends StatefulWidget {
  final Function(int index, int complainStatus)? changeIndexWithStatus;
  final Function(int index)? changeIndex;

  const SalesHome({super.key, this.changeIndexWithStatus, this.changeIndex});

  @override
  State<SalesHome> createState() => _SalesHomeState();
}

class _SalesHomeState extends State<SalesHome> {
  int touchedIndex = -1;
  int roleId = 0;
  DashboardResponse? dashboardResponse;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    roleId = AppGlobals.user!.roles!.first.id!;
  }

  Future<void> _handleDashboard() async {
    try {
      var response = await DashboardRepository().getDashboardResponse(AppGlobals.user!.roles!.first.id!);

      if (mounted) {
        dashboardResponse = response;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.paddingSmall),
          child: ListView(
            shrinkWrap: true,
            primary: false,
            children: [
              const FieldSpace(SpaceType.large),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          AppGlobals.navigate(context, const AddSalesAttendance(), false),
                      child: buildDashboardCard(
                        context: context,
                        text: AppString.addAttendance,
                      ),
                    ),
                  ),
                  const FieldSpace(SpaceType.extraSmall),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppGlobals.navigate(context, const LeaveScreen(), false),
                      child: buildDashboardCard(
                        context: context,
                        text: AppString.leave,
                      ),
                    ),
                  ),
                  const FieldSpace(SpaceType.extraSmall),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: buildDashboardCard(
                        context: context,
                        cardBg: Colors.grey.shade300,
                        text: AppString.attendanceDetails,
                      ),
                    ),
                  ),
                ],
              ),
              const FieldSpace(SpaceType.extraSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppGlobals.navigate(context, const Sales(), false),
                      child: buildDashboardCard(
                        context: context,
                        text: AppString.sales,
                      ),
                    ),
                  ),
                  const FieldSpace(SpaceType.extraSmall),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          AppGlobals.navigate(context, const Todo(), false),
                      child: buildDashboardCard(
                        context: context,
                        text: AppString.todo,
                      ),
                    ),
                  ),
                  const FieldSpace(SpaceType.extraSmall),
                  Expanded(
                    child: Container()
                  ),
                ],
              ),
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
