import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omsatya/helpers/location_helper.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/attendance_response.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/engineer_response.dart';
import 'package:omsatya/models/month_response.dart';
import 'package:omsatya/repository/attendance_repository.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/engineer_repository.dart';
import 'package:omsatya/screen/complain_details.dart';
import 'package:omsatya/screen/previous_complain.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class AddAttendance extends StatefulWidget {
  final int complainStatusKey;

  const AddAttendance({super.key, this.complainStatusKey = 1});

  @override
  State<AddAttendance> createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  TextEditingController textEditingController = TextEditingController();

  List<ComplainData> complainList = [];

  List<MonthData> monthList = [];
  List<EngineerDataResponse> engineerNameList = [];
  List<DropdownMenuItem<MonthData>>? _dropdownMonthItems;
  List<DropdownMenuItem<EngineerDataResponse>>? _dropdownEngineerItems;

  MonthData? _selectedMonth;
  EngineerDataResponse? _selectedEngineer;

  AttendanceData? attendanceData;

  int defaultMonthKey = 1;
  int roleId = 0;

  bool isInitial = true;
  bool isMonth = true;
  bool isEngineer = true;
  bool isAttendance = true;

  bool isButtonDisabled = false;
  bool isInLoading = false;
  bool isOutLoading = false;

  String _inDateTime = '';
  String _inAddress = '';
  String _outDateTime = '';
  String _outAddress = '';
  double latitude = 0.0;
  double longitude = 0.0;

  int _page = 1;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    roleId = AppGlobals.user!.roles!.first.id!;
    defaultMonthKey = AppGlobals().getCurrentMonth();
    await fetchMonthsData();
    await getEngineerAttendance();
    if (roleId == 2) {
      await fetchAllEngineersData();
    }

    _dropdownMonthItems = buildDropdownMonthItems(monthList);

    for (int x = 0; x < _dropdownMonthItems!.length; x++) {
      if (_dropdownMonthItems![x].value!.id == defaultMonthKey) {
        _selectedMonth = _dropdownMonthItems![x].value;
      }
    }

    _dropdownEngineerItems = buildDropdownEngineerNameItems(engineerNameList);
    // for (int x = 0; x < _dropdownComplainStatusItems2!.length; x++) {
    //   if (_dropdownComplainStatusItems2![x].value!.id == defaultComplainStatusKey2) {
    //     _selectedComplainStatus2 = _dropdownComplainStatusItems2![x].value;
    //   }
    // }

    // await fetchComplainList();
  }

  clearFilter() {
    if (roleId == 2 && _selectedEngineer != null) {
      _selectedEngineer = null;
    }
    fetchComplainList();
  }

  reset() {
    complainList.clear();
    isInitial = true;
    setState(() {});
  }

  fetchMonthsData() async {
    try {
      var response = await AttendanceRepository().getAllMonthResponse();

      if (response.success) {
        List<MonthData> list = response.data;
        monthList = list;
        isMonth = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isMonth = false;
      });
    } finally {
      setState(() {
        isMonth = false;
      });
    }
  }

  fetchAllEngineersData() async {
    try {
      var response = await EngineerRepository().getAllEngineerResponse();

      if (response.success) {
        engineerNameList = response.data;
        isEngineer = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isEngineer = false;
      });
    } finally {
      setState(() {
        isEngineer = false;
      });
    }
  }

  fetchComplainList() async {
    try {
      var response = await ComplainRepository().getComplainListResponse(
        statusId: _selectedMonth?.id,
        engineerId: 0,
        partyId: 0,
        complainNo: 0,
        isAssign: 0,
        page: _page,
      );

      if (response.success!) {
        complainList = response.data!.data!;
        isInitial = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  getEngineerAttendance() async {
    try {
      var response = await AttendanceRepository().getEngineerAttendance(engineerId: AppGlobals.user!.id);

      if (response.success) {
        attendanceData = response.data;
        _inDateTime = "${response.data.inDate}  ${response.data.inTime}";
        _inAddress = response.data.inAddress!;
        _outDateTime = "${response.data.outDate}  ${response.data.outTime}";
        _outAddress = response.data.outAddress!;
        isAttendance = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isAttendance = false;
      });
    } finally {
      setState(() {
        isAttendance = false;
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
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.paddingSmall),
          child: Column(
            children: [
              // buildFilterDropDown(context),
              const FieldSpace(SpaceType.small),
              isAttendance
                  ? ShimmerHelper().buildBasicShimmer(height: 200)
                  : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimen.textRadius),
                      ),
                      elevation: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(AppDimen.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    (_inDateTime.isNotEmpty && _inAddress.isNotEmpty)
                                        ? Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context).size.width * 0.165,
                                            margin: const EdgeInsets.only(top: 0),
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0.0),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                                            ),
                                            child: const Text(
                                              AppString.ins,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        : PrimaryButton(
                                            onPressed: isInLoading ? null : _recordIn,
                                            text: AppString.ins,
                                            padding: EdgeInsets.zero,
                                          ),
                                    if (isInLoading)
                                      ButtonLoader(
                                        width: MediaQuery.of(context).size.width * 0.165,
                                        margin: const EdgeInsets.only(top: 5),
                                        verticalPadding: 8.5,
                                        loaderSize: 20,
                                      ),
                                  ],
                                ),
                                const FieldSpace(),
                                if (_inDateTime.isNotEmpty && _inAddress.isNotEmpty)
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                              text: 'In Date & Time: ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _inDateTime,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                )
                                              ]),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text: 'In Address: ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _inAddress,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                            const FieldSpace(),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    (_outDateTime.isNotEmpty && _outAddress.isNotEmpty)
                                        ? Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context).size.width * 0.165,
                                            margin: const EdgeInsets.only(top: 0),
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0.0),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                                            ),
                                            child: const Text(
                                              AppString.out,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        : PrimaryButton(
                                            onPressed: isOutLoading ? null : _recordOut,
                                            text: AppString.out,
                                            padding: EdgeInsets.zero,
                                          ),
                                    if (isOutLoading)
                                      ButtonLoader(
                                        width: MediaQuery.of(context).size.width * 0.165,
                                        margin: const EdgeInsets.only(top: 5),
                                        verticalPadding: 8.5,
                                        loaderSize: 20,
                                      ),
                                  ],
                                ),
                                const FieldSpace(),
                                if (_outDateTime.isNotEmpty && _outAddress.isNotEmpty)
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                              text: 'Out Date & Time: ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _outDateTime,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                )
                                              ]),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text: 'Out Address: ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _outAddress,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                            const FieldSpace(),
                            if (attendanceData != null)
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "A/P",
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
                                          attendanceData!.ap!,
                                          style: TextStyle(
                                            color: AppGlobals().getAPColor(attendanceData!.ap!),
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
                                          "Late hours",
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
                                          "${attendanceData!.lateHrs!}",
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
                                          "EarlyGo hours",
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
                                          attendanceData!.earligoingHrs!,
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
                                          "Working hours",
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
                                          attendanceData!.workingHrs!,
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
                          ],
                        ),
                      ),
                    )
            ],
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
              isMonth
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.month,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isMonth
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.05,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<MonthData>(
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            width: roleId == 2
                                ? MediaQuery.of(context).size.width * 0.31
                                : MediaQuery.of(context).size.width * 0.6,
                            maxHeight: MediaQuery.of(context).size.height * 0.31,
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
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedMonth,
                          items: _dropdownMonthItems,
                          onChanged: (MonthData? selectedFilter) {
                            setState(() {
                              _selectedMonth = selectedFilter;
                            });
                            reset();
                            fetchComplainList();
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
        if (roleId == 2) const FieldSpace(),
        if (roleId == 2)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMonth
                    ? ShimmerHelper().buildBasicShimmer(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.015,
                        radius: 4)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppString.engineerName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          InkWell(
                            onTap: () => clearFilter(),
                            borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            highlightColor: AppColors.primary.withOpacity(0.2),
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.15,
                              // height: MediaQuery.of(context).size.height * 0.05,
                              // padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                              child: const Text(
                                AppString.clear,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                // style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                const FieldSpace(SpaceType.extraSmall),
                isMonth
                    ? ShimmerHelper().buildBasicShimmer(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.05,
                        radius: AppDimen.textRadius)
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<EngineerDataResponse>(
                            hint: Text(
                              AppString.selectEngineerName,
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
                              padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                            ),
                            value: _selectedEngineer,
                            items: _dropdownEngineerItems,
                            onChanged: (EngineerDataResponse? selectedFilter) {
                              setState(() {
                                _selectedEngineer = selectedFilter;
                              });
                              reset();
                              fetchComplainList();
                            },
                          ),
                        ),
                      ),
              ],
            ),
          ),
      ],
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
      return RefreshIndicator(
        onRefresh: () => fetchComplainList(),
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 6,
              );
            },
            itemCount: complainList.length,
            scrollDirection: Axis.vertical,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildAddressItemCard(index, complainList[index]);
            },
          ),
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

  GestureDetector buildAddressItemCard(index, ComplainData complainData) {
    return GestureDetector(
      onTap: () async {
        AppGlobals.showMessage("Double click", MessageType.success);
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppGlobals.user?.roles?.first.id == 2 ? "Engineer ${AppString.status}" : AppString.status,
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
                  if (AppGlobals.user?.roles?.first.id == 2 && complainData.engineer != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "${AppString.engineer} Name",
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
                  if (AppGlobals.user?.roles?.first.id == 2)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            (AppGlobals.user?.roles?.first.id == 2) ? "Admin ${AppString.status}" : AppString.status,
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
                            AppGlobals().getAdminStatus(complainData.isAssign),
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppGlobals().getAdminStatus(complainData.isAssign).toLowerCase() == "not assign"
                                  ? Colors.red
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
        const PopupMenuItem<MenuOptions>(
          value: MenuOptions.delete,
          child: Text("Previous Details"),
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

  List<DropdownMenuItem<MonthData>> buildDropdownMonthItems(List<MonthData> monthList) {
    List<DropdownMenuItem<MonthData>> items = [];
    for (MonthData item in monthList as Iterable<MonthData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name.toCapitalize(),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<EngineerDataResponse>> buildDropdownEngineerNameItems(
      List<EngineerDataResponse> deliveryStatusList) {
    List<DropdownMenuItem<EngineerDataResponse>> items = [];
    for (EngineerDataResponse item in deliveryStatusList as Iterable<EngineerDataResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      );
    }
    return items;
  }

  Future<String?> _getCurrentLocation(BuildContext context) async {
    Position? currentPosition = await LocationHelper.getCurrentPosition(context);
    String? currentAddress = await LocationHelper.getAddressFromLatLng(currentPosition!);
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    setState(() {});
    return currentAddress;
  }

  void _recordIn() async {
    try {
      bool result = await LocationHelper.handleLocationPermission(context);
      if (!result) return;

      String date = AppGlobals().getCurrentDate();
      String time = AppGlobals().getCurrentTime();
      double lateHours = AppGlobals.calculateLateHrs(dutyHours: AppGlobals.user!.dutyStart);

      setState(() {
        isInLoading = true;
      });

      String? address = await _getCurrentLocation(context);
      var response = await AttendanceRepository().engineerAttendanceStore(
        firmId: 1,
        engineerId: AppGlobals.user!.id,
        yearId: 1,
        ap: "P",
        inDate: date,
        inTime: time,
        pDays: 1.0,
        lateHrs: lateHours,
        inLat: latitude,
        inLong: longitude,
        address: address,
      );

      if (response.success) {
        // AppGlobals.showMessage("Attendance add Successfully", MessageType.success);
        isInLoading = false;
        _inDateTime = "$date  $time";
        _inAddress = address!;
        getEngineerAttendance();
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isInLoading = false;
      });
    } finally {
      setState(() {
        isInLoading = false;
      });
    }
  }

  void _recordOut() async {
    try {
      bool result = await LocationHelper.handleLocationPermission(context);
      if (!result) return;
      String date = AppGlobals().getCurrentDate();
      String time = AppGlobals().getCurrentTime();

      double earlyGoingHrs = AppGlobals.calculateEarlyGoingHrs(dutyEndHours: AppGlobals.user!.dutyEnd);
      double totalWorkingHrs = AppGlobals.calculateTotalWorkingHrs(inTime: attendanceData!.inTime);

      setState(() {
        isOutLoading = true;
      });

      String? address = await _getCurrentLocation(context);
      var response = await AttendanceRepository().engineerAttendanceUpdate(
        id: attendanceData!.id,
        outDate: date,
        outTime: time,
        ap: attendanceData!.ap,
        earlyGoingHrs: earlyGoingHrs,
        workingHrs: totalWorkingHrs,
        pDays: attendanceData!.pdays,
        outLat: latitude,
        outLong: longitude,
        outAddress: address,
      );

      if (response.success) {
        // AppGlobals.showMessage("Attendance out Successfully", MessageType.success);
        isOutLoading = false;
        _outDateTime = "$date  $time";
        _outAddress = address!;
        getEngineerAttendance();
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isOutLoading = false;
      });
    } finally {
      setState(() {
        isOutLoading = false;
      });
    }
  }
}
