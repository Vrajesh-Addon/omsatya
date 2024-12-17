import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/admin_today_report/admin_today_report_response.dart';
import 'package:omsatya/models/report/free_engineer_response.dart';
import 'package:omsatya/repository/engineer_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:printing/printing.dart';

class FreeEngineer extends StatefulWidget {

  const FreeEngineer({super.key});

  @override
  State<FreeEngineer> createState() => _FreeEngineerState();
}

class _FreeEngineerState extends State<FreeEngineer> {
  List<FreeEngineerData> lstFreeEngineer = [];
  bool isInitial = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await fetchFreeEngineer();
    setState(() {});
  }

  Future<void> reset() async {
    lstFreeEngineer.clear();
    fetchFreeEngineer();
  }

  clear() {
    // _txtNameController.clear();
    // setState(() {
    //   if (mounted) {
    //     engineerDataSource = EngineerDataSource(
    //       buildContext: context,
    //       lstEngineerData: allEngAttendanceList,
    //     );
    //   }
    // });
  }

  fetchFreeEngineer() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response =
      await EngineerRepository().getAllFreeEngineerResponse();

      if (response.success!) {
        lstFreeEngineer = response.data!;
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
                  child: buildFreeEngineerList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView buildFilterDropDown(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      child: Container(),
    );
  }

  buildFreeEngineerList() {
    if (isInitial && lstFreeEngineer.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 10,
          itemHeight: 80.0,
        ),
      );
    } else if (lstFreeEngineer.isNotEmpty) {
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
          itemCount: lstFreeEngineer.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildLeadSalesItemCard(index, lstFreeEngineer[index]);
          },
        ),
      );
    } else if (!isInitial && lstFreeEngineer.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noLeadAssign,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  Card buildLeadSalesItemCard(index, FreeEngineerData freeEngineerData) {
    return Card(
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
                        AppString.engineer,
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
                        freeEngineerData.name!,
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
                        AppString.pending,
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
                        "${freeEngineerData.pendingComplaints!}",
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
