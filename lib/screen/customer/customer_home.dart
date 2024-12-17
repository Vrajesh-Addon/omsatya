import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/dashboard_response.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/screen/customer/customer_complain.dart';
import 'package:omsatya/screen/customer/customer_expiry.dart';
import 'package:omsatya/screen/customer/customer_machine.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:shimmer/shimmer.dart';

class CustomerHome extends StatefulWidget {
  final Function(int index, int complainStatus)? changeIndex;

  const CustomerHome({
    super.key,
    this.changeIndex,
  });

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int touchedIndex = -1;
  DashboardResponse? dashboardResponse;

  @override
  void initState() {
    _handleDashboard();
    super.initState();
  }

  Future<void> _handleDashboard() async {
    try {
      var response = await DashboardRepository().getCustomerDashboardResponse(AppGlobals.user!.id!);

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
        child: RefreshIndicator(
          onRefresh: () => _handleDashboard(),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppDimen.paddingSmall),
            child: ListView(
              shrinkWrap: true,
              // mainAxisSize: MainAxisSize.min,
              children: [
                buildPieChart(),
                const FieldSpace(SpaceType.large),
                dashboardResponse == null
                    ? displayShimmerEffect()
                    : Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const CustomerComplain(complainStatusKey: 1), false),
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
                              onTap: () => AppGlobals.navigate(context, const CustomerComplain(complainStatusKey: 2), false),
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
                              onTap: () => AppGlobals.navigate(context, const CustomerComplain(complainStatusKey: 3), false),
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const CustomerMachine(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.machineComplain,
                              ),
                            ),
                          ),
                          const FieldSpace(SpaceType.extraSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => AppGlobals.navigate(context, const CustomerExpiry(), false),
                              child: buildDashboardCard(
                                context: context,
                                text: AppString.expiryReport,
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
                                text: AppString.freeServiceList,
                              ),
                            ),
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
        ],
      ),
    );
  }

  AspectRatio buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.80,
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
                            centerSpaceRadius: 30,
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
      final fontSize = isTouched ? 22.0 : 14.0;
      final radius = isTouched ? 50.0 : 50.0;
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
