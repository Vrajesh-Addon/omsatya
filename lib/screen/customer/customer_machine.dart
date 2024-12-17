import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/customer_machine_response.dart';
import 'package:omsatya/models/holiday_response.dart';
import 'package:omsatya/models/machine_no_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/customer_repository.dart';
import 'package:omsatya/repository/dashboard_repository.dart';
import 'package:omsatya/screen/customer/customer_add_complain.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class CustomerMachine extends StatefulWidget {
  const CustomerMachine({super.key});

  @override
  State<CustomerMachine> createState() => _CustomerMachineState();
}

class _CustomerMachineState extends State<CustomerMachine> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();

  MData? mData;

  List<MachineData> machineList = [];
  List<MachineNoData> machineNoList = [];
  List<DropdownMenuItem<MachineNoData>>? _dropdownMachineNoItems;

  MachineNoData? _selectedMachineNo;
  HolidayData? holidayData;

  int defaultComplainStatusKey = 1;

  bool isInitial = true;
  bool isStatus = true;
  bool isLoadingMore = false;

  int? partyId;
  int _page = 1;

  @override
  void initState() {
    mainScrollListener();
    init();
    super.initState();
  }


  @override
  void dispose() {
    _scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  init() async {
    partyId = AppGlobals.user!.id!;
    await fetchHolidayData();
    await fetchMachineNoData();

    _dropdownMachineNoItems = buildDropdownMachineNoItems(machineNoList);

    // for (int x = 0; x < _dropdownComplainStatusItems!.length; x++) {
    //   if (_dropdownComplainStatusItems![x].value!.id == defaultComplainStatusKey) {
    //     _selectedComplainStatus = _dropdownComplainStatusItems![x].value;
    //   }
    // }

    await fetchMachineList();
  }

  void mainScrollListener() {
    if(isLoadingMore) return;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(mData != null){
          if(mData!.lastPage != _page){
            setState(() {
              _page++;
              isLoadingMore = true;
            });
            fetchMachineList();
          }
        }
      }
    });
  }

  clearFilter() {
    _selectedMachineNo = null;
    reset();
  }

  Future<void> reset() async {
    _page = 1;
    machineList.clear();
    fetchHolidayData();
    fetchMachineList();
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

  fetchMachineNoData() async {
    try {
      var response = await ComplainRepository().getMachineNoResponse(partyId!);

      if (response.success) {
        List<MachineNoData> list = response.data;
        list.sort((a, b) {
          return a.mcNo.toLowerCase().compareTo(b.mcNo.toLowerCase());
        });
        machineNoList = list;
        isStatus = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isStatus = false;
      });
    } finally {
      setState(() {
        isStatus = false;
      });
    }
  }

  fetchMachineList() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await CustomerRepository().getCustomerMachineData(partyId!, _selectedMachineNo?.mcNo, _page);

      if (response.success!) {
        mData = response.data;
        machineList = machineList + response.data!.data!;
        machineList.sort((a, b) {
          return a.mcNo!.toLowerCase().compareTo(b.mcNo!.toLowerCase());
        });
        isInitial = false;
        isLoadingMore = false;
      } else {
        isLoadingMore = false;
      }
      setState(() {});
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
  
  gotoAddComplain(MachineData machineData) async {
    bool result = await AppGlobals.navigateAndReturn(
        context, CustomerAddComplain(machineData: machineData), false);
    if (result) reset();
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
                  child: buildMachineExpiryList(),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isStatus
                  ? ShimmerHelper().buildBasicShimmer(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.015,
                  radius: 4)
                  : const Text(
                AppString.machineNo,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const FieldSpace(SpaceType.extraSmall),
              isStatus
                  ? ShimmerHelper().buildBasicShimmer(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05,
                  radius: AppDimen.textRadius)
                  : DropdownButtonHideUnderline(
                    child: DropdownButton2<MachineNoData>(
                      hint: Text(
                        AppString.selectMachineNo,
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
                        width: MediaQuery.of(context).size.width * 0.76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          color: Colors.white,
                        ),
                      ),
                      buttonStyleData: ButtonStyleData(
                        height: MediaQuery.of(context).size.height * 0.05,
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
                      value: _selectedMachineNo,
                      items: _dropdownMachineNoItems,
                      onChanged: (MachineNoData? selectedFilter) {
                        setState(() {
                          _selectedMachineNo = selectedFilter;
                        });
                        reset();
                      },
                    ),
                  ),
            ],
          ),
        ),
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

  buildMachineExpiryList() {
    if (isInitial && machineList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (machineList.isNotEmpty) {
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
          itemCount: isLoadingMore ? machineList.length + 1 : machineList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index < machineList.length) {
              return buildMachineExpiryItemCard(index, machineList[index]);
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
    } else if (!isInitial && machineList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noMachine,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  GestureDetector buildMachineExpiryItemCard(index, MachineData machineData) {
    final currentDate = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(currentDate);
    DateTime cDate = DateFormat('yyyy-MM-dd').parse(date);
    DateTime expiredDate = DateFormat('yyyy-MM-dd').parse(machineData.serviceExpiryDate!);

    return GestureDetector(
      onTap: cDate.isAfter(expiredDate) ? null : () async {
          /*final now = DateTime.now();
          final startTime = DateTime(now.year, now.month, now.day, 19, 0); // Today 7:00 PM
          final endTime = DateTime(now.year, now.month, now.day + 1, 8, 0);

          if (machineData.cMessage != null && machineData.cMessage!.isEmpty) {
            if (!now.isAfter(startTime) || !now.isBefore(endTime)) {
              bool result = await AppGlobals.navigateAndReturn(
                  context, CustomerAddComplain(machineData: machineData), false);
              if (result) reset();
            } else {
              AppGlobals.showMessage("Evening 7:00 PM to Morning 8:00 AM complain not created.", MessageType.error);
            }
          } else {
            AppGlobals.showMessage(
                "Complain already created. Complain no is [${machineData.cMessage!}].", MessageType.error);
          }*/


          DateTime startTime;
          DateTime endTime;

          final now = DateTime.now();

          bool isSunday = now.weekday == DateTime.sunday;

          if(isSunday){
            startTime = DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
            endTime = DateTime(now.year, now.month, now.day, 13, 0); // 1:00 PM
          } else {
            startTime = DateTime(now.year, now.month, now.day, 19, 0); // Today 7:00 PM
            endTime = DateTime(now.year, now.month, now.day + 1, 9, 0); // Tomorrow 9 AM
          }

          if (machineData.cMessage != null && machineData.cMessage!.isEmpty) {
            if(holidayData != null){
              AppGlobals.showMessage(
                  holidayData!.description!, MessageType.error);
            } else if (isSunday) {
              if (isSunday && now.isAfter(startTime) && now.isBefore(endTime)) {
                gotoAddComplain(machineData);
              } else {
                AppGlobals.showMessage(
                    "Sunday after 1:00 PM complain not created.", MessageType.error);
              }
            } else {
              if (!now.isAfter(startTime) || !now.isBefore(endTime)) {
                gotoAddComplain(machineData);
              } else {
                AppGlobals.showMessage(
                    "Evening 7:00 PM to tomorrow Morning 8:00 AM complain not created.", MessageType.error);
              }
            }
          } else {
            AppGlobals.showMessage(
                "Complain already created. Complain no is [${machineData.cMessage!}].", MessageType.error);
          }
      },
      child: Card(
        color: cDate.isAfter(expiredDate) ? Colors.red.shade50 : Colors.white,
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
                          AppString.date,
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
                          AppGlobals.changeDateFormat(machineData.date!),
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
                          AppString.partyName,
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
                          machineData.party!.name!,
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
                          machineData.product!.name!,
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
                          "${machineData.serialNo} / ${machineData.mcNo}",
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
                          machineData.serviceType!.name!,
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
                          machineData.serviceExpiryDate!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(machineData.cMessage!.isNotEmpty)
                  const FieldSpace(SpaceType.small),
                  if(machineData.cMessage!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: RichText(
                          text: TextSpan(
                            text: "Complain already created. Complain no is ",
                            style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 14,
                              ),
                            children: [
                              TextSpan(
                                  text: "[${machineData.cMessage!}].",
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                              ),
                            ]
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
      ),
    );
  }

  List<DropdownMenuItem<MachineNoData>> buildDropdownMachineNoItems(
      List<MachineNoData> machineNoList) {
    List<DropdownMenuItem<MachineNoData>> items = [];
    for (MachineNoData item in machineNoList as Iterable<MachineNoData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.mcNo,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }

}
