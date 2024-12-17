import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omsatya/helpers/location_helper.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/attendance_response.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/engineer_response.dart';
import 'package:omsatya/models/month_response.dart';
import 'package:omsatya/repository/attendance_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class AddSalesAttendance extends StatefulWidget {
  final int complainStatusKey;

  const AddSalesAttendance({super.key, this.complainStatusKey = 1});

  @override
  State<AddSalesAttendance> createState() => _AddSalesAttendanceState();
}

class _AddSalesAttendanceState extends State<AddSalesAttendance> {
  TextEditingController textEditingController = TextEditingController();

  List<MonthData> monthList = [];
  List<DropdownMenuItem<MonthData>>? _dropdownMonthItems;
  MonthData? _selectedMonth;

  AttendanceData? attendanceData;

  int defaultMonthKey = 1;
  int roleId = 0;

  bool isMonth = true;
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


  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    roleId = AppGlobals.user!.roles!.first.id!;
    defaultMonthKey = AppGlobals().getCurrentMonth();
    // await fetchMonthsData();
    await getEngineerAttendance();

    // for (int x = 0; x < _dropdownMonthItems!.length; x++) {
    //   if (_dropdownMonthItems![x].value!.id == defaultMonthKey) {
    //     _selectedMonth = _dropdownMonthItems![x].value;
    //   }
    // }

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
                                          "${attendanceData!.earligoingHrs!}",
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
                                          "${attendanceData!.workingHrs!}",
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
