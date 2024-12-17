import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/report/today_machine_expiry_response.dart';
import 'package:omsatya/repository/common_repository.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class TodayExpiryReportScreen extends StatefulWidget {

  const TodayExpiryReportScreen({super.key});

  @override
  State<TodayExpiryReportScreen> createState() => _TodayExpiryReportScreenState();
}

class _TodayExpiryReportScreenState extends State<TodayExpiryReportScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();

  List<TodayMachineExpiryData> todayExpiryList = [];
  List<Party> partyNameList = [];

  List<DropdownMenuItem<Party>>? _dropdownPartyNameItems;

  Party? _selectedPartyName;

  bool isInitial = true;
  bool isParty = true;
  bool isLoadingMore = false;


  @override
  void initState() {
    init();
    super.initState();
  }


  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  init() async {
    await fetchPartyNameData();
    _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);

    await fetchTodayExpiryList();
  }

  clearFilter() {
    if(_selectedPartyName != null) {
      _selectedPartyName = null;
      reset();
    }
  }

  Future<void> reset() async {
    todayExpiryList.clear();
    fetchTodayExpiryList();
  }

  fetchPartyNameData() async {
    try {
      var response = await ComplainRepository().getPartyNameResponse();

      if (response.success) {
        List<Party> list = response.data;
        list.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        partyNameList = list;
        isParty = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isParty = false;
      });
    } finally {
      setState(() {
        isParty = false;
      });
    }
  }

  fetchTodayExpiryList() async {
    try {

      setState(() {
        isInitial = true;
      });

      var response = await CommonRepository().getTodayMachineExpiryData(_selectedPartyName?.id.toString());

      if (response.success!) {
        todayExpiryList = response.data!;
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
                  child: buildTodayExpiryList(),
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
      children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isParty
                ? ShimmerHelper().buildBasicShimmer(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.015,
                radius: 4)
                : const Text(
              AppString.partyName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const FieldSpace(SpaceType.extraSmall),
            isParty
                ? ShimmerHelper().buildBasicShimmer(
                height: MediaQuery.of(context).size.height * 0.05,
                radius: AppDimen.textRadius)
                : SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<Party>(
                  hint: Text(
                    AppString.selectPartyName,
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
                    width: MediaQuery.of(context).size.width * 0.96,
                    maxHeight: MediaQuery.of(context).size.height / 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimen.textRadius),
                      color: Colors.white,
                    ),
                  ),
                  buttonStyleData: ButtonStyleData(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimen.padding, vertical: 0),
                  ),
                  value: _selectedPartyName,
                  items: _dropdownPartyNameItems,
                  isExpanded: true,
                  onChanged: (Party? selectedFilter) {
                    setState(() {
                      _selectedPartyName = selectedFilter;
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
        ),),
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
                height: MediaQuery.of(context).size.height * 0.05,
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Text(
                  AppString.clear,
                  style:
                  Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  buildTodayExpiryList() {
    if (isInitial && todayExpiryList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (todayExpiryList.isNotEmpty) {
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
          itemCount: todayExpiryList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildTodayExpiryCard(index, todayExpiryList[index]);
          },
        ),
      );
    } else if (!isInitial && todayExpiryList.isEmpty) {
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

  Card buildTodayExpiryCard(index, TodayMachineExpiryData data) {
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
                        data.party!.name!,
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
                        AppString.phoneNo,
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
                        data.party!.phoneNo!,
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
                        data.product!.name!,
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
                        AppString.machineNo,
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
                        data.mcNo!,
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
                        AppString.address,
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
                        data.party!.address!,
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
                        data.serviceType!.name!,
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
                          AppString.expiryDate,
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
                          data.serviceExpiryDate!,
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

  List<DropdownMenuItem<Party>> buildDropdownPartyNameItems(List<Party> deliveryStatusList) {
    List<DropdownMenuItem<Party>> items = [];
    for (Party item in deliveryStatusList as Iterable<Party>) {
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
