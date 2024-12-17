import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/dashboard_response.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/screen/add_leave/leave_screen.dart';
import 'package:omsatya/screen/admin/admin_add_complain.dart';
import 'package:omsatya/screen/admin/admin_today_report.dart';
import 'package:omsatya/screen/admin/daily_attendance.dart';
import 'package:omsatya/screen/admin/free_engineer.dart';
import 'package:omsatya/screen/admin/sales_report.dart';
import 'package:omsatya/screen/ap_report.dart';
import 'package:omsatya/screen/complain.dart';
import 'package:omsatya/screen/engineer/add_attendance.dart';
import 'package:omsatya/screen/engineer/add_party_address.dart';
import 'package:omsatya/screen/today_expiry_report.dart';
import 'package:omsatya/screen/todo/todo.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  final String type;

  const HomeScreen({super.key, required this.type});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int touchedIndex = -1;
  int roleId = 0;
  DashboardResponse? dashboardResponse;

  @override
  void initState() {
    init();
    _handleDashboard();
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
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.paddingSmall),
          child: RefreshIndicator(
            onRefresh: () => _handleDashboard(),
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: ListView(
              shrinkWrap: true,
              primary: false,
              // mainAxisSize: MainAxisSize.min,
              children: [
                if(widget.type == AppString.services)
                buildPieChart(),
                if(widget.type == AppString.services)
                  Column(
                    children: [
                      dashboardResponse == null
                          ? displayShimmerEffect()
                          : Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              // onTap: () => widget.changeIndexWithStatus?.call(1, 1),
                              onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 1), false),
                              child: buildDashboardCard(
                                context: context,
                                bgColor: AppColors.primary,
                                counter: "${dashboardResponse!.data.pendingComplaints}",
                                text: AppString.pending,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 2), false),
                              child: buildDashboardCard(
                                context: context,
                                bgColor: Colors.purple,
                                counter: "${dashboardResponse!.data.inProgressComplaints}",
                                text: AppString.inProgress,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 3), false),
                              child: buildDashboardCard(
                                context: context,
                                bgColor: AppColors.success,
                                counter: "${dashboardResponse!.data.closedComplaints}",
                                text: AppString.todayClosed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const FieldSpace(SpaceType.extraSmall),
                      dashboardResponse == null
                          ? displayShimmerEffect()
                          :Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const AdminAddComplain(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.addComplain,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const ComplainScreen(complainStatusKey: 1), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.complain,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const AddPartyAddress(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.locationAddress,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const FieldSpace(SpaceType.extraSmall),
                      dashboardResponse == null
                          ? displayShimmerEffect()
                          :Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const AddAttendance(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.addAttendance,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: Container(),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
                if(widget.type == AppString.administrative)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                              onTap: () => AppGlobals.navigate(context, const ApReportScreen(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.attendanceDetails,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const AdminTodayReport(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.adminTodayReport,
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
                              onTap: () {
                                AppGlobals.navigate(context, const TodayExpiryReportScreen(), false);
                              },
                              child: buildDashboardCard(
                                context: context,
                                // cardBg: Colors.grey.shade300,
                                text: AppString.mcExpireToday,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const DailyAttendance(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.dailyAttendance,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const FreeEngineer(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.freeEngineer,
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
                              onTap: () => AppGlobals.navigate(context, const SalesReportScreen(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.salesLeadReport,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const Todo(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.todo,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
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

  buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          dashboardResponse == null
              ? Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlighted,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                  sections: showingSections(),
                ),
              ),
            ),
          )
              : Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      sections: showingSections(),
                    ),
                  ),
                ),
                // Text(
                //   "${dashboardResponse!.data.totalComplaints}",
                //   style: const TextStyle(
                //     color: AppColors.warning,
                //     fontWeight: FontWeight.w600,
                //     fontSize: 22,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 24.0 : 16.0;
      final radius = isTouched ? 60.0 : 60.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.primary,
            value: dashboardResponse == null ? 0.0 : dashboardResponse!.data.pendingComplaints.toDouble(),
            title: dashboardResponse == null ? "0" : "${dashboardResponse!.data.pendingComplaints}",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.purple,
            value: dashboardResponse == null ? 0.0 : dashboardResponse!.data.inProgressComplaints.toDouble(),
            title: dashboardResponse == null ? "0" : "${dashboardResponse!.data.inProgressComplaints}",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: AppColors.success,
            value: dashboardResponse == null ? 0.0 : dashboardResponse!.data.closedComplaints.toDouble(),
            title: dashboardResponse == null ? "0" : "${dashboardResponse!.data.closedComplaints}",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw const Error();
      }
    });
  }

  Widget pieColumnShimmerEffect() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: 18,
              radius: 0,
            ),
            const FieldSpace(SpaceType.small),
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.11,
              radius: 0,
            ),
          ],
        ),
        const FieldSpace(SpaceType.small),
        Row(
          children: [
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: 18,
              radius: 0,
            ),
            const FieldSpace(SpaceType.small),
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.11,
              radius: 0,
            ),
          ],
        ),
        const FieldSpace(SpaceType.small),
        Row(
          children: [
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: 18,
              radius: 0,
            ),
            const FieldSpace(SpaceType.small),
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.11,
              radius: 0,
            ),
          ],
        ),
        const FieldSpace(SpaceType.small),
        Row(
          children: [
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: 18,
              radius: 0,
            ),
            const FieldSpace(SpaceType.small),
            ShimmerHelper().buildBasicShimmer(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.11,
              radius: 0,
            ),
          ],
        ),
      ],
    );
  }

}
