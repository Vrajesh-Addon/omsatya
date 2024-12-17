import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/global_models.dart';
import 'package:omsatya/models/report/ap_details_response.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/repository/auth_repository.dart';
import 'package:omsatya/repository/common_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class ApReportScreen extends StatefulWidget {
  const ApReportScreen({super.key});

  @override
  State<ApReportScreen> createState() => _ApReportScreenState();
}

class _ApReportScreenState extends State<ApReportScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();

  List<ApDetailsData> apReportList = [];
  List<UserResponse> allUserList = [];
  List<Months> monthsList = Months.getMonthsList();

  List<DropdownMenuItem<Months>>? _dropdownMonths;
  List<DropdownMenuItem<UserResponse>>? _dropdownAllUser;

  ApPageData? data;

  Months? _selectedMonths;
  UserResponse? _selectedUser;

  bool isInitial = true;
  bool isUser = false;
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
    DateTime now = DateTime.now();
    int currentMonthId = now.month;

    _dropdownMonths = buildDropdownMonths(monthsList);

    for (int x = 0; x < _dropdownMonths!.length; x++) {
      if (_dropdownMonths![x].value!.id == currentMonthId) {
        _selectedMonths = _dropdownMonths![x].value;
      }
    }

    if(AppGlobals.user!.roles!.first.id == 2) {
      await fetchAllUser();
      _dropdownAllUser = buildDropdownUserItems(allUserList);
    }

    await fetchApDetailsList();
  }

  void mainScrollListener() {
    if (isLoadingMore) return;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (data != null) {
          if (data!.lastPage != _page) {
            setState(() {
              _page++;
              isLoadingMore = true;
            });
            await fetchApDetailsList();
          }
        }
      }
    });
  }

  clearFilter() {
    if(_selectedUser != null) {
      _page = 1;
      _selectedUser = null;
      reset();
    }
  }

  Future<void> reset() async {
    _page = 1;
    apReportList.clear();
    fetchApDetailsList();
  }

  fetchApDetailsList() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await CommonRepository().getApDetailsData(
        month: _selectedMonths!.id,
        userId: _selectedUser == null && AppGlobals.user!.roles!.first.id != 2 ? AppGlobals.user!.id.toString() : _selectedUser?.id.toString(),
        page: _page,
      );

      if (response.success!) {
        data = response.data!;
        // apReportList = response.data!.data!;
        apReportList.addAll(response.data!.data!);
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

  fetchAllUser() async {
    try {
      setState(() {
        isUser = true;
      });

      var response = await AuthRepository().getAllUserData();

      if (response.success) {
        allUserList = response.data;
        isUser = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isUser = false;
      });
    } finally {
      setState(() {
        isUser = false;
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
                  child: buildApReportList(),
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
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppString.month,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const FieldSpace(SpaceType.extraSmall),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.048,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<Months>(
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: AppGlobals.user!.roles!.first.id == 2 ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimen.textRadius),
                        color: Colors.white,
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      width: AppGlobals.user!.roles!.first.id == 2 ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.95,
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
                    value: _selectedMonths,
                    items: _dropdownMonths,
                    onChanged: (Months? months) {
                      setState(() {
                        _selectedMonths = months;
                      });
                      reset();
                    },
                  ),
                ),
              ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          if(AppGlobals.user!.roles!.first.id == 2)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isUser
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.user,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isUser
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.52,
                      height: MediaQuery.of(context).size.height * 0.048,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.048,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<UserResponse>(
                          isExpanded: true,
                          hint: Text(
                            AppString.selectUser,
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
                            width: MediaQuery.of(context).size.width * 0.52,
                            maxHeight: MediaQuery.of(context).size.height / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            width: MediaQuery.of(context).size.width * 0.52,
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
                            height: MediaQuery.of(context).size.height * 0.045,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedUser,
                          items: _dropdownAllUser,
                          onChanged: (UserResponse? userResponse) {
                            setState(() {
                              _selectedUser = userResponse;
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
                                  hintText: AppString.searchForUser,
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
          ),
          if(AppGlobals.user!.roles!.first.id == 2)
          const FieldSpace(SpaceType.small),
          if(AppGlobals.user!.roles!.first.id == 2)
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
                  height: MediaQuery.of(context).size.height * 0.045,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                  child: Text(
                    AppString.clear,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildApReportList() {
    if (isInitial && apReportList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (apReportList.isNotEmpty) {
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
          itemCount: isLoadingMore ? apReportList.length + 1 : apReportList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index < apReportList.length) {
              return buildApReportCard(index, apReportList[index]);
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
    } else if (!isInitial && apReportList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noAttendanceFound,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  Card buildApReportCard(index, ApDetailsData data) {
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
                        AppString.name,
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
                        "${data.users!.name}",
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
                        AppString.phone,
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
                        data.users!.phoneNo!,
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
                        AppString.ap,
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
                        data.ap!,
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
                        AppString.inDateTime,
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
                        "${data.inDate!} ${data.inTime!}",
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
                        AppString.outDateTime,
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
                        "${data.outDate!} ${data.outTime!}",
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                /*Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        AppString.designation,
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
                        "Designation",
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),*/
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        "Late Hrs",
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
                        data.lateHrs ?? "0.0",
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
                        "Early Going Hrs",
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
                        data.earligoingHrs ?? "0.0",
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
                        "Working Hrs",
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
                        data.workingHrs ?? "0.0",
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

  List<DropdownMenuItem<Months>> buildDropdownMonths(List<Months> monthsList) {
    List<DropdownMenuItem<Months>> items = [];
    for (Months item in monthsList as Iterable<Months>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name.toCapitalize(),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<UserResponse>> buildDropdownUserItems(List<UserResponse> userList) {
    List<DropdownMenuItem<UserResponse>> items = [];
    for (UserResponse item in userList as Iterable<UserResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }
}
