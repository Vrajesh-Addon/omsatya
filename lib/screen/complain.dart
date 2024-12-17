import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/all_complain_no_response.dart';
import 'package:omsatya/models/assign_status.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/engineer_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/engineer_repository.dart';
import 'package:omsatya/screen/complain_details.dart';
import 'package:omsatya/screen/engineer/in_out.dart';
import 'package:omsatya/screen/previous_complain_pdf.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:url_launcher/url_launcher.dart';


class User {
  final String name;
  final int id;

  User({required this.name, required this.id});

  @override
  String toString() {
    return 'User(name: $name, id: $id)';
  }
}

class ComplainScreen extends StatefulWidget {
  final int complainStatusKey;

  const ComplainScreen({super.key, this.complainStatusKey = 1});

  @override
  State<ComplainScreen> createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController engineerEditingController = TextEditingController();
  TextEditingController assignEngineerEditingController = TextEditingController();
  TextEditingController txtComplainNoController = TextEditingController();
  TextEditingController complainNoController = TextEditingController();

  List<ComplainData> complainList = [];

  List<ComplainStatusData> complainStatusList = [];
  List<EngineerDataResponse> engineerNameList = [];
  List<Party> partyNameList = [];
  List<AllComplainNoData> allComplainNoList = [];

  List<DropdownMenuItem<ComplainStatusData>>? _dropdownComplainStatusItems;
  List<DropdownMenuItem<AssignStatus>>? _dropdownAssignStatusItems;
  List<DropdownMenuItem<Party>>? _dropdownPartyNameItems;
  List<DropdownMenuItem<EngineerDataResponse>>? _dropdownEngineerItems;

  // List<DropdownMenuItem<EngineerDataResponse>>? _dropdownAssignEngineerItems;
  List<DropdownMenuItem<EngineerDataResponse>>? _dropdownAssignEngineerItems;
  List<DropdownMenuItem<AllComplainNoData>>? _dropdownComplainNoItems;

  ComplainStatusData? _selectedComplainStatus;
  AssignStatus? _selectAssignStatus;
  Party? _selectedPartyName;
  EngineerDataResponse? _selectedEngineerName;
  AllComplainNoData? _selectedComplainNo;
  Data? data;

  int defaultComplainStatusKey = 1;
  int defaultAssignStatus = 10;
  int defaultPartyNameKey = 1;
  int defaultEngineerNameKey = 1;
  int _currentIndex = 0;

  bool isInitial = true;
  bool isStatus = true;
  bool isParty = true;
  bool isEngineer = true;
  bool isComplainNo = true;
  bool isLoadingMore = false;

  int _page = 1;
  Timer? _debounce;

  List<AssignStatus> lstAssignStatus = [
    AssignStatus(id: 10, name: "Both"),
    AssignStatus(id: 1, name: "Assign"),
    AssignStatus(id: 0, name: "Not Assign"),
  ];

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
    engineerEditingController.dispose();
    assignEngineerEditingController.dispose();
    txtComplainNoController.dispose();
    complainNoController.dispose();
    super.dispose();
  }

  init() async {
    defaultComplainStatusKey = widget.complainStatusKey;
    await fetchComplainStatusData();
    await fetchPartyNameData();
    // await fetchComplainNo();
    if (AppGlobals.user!.roles!.first.id == 2) {
      await fetchAllEngineersData();
    }

    _dropdownComplainStatusItems =
        AppGlobals().buildDropdownComplainStatusItems(complainStatusList);
    _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
    _dropdownAssignStatusItems = buildDropdownAssignStatusItems(lstAssignStatus);
    _dropdownEngineerItems = buildDropdownEngineerNameItems(engineerNameList);
    _dropdownComplainNoItems = buildDropdownComplainNoItems(allComplainNoList);

    for (int x = 0; x < _dropdownComplainStatusItems!.length; x++) {
      if (_dropdownComplainStatusItems![x].value!.id == defaultComplainStatusKey) {
        _selectedComplainStatus = _dropdownComplainStatusItems![x].value;
      }
    }

    for (int x = 0; x < _dropdownAssignStatusItems!.length; x++) {
      if (_dropdownAssignStatusItems![x].value!.id == defaultAssignStatus) {
        _selectAssignStatus = _dropdownAssignStatusItems![x].value;
      }
    }

    // for (int x = 0; x < _dropdownPartyNameItems!.length; x++) {
    //   if (_dropdownPartyNameItems![x].value!.id == defaultPartyNameKey) {
    //     _selectedPartyName = _dropdownPartyNameItems![x].value;
    //   }
    // }

    await fetchComplainList();
  }

  void mainScrollListener() {
    if (isLoadingMore) return;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (data != null) {
          if (data!.lastPage != _page) {
            setState(() {
              _page++;
              isLoadingMore = true;
            });
            fetchComplainList();
          }
        }
      }
    });
  }

  clearFilter() {
    if (_selectedPartyName != null ||
        _selectedEngineerName != null ||
        _selectedComplainNo != null) {
      _selectedPartyName = null;
      _selectedComplainNo = null;
      complainNoController.clear();
      if (AppGlobals.user!.roles!.first.id == 2) {
        _selectedEngineerName = null;
      }
      reset();
    }
  }

  Future<void> reset() async {
    _page = 1;
    complainList.clear();
    fetchComplainList();
  }

  fetchComplainStatusData() async {
    try {
      var response = await ComplainRepository().getComplainStatusResponse();

      if (response.success!) {
        complainStatusList = response.data!;
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

  fetchComplainNo() async {
    try {
      var response = await ComplainRepository().getAllComplainNo();

      if (response.success) {
        List<AllComplainNoData> list = response.data;
        list.sort((a, b) {
          return a.complaintNo!.compareTo(b.complaintNo!);
        });
        allComplainNoList = list;
        isComplainNo = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isComplainNo = false;
      });
    } finally {
      setState(() {
        isComplainNo = false;
      });
    }
  }

  fetchAllEngineersData() async {
    try {
      var response = await EngineerRepository().getAllEngineerResponse();

      if (response.success) {
        List<EngineerDataResponse> list = response.data;
        list.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        engineerNameList = list;
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
      setState(() {
        isInitial = true;
      });

      var response = await ComplainRepository().getComplainListResponse(
        statusId: _selectedComplainStatus?.id,
        partyId: _selectedPartyName?.id,
        engineerId: _selectedEngineerName?.id,
        isAssign: _selectAssignStatus?.id,
        complainNo: complainNoController.text.isEmpty ? null : int.parse(complainNoController.text),
        page: _page,
      );

      if (response.success!) {
        data = response.data!;
        complainList = complainList + response.data!.data!;
        isInitial = false;
        isLoadingMore = false;
      } else {
        isLoadingMore = false;
      }
      setState(() {});
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  assignToEngineer(BuildContext context,{int? complainId, List<EngineerDataResponse>? lstSelectedEngineer}) async {
    try {
      var response = await EngineerRepository().getAssignToEngineerResponse(
        complainId: complainId,
        lstSelectedEngineer: lstSelectedEngineer
      );

      if (response.success) {
        AppGlobals.showMessage(response.message, MessageType.success);
        reset();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.isNotEmpty) {
        complainNoController.text = query.trim();
        reset();
      } else {
        complainNoController.clear();
        reset();
      }
    });
  }

  List<DropdownMenuItem<AssignStatus>> buildDropdownAssignStatusItems(
      List<AssignStatus> assignList) {
    List<DropdownMenuItem<AssignStatus>> items = [];
    for (AssignStatus item in assignList as Iterable<AssignStatus>) {
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

  List<DropdownMenuItem<EngineerDataResponse>> buildDropdownEngineerNameItems(
      List<EngineerDataResponse> deliveryStatusList) {
    List<DropdownMenuItem<EngineerDataResponse>> items = [];
    for (EngineerDataResponse item in deliveryStatusList as Iterable<EngineerDataResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Wrap(
            children: [
              Text(
                item.name,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "(${item.pendingComplaints})",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<AllComplainNoData>> buildDropdownComplainNoItems(
      List<AllComplainNoData> complainNoList) {
    List<DropdownMenuItem<AllComplainNoData>> items = [];
    for (AllComplainNoData item in complainNoList as Iterable<AllComplainNoData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.complaintNo!,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  void onTapped(int i) {
    // fetchAll();

    // if (guest_checkout_status.$ && (i == 2)) {
    // } else if (!guest_checkout_status.$ && (i == 5)) {
    // }

    // if (i == 4) {
    //   routes.push("/dashboard");
    //   return;
    // }

    setState(() {
      _currentIndex = i;
    });
    //print("i$i");
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
          PreviousComplainPDF(complainId: complainList[listIndex].id),
          false,
        );
        break;
      case 2:
        bool result = await AppGlobals.navigateAndReturn(
          context,
          InOutScreen(complainData: complainList[listIndex]),
          false,
        );
        if (result) reset();
        break;
      case 3:
        if (AppGlobals.user!.roles!.first.id == 2 && complainList[listIndex].isAssign != 1) {
          openAssignEngineerDialog(listIndex, context);
        } else {
          AppGlobals.showMessage(AppString.engineerAlreadyAssign, MessageType.success);
        }
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
              children: [
                buildFilterDropDown(context),
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

  SingleChildScrollView buildFilterDropDown(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isStatus
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.complainStatus,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isStatus
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.045,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<ComplainStatusData>(
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            width: MediaQuery.of(context).size.width * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.35,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedComplainStatus,
                          items: _dropdownComplainStatusItems,
                          onChanged: (ComplainStatusData? selectedFilter) {
                            setState(() {
                              _selectedComplainStatus = selectedFilter;
                            });
                            reset();
                          },
                        ),
                      ),
                    ),
            ],
          ),
          if (AppGlobals.user != null && AppGlobals.user!.roles!.first.id == 2)
            const FieldSpace(SpaceType.small),
          if (AppGlobals.user != null && AppGlobals.user!.roles!.first.id == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppString.assignStatus,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const FieldSpace(SpaceType.extraSmall),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<AssignStatus>(
                      hint: Text(
                        AppString.assignStatus,
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
                      isExpanded: true,
                      dropdownStyleData: DropdownStyleData(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          color: Colors.white,
                        ),
                      ),
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.4,
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                      ),
                      value: _selectAssignStatus,
                      items: _dropdownAssignStatusItems,
                      onChanged: (AssignStatus? selectedFilter) {
                        setState(() {
                          _selectAssignStatus = selectedFilter;
                        });
                        reset();
                      },
                    ),
                  ),
                ),
              ],
            ),
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppString.complainNo,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const FieldSpace(SpaceType.extraSmall),
              Container(
                height: MediaQuery.of(context).size.height * 0.045,
                width: MediaQuery.of(context).size.width * 0.38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimen.textRadius),
                ),
                child: TextFormField(
                  controller: complainNoController,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: AppString.complainNo,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimen.textRadius),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimen.textRadius),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall, vertical: 0),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [PhoneInputFormatter(), LengthLimitingTextInputFormatter(10)],
                  maxLines: 1,
                  onChanged: _onSearchChanged,
                  validator: (value) {
                    bool isValid = Validations.validateInput(value, true);

                    if (isValid == false) {
                      return AppString.enterCode;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
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
                      width: MediaQuery.of(context).size.width * 0.56,
                      height: MediaQuery.of(context).size.height * 0.045,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
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
                            width: MediaQuery.of(context).size.width * 0.56,
                            maxHeight: MediaQuery.of(context).size.height / 1.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            width: MediaQuery.of(context).size.width * 0.56,
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
          ),
          if (AppGlobals.user != null && AppGlobals.user!.roles!.first.id == 2)
            const FieldSpace(SpaceType.small),
          if (AppGlobals.user != null && AppGlobals.user!.roles!.first.id == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isEngineer
                    ? ShimmerHelper().buildBasicShimmer(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.015,
                        radius: 4)
                    : const Text(
                        AppString.engineerName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                const FieldSpace(SpaceType.extraSmall),
                isEngineer
                    ? ShimmerHelper().buildBasicShimmer(
                        width: MediaQuery.of(context).size.width * 0.56,
                        height: MediaQuery.of(context).size.height * 0.045,
                        radius: AppDimen.textRadius)
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.045,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<EngineerDataResponse>(
                            hint: Text(
                              AppString.selectEngineer,
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
                              maxHeight: MediaQuery.of(context).size.height / 1.5,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimen.padding, vertical: 0),
                            ),
                            value: _selectedEngineerName,
                            items: _dropdownEngineerItems,
                            isExpanded: true,
                            onChanged: (EngineerDataResponse? selectedFilter) {
                              setState(() {
                                _selectedEngineerName = selectedFilter;
                              });
                              reset();
                            },
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                engineerEditingController.clear();
                              }
                            },
                            dropdownSearchData: DropdownSearchData(
                              searchController: engineerEditingController,
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
                                  controller: engineerEditingController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: AppString.searchForEngineer,
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value!.name.toLowerCase().contains(searchValue);
                              },
                            ),
                          ),
                        ),
                      ),
              ],
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
                  height: MediaQuery.of(context).size.height * 0.045,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
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

  GestureDetector buildComplainCard(index, ComplainData complainData) {
    return GestureDetector(
      onTap: () async {
        if (AppGlobals.user != null) {
          switch (AppGlobals.user!.roles!.first.id) {
            case 2:
              if ((complainList[index].isAssign == 0 && complainList[index].statusId == 1)) {
                openAssignEngineerDialog(index, context);
              }
              break;
            case 4:
              if (complainList[index].statusId == 1 || complainList[index].statusId == 2) {
                bool result = await AppGlobals.navigateAndReturn(
                  context,
                  InOutScreen(complainData: complainList[index]),
                  false,
                );
                if (result) reset();
              }
              break;
          }
        }
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
                        child: Row(
                          children: [
                            RichText(text: TextSpan(
                              text: "${complainData.complaintNo}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                if(complainData.isCustomerComplain == 1)
                                const TextSpan(
                                  text: " / C",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ]
                            ),),
                            // Text(
                            //   "${complainData.complaintNo}",
                            //   maxLines: 2,
                            //   style: const TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 13,
                            //     letterSpacing: 1,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // const FieldSpace(),
                            // if(complainData.isCustomerComplain == 1)
                            //   const Text(
                            //     "C",
                            //     maxLines: 2,
                            //     style: TextStyle(
                            //       color: AppColors.primary,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),

                          ],
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
                          "${complainData.date!}  ${complainData.time!}",
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
                  // if (AppGlobals.user?.roles?.first.id == 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Assign ${AppString.status}",
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
                        child: RichText(
                          text: TextSpan(
                              text: AppGlobals().getAdminStatus(complainData.isAssign),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppGlobals()
                                    .getAdminStatus(complainData.isAssign)
                                    .toLowerCase() ==
                                    "not assign"
                                    ? Colors.red
                                    : AppColors.success,
                              ),
                              children: [
                                if (complainData.engineerAssignDate != null &&
                                    complainData.engineerAssignTime != null)
                                  TextSpan(
                                    text:
                                    " ${complainData.engineerAssignDate}  ${complainData.engineerAssignTime}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                              ]),
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
                            style: TextStyle(
                              color: (AppGlobals.user!.roles!.first.id == 2) ? AppColors.primary : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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
                  if (complainData.engineerInAddress != null)
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
                  if (complainData.engineerOutAddress != null)
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
                  if (complainData.engineerTimeDuration != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            AppString.totalTime,
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
                            complainData.engineerTimeDuration!,
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
                              ? AppString.status
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
                  if(AppGlobals.user!.roles!.first.id == 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          complainData.party!.address! ?? "",
                          maxLines: 4,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const FieldSpace(SpaceType.small),
                      GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Open in Google Maps'),
                                content: const Text('Do you want to open this address in Google Maps?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(); // Close the dialog
                                      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(complainData.party!.address!)}';
                                      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                                      await launchUrl(Uri.parse(googleMapsUrl));
                                      } else {
                                      throw 'Could not launch $googleMapsUrl';
                                      }
                                    },
                                    child: const Text('Open'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Clipboard.setData(ClipboardData(text: complainData.party!.address!));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 0),
                          padding: const EdgeInsets.all(AppDimen.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20,),
                        ),
                      ),
                      // const Expanded(
                      //   child: Text(
                      //     AppString.address,
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 13,
                      //     ),
                      //   ),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      //   child: Text(
                      //     ":",
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //     ),
                      //   ),
                      // ),
                      /*Row(
                        children: [
                          Text(
                            complainData.party!.address! ?? "",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: complainData.party!.address!));
                              // AppGlobals.showMessage("Address copied", MessageType.success);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 0),
                              padding: const EdgeInsets.all(AppDimen.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              ),
                              child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20,),
                            ),
                          ),
                        ],
                      ),*/

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
          child: Text("Previous History"),
        ),
        if (AppGlobals.user!.roles!.first.id == 4 && complainList[listIndex].statusId != 3)
          const PopupMenuItem<MenuOptions>(
            value: MenuOptions.addLocation,
            child: Text("In/Out"),
          ),
        if (AppGlobals.user!.roles!.first.id == 2 && complainList[listIndex].isAssign != 1)
          const PopupMenuItem<MenuOptions>(
            value: MenuOptions.assignToEngineer,
            child: Text("Assign to Engineer"),
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

  openAssignEngineerDialog(int listIndex, BuildContext mainContext) {
    List<EngineerDataResponse> selectedItems = [];
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text("Assign To Engineer"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppString.engineerName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const FieldSpace(SpaceType.extraSmall),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.055,
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
                            width: MediaQuery.of(context).size.width * 0.65,
                            maxHeight: MediaQuery.of(context).size.height * 0.64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
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
                            height: MediaQuery.of(context).size.height * 0.055,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimen.padding, vertical: 0),
                          ),
                          // value: _selectedAssignEngineerName,
                          // items: _dropdownAssignEngineerItems,
                          value: selectedItems.isEmpty ? null : selectedItems.last,
                          items: engineerNameList.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              // label: item.name,
                              child: Row(
                                children: [
                                  StatefulBuilder(
                                      builder: (context, menuSetState) {
                                        return Checkbox(
                                          value: selectedItems.contains(item),
                                          onChanged: (bool? checked) {
                                            if (checked != null) {
                                              menuSetState(() {
                                                if (checked) {
                                                  if (selectedItems.length != 2) {
                                                    selectedItems.add(item);
                                                  } else {
                                                    AppGlobals.showMessage(AppString.atTimeTwoEngineerSelected, MessageType.error);
                                                  }
                                                } else {
                                                  selectedItems.remove(item);
                                                }
                                              });
                                              setState((){});
                                            }
                                          },
                                          checkColor: Colors.white, // Color of the checkmark inside the checkbox
                                          activeColor:  AppColors.primary, // Color of the checkbox border when unchecked
                                          shape: const RoundedRectangleBorder(),
                                        );
                                      }
                                  ),
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          "(${item.pendingComplaints})",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },).toList(),
                          isExpanded: true,
                          selectedItemBuilder: (context) {
                            return engineerNameList.map(
                                  (item) {
                                return Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    selectedItems.map((e) => e.name).toList().join(', '),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ).toList();
                          },
                          onChanged: (EngineerDataResponse? selectedFilter) {
                            // setState(() {
                            //   _selectedAssignEngineerName = selectedFilter;
                            // });
                          },
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              assignEngineerEditingController.clear();
                            }
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: assignEngineerEditingController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 60,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: assignEngineerEditingController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppDimen.padding,
                                    vertical: AppDimen.padding,
                                  ),
                                  hintText: AppString.searchForEngineer,
                                  hintStyle: const TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              return item.value!.name.toLowerCase().contains(searchValue);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      selectedItems.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (selectedItems.isNotEmpty) {
                        assignToEngineer(context, complainId: complainList[listIndex].id, lstSelectedEngineer: selectedItems);
                      } else {
                        AppGlobals.showMessage(AppString.pleaseSelectEngineer, MessageType.error);
                      }

                      // if(controller.selectedItems.isNotEmpty) {
                      // } else {
                      //   AppGlobals.showMessage("Please select engineer", MessageType.error);
                      // }
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              );
            }));
  }
}
