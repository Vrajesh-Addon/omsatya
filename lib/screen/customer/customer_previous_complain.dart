import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/customer_repository.dart';
import 'package:omsatya/screen/complain_details.dart';
import 'package:omsatya/screen/previous_complain.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class CustomerPreviousComplain extends StatefulWidget {
  final ComplainData? complainData;

  const CustomerPreviousComplain({super.key, this.complainData});

  @override
  State<CustomerPreviousComplain> createState() => _CustomerPreviousComplainState();
}

class _CustomerPreviousComplainState extends State<CustomerPreviousComplain> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();

  List<ComplainData> complainList = [];
  List<ComplainStatusData> complainStatusList = [];
  List<DropdownMenuItem<ComplainStatusData>>? _dropdownComplainStatusItems;

  ComplainStatusData? _selectedComplainStatus;

  Data? data;

  int defaultComplainStatusKey = 1;

  bool isInitial = true;
  bool isStatus = true;
  bool isLoadingMore = false;

  int _page = 1;

  @override
  void initState() {
    mainScrollListener();
    init();
    super.initState();
  }

  init() async {
    // defaultComplainStatusKey = widget.complainStatusKey;
    // await fetchComplainStatusData();
    //
    // _dropdownComplainStatusItems = buildDropdownComplainStatusItems(complainStatusList);
    //
    // for (int x = 0; x < _dropdownComplainStatusItems!.length; x++) {
    //   if (_dropdownComplainStatusItems![x].value!.id == defaultComplainStatusKey) {
    //     _selectedComplainStatus = _dropdownComplainStatusItems![x].value;
    //   }
    // }

    await fetchPreviousComplainList();
  }

  void mainScrollListener() {
    if(isLoadingMore) return;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(data != null){
          if(data!.lastPage != _page){
            setState(() {
              _page++;
              isLoadingMore = true;
            });
            fetchPreviousComplainList();
          }
        }
      }
    });
  }

  clearFilter() {

  }

  Future<void> reset() async {
    complainList.clear();
    fetchPreviousComplainList();
  }

  fetchPreviousComplainList() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await CustomerRepository().getCustomerPreviousComplain(
          partyId: AppGlobals.user!.id!,
          machineSalesId: widget.complainData!.salesEntry!.id!,
      );

      if (response.success!) {
        complainList = response.data!;
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

  _tabOption(int index, listIndex, context) async {
    switch (index) {
      case 0:
        AppGlobals.navigate(
          context,
          ComplainDetailsScreen(complainData: complainList[listIndex]),
          false,
        );
        break;
      case 1:
        AppGlobals.navigate(
          context,
          PreviousComplainScreen(complainId: complainList[listIndex].id),
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
                const FieldSpace(SpaceType.small),
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
    if (isInitial && complainList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (complainList.isNotEmpty) {
      return SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 6,
            );
          },
          itemCount: isLoadingMore ? complainList.length + 1 : complainList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index < complainList.length) {
              return buildComplainCard(index, complainList[index]);
            } else {
              return Container(
                height: 100,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimen.paddingLarge,
                ),
                child: const Center(
                  child: AppLoader(),
                ),
              );
            }
          },
        ),
      );
    } else if (!isInitial && complainList.isEmpty) {
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

  Card buildComplainCard(index, ComplainData complainData) {
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
                        "${complainData.complaintNo}",
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
                        complainData.salesEntry!.mcNo!,
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
                /*if (AppGlobals.user != null &&
                    AppGlobals.user!.roles!.first.name!.toLowerCase() ==
                        "admin") // Engineer field display on admin role
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppString.engineer,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Padding(
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
                          "Free",
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),*/
                if (complainData.engineer != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "${AppString.engineer}",
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
                if (complainData.engineerInDate != null && complainData.engineerInTime != null)
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
                if (complainData.engineerOutDate != null && complainData.engineerOutTime != null)
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
                    Expanded(
                      child: Text(
                        AppGlobals.user?.roles?.first.id == 2
                            ? "Engineer ${AppString.status}"
                            : AppString.status,
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
                        AppGlobals().getStatus(complainData.statusId),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppGlobals().getStatus(complainData.statusId).toLowerCase() ==
                              "pending"
                              ? Colors.red
                              : AppGlobals().getStatus(complainData.statusId).toLowerCase() ==
                              "in progress"
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
            child: showOptions(listIndex: index, context: context),
          ),
        ],
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
          child: Text("Details"),
        ),
        // const PopupMenuItem<MenuOptions>(
        //   value: MenuOptions.delete,
        //   child: Text("Previous Details"),
        // ),
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
}
