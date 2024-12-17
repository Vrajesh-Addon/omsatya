import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/common_name_response.dart';
import 'package:omsatya/models/complain_machine_response.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/complain_types_response.dart';
import 'package:omsatya/models/customer_machine_response.dart';
import 'package:omsatya/models/engineer_response.dart';
import 'package:omsatya/models/get_complain_no_response.dart';
import 'package:omsatya/models/party_details_by_code_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/customer_repository.dart';
import 'package:omsatya/repository/engineer_repository.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class AdminAddComplain extends StatefulWidget {
  final Function(int index)? changeIndex;

  const AdminAddComplain({super.key, this.changeIndex});

  @override
  State<AdminAddComplain> createState() => _AdminAddComplainState();
}

class _AdminAddComplainState extends State<AdminAddComplain> {
  final GlobalKey<FormState> _formKeyAddComplain = GlobalKey<FormState>();

  final TextEditingController _partyCodeController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _complainTypeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _engNameController = TextEditingController();

  List<ComplainTypesData> complainTypesList = [];
  List<Party> partyNameList = [];
  List<CommonNameData> serviceTypeList = [];
  List<MachineData> machineDataList = [];
  List<ComplainMachineData> complainMachineDataList = [];
  List<EngineerDataResponse> engineerNameList = [];

  List<DropdownMenuItem<ComplainTypesData>>? _dropdownComplainTypesItems;
  List<DropdownMenuItem<Party>>? _dropdownPartyNameItems;
  List<DropdownMenuItem<MachineData>>? _dropdownMachineItems;
  List<DropdownMenuItem<CommonNameData>>? _dropdownServiceTypeItems;

  ComplainTypesData? _selectedComplainTypes;
  Party? _selectedPartyNames;
  MachineData? _selectedMachine;
  CommonNameData? _selectedServiceType;

  PartyDetailsByCodeResponse? partyDetailsByCodeResponse;

  GetComplainNoResponse? complainNoResponse;

  int defaultComplainStatusKey = 1;
  int defaultServiceTypeKey = 2;

  String date = "";
  String time = "";

  bool isLoading = false;
  bool isStatus = true;
  bool isInitial = false;

  String avatar = "";
  String videoAvtar = "";
  String recordingPath = "";

  File? imageFile;
  File? videoFile;
  File? audioFile;

  Timer? _debounce;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _partyCodeController.dispose();
    _productNameController.dispose();
    _complainTypeController.dispose();
    _remarksController.dispose();
    _partyNameController.dispose();
    _engNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimen.padding),
          child: _buildComplainForm(context),
        ),
      ),
    );
  }

  Column _buildComplainForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextFormField(
          controller: _partyCodeController,
          decoration: const InputDecoration(
            labelText: AppString.code,
            // prefixIcon: Icon(
            //   Icons.pin_outlined,
            //   color: AppColors.primary,
            // ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          inputFormatters: [LengthLimitingTextInputFormatter(10)],
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
        const FieldSpace(),
        DropdownButtonFormField2(
          value: _selectedPartyNames,
          items: _dropdownPartyNameItems,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: AppString.partyName,
            // prefixIcon: Icon(
            //   Icons.person_rounded,
            //   color: AppColors.primary,
            // ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: MediaQuery.of(context).size.height * 0.64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimen.textRadius),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
          ),
          onChanged: (value) {
            setState(() {
              _selectedPartyNames = value;
              _partyCodeController.text = _selectedPartyNames!.code!;
              machineDataList.clear();
              _selectedMachine = null;
              _dropdownMachineItems = null;
            });
            fetchMachineDataByParty(_selectedPartyNames!.id!);
          },
          validator: (value) {
            if (value == null) {
              return AppString.selectPartyName;
            }
            return null;
          },
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              _partyNameController.clear();
            }
          },
          dropdownSearchData: DropdownSearchData(
            searchController: _partyNameController,
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
                controller: _partyNameController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimen.padding,
                    vertical: AppDimen.paddingSmall,
                  ),
                  hintText: AppString.partyName,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (DropdownMenuItem<Party>? item, searchValue) {
              return item!.value!.name!.toLowerCase().contains(searchValue);
            },
          ),
        ),
        const FieldSpace(),
        Row(
          children: [
            Expanded(
              child: buildPartyMachineList(),
            ),
          ],
        ),
      ],
    );
  }

  buildPartyMachineList() {
    if (isInitial && complainMachineDataList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (complainMachineDataList.isNotEmpty) {
      return SingleChildScrollView(
        // controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        primary: true,
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 6,
            );
          },
          itemCount: complainMachineDataList.first.machineData!.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildMachineItemCard(
                index, machineDataList[index], complainMachineDataList.first);
          },
        ),
      );
    } else if (!isInitial && complainMachineDataList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            "No data found",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  GestureDetector buildMachineItemCard(
      index, MachineData machineData, ComplainMachineData complainMachineData) {
    final currentDate = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(currentDate);
    DateTime cDate = DateFormat('yyyy-MM-dd').parse(date);
    DateTime expiredDate = DateFormat('yyyy-MM-dd').parse(machineData.serviceExpiryDate!);

    return GestureDetector(
      onTap: cDate.isAfter(expiredDate) ? null : () async {
        if(machineData.cMessage != null && machineData.cMessage!.isEmpty) {
          openAssignEngineerDialog(index, context, machineData);
        } else {
          AppGlobals.showMessage("Complain already created. Complain no is [${machineData.cMessage!}].", MessageType.error);
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
                  //Name
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
                          complainMachineData.name!,
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
                  //Mobile
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
                          complainMachineData.phoneNo!,
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
                          "${machineData.serialNo!} / ${machineData.mcNo!}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppString.serviceType,
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
                          "Warranty",
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppString.status,
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
                          "Pending",
                          maxLines: 2,
                          style: TextStyle(
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
                          machineData.serviceExpiryDate ?? "",
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

  openAssignEngineerDialog(int listIndex, BuildContext mainContext, MachineData machineData) {
   String date = AppGlobals().getCurrentDate();
   String time = AppGlobals().getCurrentTime();
   List<EngineerDataResponse> selectedItems = [];

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text("Create complain"),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKeyAddComplain,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField2<ComplainTypesData>(
                          value: _selectedComplainTypes,
                          items: _dropdownComplainTypesItems,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: AppString.complainType,
                            // prefixIcon: Icon(
                            //   Icons.warning_amber_rounded,
                            //   color: AppColors.primary,
                            // ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: MediaQuery.of(context).size.height / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedComplainTypes = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return AppString.selectComplainType;
                            }
                            return null;
                          },
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              _complainTypeController.clear();
                            }
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: _complainTypeController,
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
                                controller: _complainTypeController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppDimen.padding,
                                    vertical: AppDimen.paddingSmall,
                                  ),
                                  hintText: AppString.complainType,
                                  hintStyle: const TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (DropdownMenuItem<ComplainTypesData>? item, searchValue) {
                              return item!.value!.name.toLowerCase().contains(searchValue);
                            },
                          ),
                        ),
                        const FieldSpace(),
                        TextFormField(
                          controller: _remarksController,
                          decoration: const InputDecoration(
                            labelText: AppString.remarks,
                            // prefixIcon: Icon(
                            //   Icons.note_alt_outlined,
                            //   color: AppColors.primary,
                            // ),
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            // bool isValid;
                            //
                            // isValid = Validations.validateInput(value, true);
                            //
                            // if (isValid == false) {
                            //   return AppString.enterRemarks;
                            // }
                            return null;
                          },
                        ),
                        const FieldSpace(),
                        DropdownButtonFormField2<EngineerDataResponse>(
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
                          onChanged: (value) {
                            // setState(() {
                            //   _selectedEngineerName = value;
                            // });
                          },
                          decoration: const InputDecoration(
                            labelText: AppString.assignEngineer,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: MediaQuery.of(context).size.height / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          validator: (value) {
                            // if (value == null) {
                            //   return AppString.selectAssignEngineer;
                            // }
                            return null;
                          },
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              _engNameController.clear();
                            }
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: _engNameController,
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
                                controller: _engNameController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppDimen.padding,
                                    vertical: AppDimen.paddingSmall,
                                  ),
                                  hintText: AppString.searchForEngineer,
                                  hintStyle: const TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn:
                                (DropdownMenuItem<EngineerDataResponse>? item, searchValue) {
                              return item!.value!.name.toLowerCase().contains(searchValue);
                            },
                          ),
                        ),
                        const FieldSpace(),
                        Text(
                          "${AppString.dateTime}: $date $time",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const FieldSpace(),
                        if (complainNoResponse != null)
                          Text(
                            "${AppString.complainNo}: [${complainNoResponse!.data}]",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _selectedComplainTypes = null;
                      selectedItems.clear();
                      _remarksController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                  TextButton(
                    onPressed: () {
                      onSubmit(machineData: machineData, date: date, time: time, lstSelectedEngineer: selectedItems);
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              );
            }));
  }

  init() async {
    // date = AppGlobals().getCurrentDate();
    // time = AppGlobals().getCurrentTime();

    // _dateTimeController.text = "$date  $time";
    _productNameController.text = "1223*400*800*1500 [MTS+SC]- 1234- 01111";

    await fetchComplainNoData();
    await fetchPartyNameData();
    await fetchComplainTypeData();
    await fetchServiceType();
    await fetchAllEngineersData();

    _dropdownComplainTypesItems = buildDropdownComplainTypesItems(complainTypesList);
    _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
    _dropdownServiceTypeItems = buildDropdownServiceTypeItems(serviceTypeList);

    for (int x = 0; x < _dropdownServiceTypeItems!.length; x++) {
      if (_dropdownServiceTypeItems![x].value!.id == defaultServiceTypeKey) {
        _selectedServiceType = _dropdownServiceTypeItems![x].value;
      }
    }
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.isNotEmpty) {
        // fetchPartyDataByCode(query);
        Party? party = partyNameList.firstWhere((element) {
          return element.code!.toLowerCase() == query.toLowerCase();
        }, orElse: () {
          return Party.fromJson({});
        });

        if (party != null && party.code != null) {
          _selectedPartyNames = party;

          machineDataList.clear();
          _selectedMachine = null;
          _dropdownMachineItems = null;
          await fetchMachineDataByParty(_selectedPartyNames!.id);
          _dropdownMachineItems = buildDropdownMachineItems(machineDataList);
        } else {
          partyNameList.clear();
          _selectedPartyNames = null;
          _dropdownPartyNameItems = null;

          machineDataList.clear();
          _selectedMachine = null;
          _dropdownMachineItems = null;
          await fetchPartyNameData();
          _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
        }
      } else {
        partyNameList.clear();
        _selectedPartyNames = null;
        _dropdownPartyNameItems = null;

        machineDataList.clear();
        _selectedMachine = null;
        _dropdownMachineItems = null;
        await fetchPartyNameData();
        _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
      }
    });
  }

  fetchPartyDataByCode(String partyCode) async {
    try {
      var response = await CustomerRepository().getPartyDetailsByPartyCode(partyCode);

      if (response.success!) {
        if (response.data == null) {
          AppGlobals.showMessage("Enter wrong party code", MessageType.error);
        } else {
          partyDetailsByCodeResponse = response;
          partyNameList.clear();
          partyNameList.add(partyDetailsByCodeResponse!.data!);
          _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
          _selectedPartyNames = partyDetailsByCodeResponse!.data;

          machineDataList.clear();
          _selectedMachine = null;
          _dropdownMachineItems = null;
          await fetchMachineDataByParty(_selectedPartyNames!.id);
          _dropdownMachineItems = buildDropdownMachineItems(machineDataList);
          setState(() {});
        }
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  void onSubmit({MachineData? machineData, String? date, String? time, List<EngineerDataResponse>? lstSelectedEngineer}) async {
    try {
      if (!_formKeyAddComplain.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      var response = await ComplainRepository().getComplainAddResponse(
        date: date,
        time: time,
        partyId: complainMachineDataList.first.id.toString(),
        statusId: "1",
        complainNo: complainNoResponse!.data.toString(),
        complainTypeId: _selectedComplainTypes!.id.toString(),
        productId: machineData!.product!.id.toString(),
        salesEntryId: machineData.id.toString(),
        serviceTypeId: "2",
        remarks: _remarksController.text.trim(),
        image: imageFile,
        video: videoFile,
        audio: recordingPath.isEmpty ? null : File(recordingPath),
        engineerId: lstSelectedEngineer?.first.id,
        jointEngineerId: lstSelectedEngineer?.last.id,
      );

      if (!response.success) {
        isLoading = false;
        AppGlobals.showMessage(response.message, MessageType.error);
        setState(() {});
        return;
      }

      if (response.success) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage(response.message, MessageType.success);
        isLoading = false;
        if (mounted) {
          Navigator.pop(context);
          _selectedPartyNames = null;
          complainMachineDataList.clear();
          machineDataList.clear();
          _partyCodeController.clear();
          fetchComplainNoData();
          // widget.changeIndex!.call(1);
        }
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  fetchComplainNoData() async {
    try {
      var response = await ComplainRepository().generateComplainNo();

      if (response.success) {
        complainNoResponse = response;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
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
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  fetchMachineDataByParty(int? partyId) async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await SalesRepository().getMachineDataByParty(partyId!);

      setState(() {
        isInitial = false;
      });

      if (response.success) {
        complainMachineDataList = response.data;
        machineDataList = response.data.first.machineData!;
        _dropdownMachineItems = buildDropdownMachineItems(machineDataList);
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

  fetchServiceType() async {
    try {
      var response = await SalesRepository().getServiceType();

      if (response.success!) {
        List<CommonNameData> list = response.data;
        list.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        serviceTypeList = list;
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

  fetchComplainTypeData() async {
    try {
      var response = await ComplainRepository().getComplainTypesResponse();

      if (response.success) {
        List<ComplainTypesData> list = response.data;
        list.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        complainTypesList = list;
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
      var response = await ComplainRepository().getAllPartyResponse();

      if (response.success) {
        List<Party> list = response.data;
        list.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        partyNameList = list;
        // isParty = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        // isParty = false;
      });
    } finally {
      setState(() {
        // isParty = false;
      });
    }
  }

  List<DropdownMenuItem<ComplainTypesData>> buildDropdownComplainTypesItems(
      List<ComplainTypesData> complainTypesList) {
    List<DropdownMenuItem<ComplainTypesData>> items = [];
    for (ComplainTypesData item in complainTypesList as Iterable<ComplainTypesData>) {
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

  List<DropdownMenuItem<Party>> buildDropdownPartyNameItems(List<Party> machineDataList) {
    List<DropdownMenuItem<Party>> items = [];
    for (Party item in machineDataList as Iterable<Party>) {
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

  List<DropdownMenuItem<MachineData>> buildDropdownMachineItems(List<MachineData> machineDataList) {
    List<DropdownMenuItem<MachineData>> items = [];
    for (MachineData item in machineDataList as Iterable<MachineData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.product!.name!.toCapitalize(),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<CommonNameData>> buildDropdownServiceTypeItems(
      List<CommonNameData> complainTypesList) {
    List<DropdownMenuItem<CommonNameData>> items = [];
    for (CommonNameData item in complainTypesList as Iterable<CommonNameData>) {
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

  List<DropdownMenuItem<ComplainStatusData>> buildDropdownStatusTypeItems(
      List<ComplainStatusData> complainTypesList) {
    List<DropdownMenuItem<ComplainStatusData>> items = [];
    for (ComplainStatusData item in complainTypesList as Iterable<ComplainStatusData>) {
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

  void handleOnImageChanged(file) async {
    if (file == null) {
      avatar = "";
    } else {
      File filePath = File(file.path);
      Uint8List imageBytes = await filePath.readAsBytes();
      String base64string = base64.encode(imageBytes);
      avatar = base64string;
      imageFile = filePath;
    }
    setState(() {});
  }

  void handleOnVideoChanged(file) async {
    if (file == null) {
      avatar = "";
    } else {
      File filePath = File(file.path);
      Uint8List imageBytes = await filePath.readAsBytes();
      String base64string = base64.encode(imageBytes);

      videoFile = filePath;

      // Uint8List? uint8list = await VideoThumbnail.thumbnailData(
      //   video: videoFile.path,
      //   imageFormat: ImageFormat.JPEG,
      //   maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      //   quality: 25,
      // );
      // String base64string = base64.encode(uint8list!);

      avatar = base64string;
    }
    setState(() {});
  }
}
