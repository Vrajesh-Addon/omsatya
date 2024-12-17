import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/screen/complain_details.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class PreviousComplainScreen extends StatefulWidget {
  final int? complainId;

  const PreviousComplainScreen({super.key, this.complainId});

  @override
  State<PreviousComplainScreen> createState() => _PreviousComplainScreenState();
}

class _PreviousComplainScreenState extends State<PreviousComplainScreen> {
  List<ComplainData> previousComplainList = [];

  bool isInitial = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    fetchComplainList();
  }

  Future<void> reset() async {
    previousComplainList.clear();
    fetchComplainList();
  }

  fetchComplainList() async {
    try {
      var response = await ComplainRepository().getPreviousComplain(widget.complainId!);

      if (response.success) {
        previousComplainList = response.data!.pastComplaints;
        isInitial = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  _tabOption(int index, listIndex) async {
    switch (index) {
      case 0:
        AppGlobals.navigate(
          context,
          ComplainDetailsScreen(complainData: previousComplainList[listIndex]),
          false,
        );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppDimen.paddingSmall, bottom: AppDimen.paddingSmall),
                  child: Text(AppString.previousComplain, style: Theme.of(context).textTheme.titleMedium,),
                ),
                Expanded(
                  child: buildComplainList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildComplainList() {
    if (isInitial && previousComplainList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (previousComplainList.isNotEmpty) {
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
          itemCount: previousComplainList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildPreviousDetailItemCard(index, previousComplainList[index]);
          },
        ),
      );
    } else if (!isInitial && previousComplainList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noComplain,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  Card buildPreviousDetailItemCard(index, ComplainData complainData) {
    return Card(
      color: Colors.grey.shade300,
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
                        AppString.complainNo,
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
                        complainData.complaintNo!,
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
                        "${AppGlobals.changeDateFormat(complainData.date!)}  ${complainData.time!}",
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
                        AppString.party,
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
                        complainData.party!.name!,
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
                        AppString.productName,
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
                        complainData.product!.name,
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
                        AppString.machineSrNo,
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
                        "${complainData.salesEntry!.serialNo!} / ${complainData.salesEntry!.mcNo!}",
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
                        AppString.complain,
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
                        complainData.complaintType!.name,
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
                        AppString.serviceType,
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
                        complainData.serviceType!.name,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (complainData.engineer != null)
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
                          complainData.engineer!.name!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                if(complainData.engineerInDate != null && complainData.engineerInTime != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.engineerIn,
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
                          "${complainData.engineerInDate}  ${complainData.engineerInTime}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                if(complainData.engineerInAddress != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.engineerInAddress,
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
                          complainData.engineerInAddress!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                if(complainData.engineerOutDate != null && complainData.engineerOutTime != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.engineerOut,
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
                          "${complainData.engineerOutDate}  ${complainData.engineerOutTime}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                if(complainData.engineerOutAddress != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.engineerOutAddress,
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
                          complainData.engineerOutAddress!,
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
                        AppGlobals().getStatus(complainData.statusId),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppGlobals().getStatus(complainData.statusId).toLowerCase() == "pending"
                              ? Colors.red
                              : AppGlobals().getStatus(complainData.statusId).toLowerCase() == "in progress"
                              ? Colors.purple
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
            child: showOptions(listIndex: index),
          ),
        ],
      ),
    );
  }

  Widget showOptions({listIndex, productId}) {
    return PopupMenuButton<MenuOptions>(
      offset: const Offset(-25, 0),
      onSelected: (MenuOptions result) {
        _tabOption(result.index, listIndex);
        // setState(() {
        //   //_menuOptionSelected = result;
        // });
      },
      splashRadius: 25,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
        const PopupMenuItem<MenuOptions>(
          value: MenuOptions.edit,
          child: Text("Details"),
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
}
