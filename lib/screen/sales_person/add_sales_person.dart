import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/location_helper.dart';
import 'package:omsatya/models/common_name_response.dart';
import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';
import 'package:omsatya/models/product_response.dart';
import 'package:omsatya/models/sales_person/sales_person_response.dart';
import 'package:omsatya/models/sales_person/sales_person_task.dart';
import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/repository/todo_repository.dart';
import 'package:omsatya/screen/get_all_contacts.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class AddSalesPerson extends StatefulWidget {
  final LeadSalesPersonData? leadSalesPersonData;

  const AddSalesPerson({super.key, this.leadSalesPersonData});

  @override
  State<AddSalesPerson> createState() => _AddSalesPersonState();
}

class _AddSalesPersonState extends State<AddSalesPerson> {
  final TextEditingController _txtDateTimeController = TextEditingController();
  final TextEditingController _txtPhoneController = TextEditingController();
  final TextEditingController _txtPartyController = TextEditingController();
  final TextEditingController _txtAddressController = TextEditingController();
  final TextEditingController _txtLocationAddressController = TextEditingController();
  final TextEditingController _txtNextDateController = TextEditingController();
  final TextEditingController _txtNextTimeController = TextEditingController();
  final TextEditingController _txtCommentFirstController = TextEditingController();
  final TextEditingController _txtCommentSecondController = TextEditingController();
  final TextEditingController _txtSearchProductController = TextEditingController();
  final TextEditingController _txtSearchSalesController = TextEditingController();
  final TextEditingController _txtSearchAreaController = TextEditingController();
  final TextEditingController _txtSearchStatusController = TextEditingController();

  final GlobalKey<FormState> _formKeySalesPerson = GlobalKey<FormState>();

  List<CommonNameData> areaList = [];
  List<PriorityResponse> priorityList = [];
  List<PriorityResponse> statusList = [];
  List<ProductData> productList = [];
  List<ProductData> salesProductList = [];
  List<SalesPersonData> salesPersonList = [];

  List<DropdownMenuItem<CommonNameData>>? _dropdownAreaItems;
  List<DropdownMenuItem<PriorityResponse>>? _dropdownPriority;
  List<DropdownMenuItem<PriorityResponse>>? _dropdownStatus;
  List<DropdownMenuItem<ProductData>>? _dropdownProducts;
  List<DropdownMenuItem<ProductData>>? _dropdownSalesProducts;
  List<DropdownMenuItem<SalesPersonData>>? _dropdownSalesPerson;
  List<DropdownMenuItem<SalesPersonData>>? _dropdownSalesPerson2;

  CommonNameData? _selectedAreaData;
  PriorityResponse? _selectedPriority;
  PriorityResponse? _selectedStatus;
  ProductData? _selectedProducts;
  ProductData? _selectedSalesProducts;
  SalesPersonData? _selectedSalesPerson;
  SalesPersonData? _selectedSalesPerson2;

  double latitude = 0.0;
  double longitude = 0.0;
  String? locationAddress;

  bool isLoading = false;

  DateTime? selectedReminderDate;
  TimeOfDay selectedRemainderTime = TimeOfDay.now();
  DateTime? picked;
  DateTime selectedCurrentTime = DateTime.now();

  String date = "";
  String time = "";
  String pickedTime = "";

  int i = 0;

  @override
  void initState() {
    date = AppGlobals().getCurrentDate();
    time = AppGlobals().getCurrentTime();
    _txtDateTimeController.text = "$date  $time";
    // _txtNextDateController.text = AppGlobals().getCurrentDate();
    // _txtNextTimeController.text = AppGlobals().getCurrentTime();

    init();
    super.initState();
  }


  @override
  void dispose() {
    _txtDateTimeController.dispose();
    _txtPhoneController.dispose();
    _txtPartyController.dispose();
    _txtAddressController.dispose();
    _txtLocationAddressController.dispose();
    _txtNextDateController.dispose();
    _txtNextTimeController.dispose();
    _txtCommentFirstController.dispose();
    _txtCommentSecondController.dispose();
    _txtSearchProductController.dispose();
    _txtSearchSalesController.dispose();
    _txtSearchAreaController.dispose();
    _txtSearchStatusController.dispose();
    super.dispose();
  }

  init() async {
    await fetchPriority();
    // await fetchStatus();
    _dropdownPriority = buildDropdownPriorityItems(priorityList);
    // _dropdownStatus = buildDropdownPriorityItems(statusList);

    if(widget.leadSalesPersonData == null) {
      await fetchAreaData();
      // await fetchProducts();
      await fetchSalesProducts();
      // await fetchSalesPerson();

      _dropdownAreaItems = buildDropdownCommonItems(areaList);
      // _dropdownProducts = buildDropdownProductItems(productList);
      _dropdownSalesProducts = buildDropdownProductItems(salesProductList);
      // _dropdownSalesPerson = buildDropdownSalesPersonItems(salesPersonList);
      for (int x = 0; x < _dropdownPriority!.length; x++) {
        if (_dropdownPriority![x].value!.id == 5) { // default set under process id
          _selectedPriority = _dropdownPriority![x].value;
        }
      }

    }

    if (widget.leadSalesPersonData != null) {
      if(widget.leadSalesPersonData!.product != null) {
        if (widget.leadSalesPersonData!.product!.name == "EMBROIDERY MACHINE") {
          await fetchSalesPerson(isEmb: 1, isCir: 0);
        } else {
          await fetchSalesPerson(isEmb: 0, isCir: 1);
        }
      }
      _dropdownSalesPerson = buildDropdownSalesPersonItems(salesPersonList);

      _txtDateTimeController.text = "${widget.leadSalesPersonData!.date} ${widget.leadSalesPersonData!.time}";
      _txtPhoneController.text = widget.leadSalesPersonData!.mobileNo ?? "";
      _txtPartyController.text = widget.leadSalesPersonData!.partyname ?? "";
      _txtAddressController.text = widget.leadSalesPersonData!.address ?? "";
      _txtLocationAddressController.text = widget.leadSalesPersonData!.locationAddress ?? "";

      // for (int x = 0; x < _dropdownSalesPerson!.length; x++) {
      //   if (_dropdownSalesPerson![x].value!.id == widget.leadSalesPersonData!.salesPersonTask!.last.priorityId) {
      //     _selectedSalesPerson = _dropdownSalesPerson![x].value;
      //   }
      // }

      for (int x = 0; x < _dropdownPriority!.length; x++) {
        if (_dropdownPriority![x].value!.id == widget.leadSalesPersonData!.salesPersonTask!.last.priorityId) {
          _selectedPriority = _dropdownPriority![x].value;
        }
      }
    }
  }

  Future<String?> _getCurrentLocation(BuildContext context, {isReload = false}) async {
    Position? currentPosition = await LocationHelper.getCurrentPosition(context);
    String? currentAddress = await LocationHelper.getAddressFromLatLng(currentPosition!);
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    locationAddress = currentAddress;
    _txtLocationAddressController.text = locationAddress!;
    if (isReload) {
      setState(() {});
    }
    return currentAddress;
  }

  fetchAreaData() async {
    try {
      var response = await SalesRepository().getArea();

      if (response.success) {
        List<CommonNameData> list = response.data;
        list.removeWhere((element) => element.name == "--");
        areaList = list;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  fetchPriority() async {
    try {
      var response = await TodoRepository().getPriorityResponse(priority: 0, status: 1);

      if (response.success) {
        priorityList = response.data;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  fetchStatus() async {
    try {
      var response = await TodoRepository().getPriorityResponse(priority: 0, status: 1);

      if (response.success) {
        statusList = response.data;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  fetchProducts() async {
    try {
      var response = await SalesRepository().getAllProduct();

      if (response.success) {
        List<ProductData> list = response.data;
        productList = list;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  fetchSalesProducts() async {
    try {
      var response = await SalesRepository().getAllSalesProduct();

      if (response.success) {
        List<ProductData> list = response.data;
        salesProductList = list;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  fetchSalesPerson({required int isEmb, required int isCir}) async {
    try {
      var response = await SalesRepository().getSalesPerson(isEmb: isEmb, isCir: isCir);

      if (response.success) {
        List<SalesPersonData> list = response.data;
        salesPersonList = list;
        _dropdownSalesPerson = buildDropdownSalesPersonItems(salesPersonList);
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {
    }
  }

  Future<void> _selectReminderDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedReminderDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedReminderDate) {
      setState(() {
        selectedReminderDate = picked;
        _txtNextDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: TimePickerSpinner(
          is24HourMode: true,
          normalTextStyle: const TextStyle(
              fontSize: 24,
              color: Colors.black
          ),
          highlightedTextStyle: const TextStyle(
            fontSize: 24,
            color: AppColors.primary,
          ),
          time: DateTime.now(),
          // isShowSeconds: true,
          spacing: 50,
          itemHeight: 80,
          isForce2Digits: true,
          // minutesInterval: 5,
          onTimeChange: (time) {
            showMessage("Time picker ==> $time");
            setState(() {
              // _dateTime = time;
              picked = time;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(onPressed: () {
            if (picked != null && picked != selectedCurrentTime) {
              setState(() {
                pickedTime = _formatTime(picked!);
                _txtNextTimeController.text = pickedTime;
              });
            }
            Navigator.of(context).pop();
          }, child: const Text("Done"),),
        ],
      ),);

   /* final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedRemainderTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedRemainderTime) {
      setState(() {
        pickedTime = _formatTime(picked);
        _txtNextTimeController.text = pickedTime;
      });
    }*/
  }

  // String _formatTime(TimeOfDay time) {
  //   final hour = time.hour.toString().padLeft(2, '0');
  //   final minute = time.minute.toString().padLeft(2, '0');
  //   return '$hour:$minute';
  // }

  String _formatTime(DateTime dateTime) {
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }

  addSalesPerson() async {
    try {
      if (!_formKeySalesPerson.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      var body = {
        "area_id": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.areaId!.toString() : _selectedAreaData == null ? "1" : _selectedAreaData!.id.toString(),
        "product_id": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.productId == null ? "" : widget.leadSalesPersonData!.productId!.toString() : _selectedSalesProducts == null ? "" : _selectedSalesProducts!.id.toString(),
        "lead_stage_id": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.leadStageId == null ? "" : widget.leadSalesPersonData!.leadStageId!.toString() : _selectedPriority == null ? "" : _selectedPriority!.id.toString(),
        "sale_user_id": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.saleUserId.toString() : AppGlobals.user!.id!.toString(),
        // "sale_assign_user_id": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.saleAssignUser == null ? "" : widget.leadSalesPersonData!.saleAssignUser!.id.toString() : _selectedSalesPerson == null ? "" : _selectedSalesPerson!.id.toString(),
        // "sale_assign_user_id": _selectedSalesPerson != null ? _selectedSalesPerson!.id.toString() : widget.leadSalesPersonData!.saleAssignUser == null ? "" : widget.leadSalesPersonData!.saleAssignUser!.id.toString(),
        "sale_assign_user_id": _selectedSalesPerson?.id?.toString()
            ?? widget.leadSalesPersonData?.saleAssignUser?.id?.toString()
            ?? "",
        "date": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.date! : date,
        "time": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.time! : time,
        "mobile_no": _txtPhoneController.text.trim(),
        "partyname": _txtPartyController.text.trim(),
        "address": _txtAddressController.text.trim(),
        "location_Address": widget.leadSalesPersonData != null ? _txtLocationAddressController.text : _txtLocationAddressController.text,
        "latitude": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.latitude! : latitude.toString(),
        "logitude": widget.leadSalesPersonData != null ? widget.leadSalesPersonData!.logitude! : longitude.toString(),
        "remarks": "",
        "next_reminder_date": _txtNextDateController.text,
        "next_reminder_time": _txtNextTimeController.text,
      };


      if (widget.leadSalesPersonData == null) {
        body.addAll({
          'todo_task[$i][date]': _txtNextDateController.text,
          'todo_task[$i][time]':  _txtNextTimeController.text,
          // 'todo_task[$i][assign_user_id]': _selectedSalesPerson!.id.toString(),
          'todo_task[$i][comment_first]': _txtCommentFirstController.text,
          'todo_task[$i][comment_second]':
          _txtCommentSecondController.text.isEmpty ? "-" : _txtCommentSecondController.text,
          'todo_task[$i][priority_id]': _selectedPriority == null ? "" : _selectedPriority!.id.toString(),
          "status_id": _selectedPriority!.id.toString(),
        });
      } else {
        body.addAll({
          "status_id": _selectedPriority!.id.toString(),
          "closed_by": AppGlobals.user!.id!.toString(),
          "closed_date": AppGlobals().getCurrentDate(),
        });

        widget.leadSalesPersonData!.salesPersonTask!.add(SalesPersonTask(
          date: _txtNextDateController.text,
          time:  _txtNextTimeController.text,
          // assignUserId: _selectedSalesPerson!.id,
          commentFirst: _txtCommentFirstController.text,
          commentSecond: _txtCommentSecondController.text.isEmpty ? "-" : _txtCommentSecondController.text,
          priorityId: _selectedPriority!.id,
        ));

        for (i = 0; i < widget.leadSalesPersonData!.salesPersonTask!.length; i++) {
          SalesPersonTask data = widget.leadSalesPersonData!.salesPersonTask![i];

          showMessage("Assign user ID ==> ${data.assignUserId}");

          body.addAll({
            'todo_task[$i][date]': data.date ?? "",
            'todo_task[$i][time]': data.time ?? "",
            // 'todo_task[$i][assign_user_id]': data.assignUserId.toString(),
            'todo_task[$i][comment_first]': data.commentFirst ?? "",
            'todo_task[$i][comment_second]': data.commentSecond ?? "",
            'todo_task[$i][priority_id]': data.priorityId!.toString(),
          });
        }
      }
      //
      // showMessage("Body======> $body");
      //
      // return;
      var response = await SalesRepository().addSalesPersonAssign(body: body, salesId: widget.leadSalesPersonData?.id);

      if (response.success) {
        AppGlobals.showMessage(response.message, MessageType.success);
        isLoading = false;
        setState(() {});
        Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(false),
      ),
      body: SafeArea(
        child: Form(
          key: _formKeySalesPerson,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDimen.screenPadding),
            children: [
              if(widget.leadSalesPersonData == null)
              mainFields(),
              if(widget.leadSalesPersonData != null)
              const FieldSpace(),
              if(widget.leadSalesPersonData != null)
              buildLeadSalesItemCard(context, widget.leadSalesPersonData!),
              if(widget.leadSalesPersonData != null)
              const FieldSpace(),
              if(widget.leadSalesPersonData != null)
              TextFormField(
                controller: _txtLocationAddressController,
                decoration: InputDecoration(
                  labelText: AppString.locationAddress,
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                      onPressed: () async {
                        await LocationHelper.handleLocationPermission(context);
                        locationAddress = await _getCurrentLocation(context);
                      },
                      icon: const Icon(
                        Icons.add_location_alt_rounded,
                        color: AppColors.primary,
                      ),
                  ),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validator: (value) {
                  // bool isValid = Validations.validateInput(value, true);
                  // if (!isValid) {
                  //   return AppString;
                  // }
                  return null;
                },
              ),
              if(widget.leadSalesPersonData != null)
              const FieldSpace(),
              if(widget.leadSalesPersonData != null)
              TextFormField(
                controller: _txtNextDateController,
                decoration: const InputDecoration(
                  labelText: AppString.nextReminderDate,
                  prefixIcon: Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                  ),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                readOnly: true,
                onTap: () {
                  _selectReminderDate();
                },
                validator: (value) {
                  // bool isValid = Validations.validateInput(value, true);
                  // if (!isValid) {
                  //   return AppString.selectNextDate;
                  // }
                  return null;
                },
              ),
              if(widget.leadSalesPersonData != null)
              const FieldSpace(),
              if(widget.leadSalesPersonData != null)
              TextFormField(
                controller: _txtNextTimeController,
                decoration: const InputDecoration(
                  labelText: AppString.nextReminderTime,
                  prefixIcon: Icon(
                    Icons.watch_later_outlined,
                    color: AppColors.primary,
                  ),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                readOnly: true,
                onTap: () {
                  _selectReminderTime(context);
                },
                validator: (value) {
                  // bool isValid = Validations.validateInput(value, true);
                  // if (!isValid) {
                  //   return AppString.selectNextTime;
                  // }
                  return null;
                },
              ),
              if(widget.leadSalesPersonData != null)
              const FieldSpace(),
              if(widget.leadSalesPersonData != null)
              DropdownButtonFormField2<SalesPersonData>(
                value: _selectedSalesPerson,
                items: _dropdownSalesPerson,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedSalesPerson = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: AppString.leadAssign,
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
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
                  //   return AppString.selectSalesPerson;
                  // }
                  return null;
                },
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    _txtSearchSalesController.clear();
                  }
                },
                dropdownSearchData: DropdownSearchData(
                  searchController: _txtSearchSalesController,
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
                      controller: _txtSearchSalesController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.padding,
                          vertical: AppDimen.paddingSmall,
                        ),
                        hintText: AppString.searchForSales,
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn:
                      (DropdownMenuItem<SalesPersonData>? item, searchValue) {
                    return item!.value!.name!.toLowerCase().contains(searchValue);
                  },
                ),
              ),
              const FieldSpace(),
              TextFormField(
                controller: _txtCommentFirstController,
                decoration: const InputDecoration(
                  labelText: AppString.comment,
                  prefixIcon: Icon(
                    Icons.note_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  // bool isValid = Validations.validateInput(value, true, ValidationType.none);
                  // if (!isValid) {
                  //   return AppString.enterComment;
                  // }
                  return null;
                },
              ),
              // if(widget.leadSalesPersonData != null)
              // const FieldSpace(),
              // if(widget.leadSalesPersonData != null)
              // TextFormField(
              //   controller: _txtCommentSecondController,
              //   decoration: const InputDecoration(
              //     labelText: AppString.commentSecond,
              //     prefixIcon: Icon(
              //       Icons.note_alt_outlined,
              //       color: AppColors.primary,
              //     ),
              //   ),
              //   textInputAction: TextInputAction.next,
              //   keyboardType: TextInputType.text,
              //   validator: (value) {
              //     bool isValid = Validations.validateInput(value, true, ValidationType.none);
              //     if (!isValid) {
              //       return AppString.enterCommentSecond;
              //     }
              //     return null;
              //   },
              // ),
              const FieldSpace(),
              DropdownButtonFormField2<PriorityResponse>(
                value: _selectedPriority,
                items: _dropdownPriority,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: AppString.status,
                  prefixIcon: Icon(
                    Icons.checklist_rounded,
                    color: AppColors.primary,
                  ),
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
                  //   return AppString.selectPriority;
                  // }
                  return null;
                },
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    _txtSearchStatusController.clear();
                  }
                },
                dropdownSearchData: DropdownSearchData(
                  searchController: _txtSearchStatusController,
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
                      controller: _txtSearchStatusController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.padding,
                          vertical: AppDimen.paddingSmall,
                        ),
                        hintText: AppString.searchForStage,
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn:
                      (DropdownMenuItem<PriorityResponse>? item, searchValue) {
                    return item!.value!.priority!.toLowerCase().contains(searchValue);
                  },
                ),
              ),
              /*const FieldSpace(),
              DropdownButtonFormField2<PriorityResponse>(
                value: _selectedStatus,
                items: _dropdownStatus,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: AppString.status,
                  prefixIcon: Icon(
                    Icons.checklist_rounded,
                    color: AppColors.primary,
                  ),
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
                  //   return AppString.selectPriority;
                  // }
                  return null;
                },
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    _txtSearchStatusController.clear();
                  }
                },
                dropdownSearchData: DropdownSearchData(
                  searchController: _txtSearchStatusController,
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
                      controller: _txtSearchStatusController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.padding,
                          vertical: AppDimen.paddingSmall,
                        ),
                        hintText: AppString.searchForStatus,
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn:
                      (DropdownMenuItem<PriorityResponse>? item, searchValue) {
                    return item!.value!.priority!.toLowerCase().contains(searchValue);
                  },
                ),
              ),*/
              const FieldSpace(),
              Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: isLoading ? null : addSalesPerson,
                          text: AppString.submit,
                        ),
                      ),
                    ],
                  ),
                  if (isLoading) const ButtonLoader(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  mainFields(){
    return Column(
      children: [
        TextFormField(
          controller: _txtDateTimeController,
          decoration: const InputDecoration(
            labelText: AppString.dateTime,
            prefixIcon: Icon(
              Icons.calendar_month,
              color: AppColors.primary,
            ),
          ),
          textInputAction: TextInputAction.next,
          readOnly: true,
          onTap: () {
            _selectReminderDate();
          },
          validator: (value) {
            // bool isValid = Validations.validateInput(value, true);
            // if (!isValid) {
            //   return AppString.selectCurrentDateTime;
            // }
            return null;
          },
        ),
        const FieldSpace(),
        TextFormField(
          controller: _txtPhoneController,
          decoration: InputDecoration(
            labelText: AppString.phone,
            prefixIcon: const Icon(
              Icons.call_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              onPressed: () async {
                await FlutterContacts.requestPermission();
                  if (mounted) {
                    Contact? contact = await AppGlobals.navigateAndReturn(context, const GetAllContacts(), false);
                    if (contact != null) {
                      _txtPhoneController.text = AppGlobals.removeCountryCode(contact.phones.first.number);
                      _txtPartyController.text = contact.displayName;
                      setState(() {});
                    }
                  }
              },
              icon: const Icon(
                Icons.import_contacts_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            PhoneInputFormatter(),
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            // bool result = Validations.validateInput(value, true, ValidationType.none);
            // if (!result) {
            //   return AppString.enterPhoneNo;
            // } else {
            //   bool isValid = Validations.validateInput(value, true, ValidationType.phone);
            //   if (!isValid) {
            //     return AppString.enterValidPhoneNo;
            //   }
            // }
            return null;
          },
        ),
        const FieldSpace(),
        TextFormField(
          controller: _txtPartyController,
          decoration: const InputDecoration(
            labelText: AppString.partyName,
            prefixIcon: Icon(
              Icons.person_rounded,
              color: AppColors.primary,
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          validator: (value) {
            // bool isValid = Validations.validateInput(value, true, ValidationType.none);
            // if (!isValid) {
            //   return AppString.enterPartyName;
            // }
            return null;
          },
        ),
        const FieldSpace(),
        TextFormField(
          controller: _txtAddressController,
          decoration: const InputDecoration(
            labelText: AppString.address,
            prefixIcon: Icon(
              Icons.location_city,
              color: AppColors.primary,
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          validator: (value) {
            // bool isValid = Validations.validateInput(value, true, ValidationType.none);
            // if (!isValid) {
            //   return AppString.enterAddress;
            // }
            return null;
          },
        ),
        const FieldSpace(),
        DropdownButtonFormField2<CommonNameData>(
          value: _selectedAreaData,
          items: _dropdownAreaItems,
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedAreaData = value;
            });
          },
          decoration: const InputDecoration(
            labelText: AppString.area,
            prefixIcon: Icon(
              Icons.area_chart,
              color: AppColors.primary,
            ),
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
            //   return AppString.selectArea;
            // }
            return null;
          },
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              _txtSearchAreaController.clear();
            }
          },
          dropdownSearchData: DropdownSearchData(
            searchController: _txtSearchAreaController,
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
                controller: _txtSearchAreaController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimen.padding,
                    vertical: AppDimen.paddingSmall,
                  ),
                  hintText: AppString.searchForArea,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn:
                (DropdownMenuItem<CommonNameData>? item, searchValue) {
              return item!.value!.name.toLowerCase().contains(searchValue);
            },
          ),
        ),
        const FieldSpace(),
        TextFormField(
          controller: _txtLocationAddressController,
          decoration: InputDecoration(
            labelText: AppString.locationAddress,
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
                onPressed: () async {
                  await LocationHelper.handleLocationPermission(context);
                  locationAddress = await _getCurrentLocation(context);
                },
                icon: const Icon(
                  Icons.add_location_alt_rounded,
                  color: AppColors.primary,
                ),),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          validator: (value) {
            // bool isValid = Validations.validateInput(value, true, ValidationType.none);
            // if (!isValid) {
            //   return AppString.address;
            // }
            return null;
          },
        ),
        /*const FieldSpace(),
        DropdownButtonFormField2<ProductData>(
          value: _selectedProducts,
          items: _dropdownProducts,
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedProducts = value;
            });
          },
          decoration: const InputDecoration(
            labelText: AppString.product,
            prefixIcon: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
            ),
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
            //   return AppString.selectProductName;
            // }
            return null;
          },
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              _txtSearchProductController.clear();
            }
          },
          dropdownSearchData: DropdownSearchData(
            searchController: _txtSearchProductController,
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
                controller: _txtSearchProductController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimen.padding,
                    vertical: AppDimen.paddingSmall,
                  ),
                  hintText: AppString.searchForProduct,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn:
                (DropdownMenuItem<ProductData>? item, searchValue) {
              return item!.value!.name.toLowerCase().contains(searchValue);
            },
          ),
        ),*/
        const FieldSpace(),
        DropdownButtonFormField2<ProductData>(
          value: _selectedSalesProducts,
          items: _dropdownSalesProducts,
          isExpanded: true,
          onChanged: (value) async {
            int isEmb = 0;
            int isCir = 0;
            setState(() {
              _selectedSalesProducts = value;
              _selectedSalesPerson = null;
            });
            if(value!.name.toUpperCase() == "EMBROIDERY MACHINE"){
              isEmb = 1;
              isCir = 0;
            } else {
              isEmb = 0;
              isCir = 1;
            }
            await fetchSalesPerson(isEmb: isEmb, isCir: isCir);
          },
          decoration: const InputDecoration(
            labelText: AppString.product,
            prefixIcon: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
            ),
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
            //   return AppString.selectProductName;
            // }
            return null;
          },
        ),
        const FieldSpace(),
        DropdownButtonFormField2<SalesPersonData>(
          value: _selectedSalesPerson,
          items: _dropdownSalesPerson,
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedSalesPerson = value;
            });
          },
          decoration: const InputDecoration(
            labelText: AppString.leadAssign,
            prefixIcon: Icon(
              Icons.person,
              color: AppColors.primary,
            ),
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
            //   return AppString.selectSalesPerson;
            // }
            return null;
          },
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              _txtSearchSalesController.clear();
            }
          },
          dropdownSearchData: DropdownSearchData(
            searchController: _txtSearchSalesController,
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
                controller: _txtSearchSalesController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimen.padding,
                    vertical: AppDimen.paddingSmall,
                  ),
                  hintText: AppString.searchForSales,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn:
                (DropdownMenuItem<SalesPersonData>? item, searchValue) {
              return item!.value!.name!.toLowerCase().contains(searchValue);
            },
          ),
        ),
      ],
    );
  }

  GestureDetector buildLeadSalesItemCard(index, LeadSalesPersonData salesPersonData ) {
    return GestureDetector(
      onTap: () async {
        // AppGlobals.showMessage("Double click", MessageType.success);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
        ),
        elevation: 2,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimen.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Lead No",
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
                          "${salesPersonData.id!}",
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
                          "${salesPersonData.date!}  ${salesPersonData.time!}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.partyname != null)
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
                          salesPersonData.partyname!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.mobileNo != null)
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
                          salesPersonData.mobileNo!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.product != null && salesPersonData.product!.name!.isNotEmpty)
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
                          salesPersonData.product!.name!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.saleUserDetail != null && salesPersonData.saleUserDetail!.name!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Assigned By",
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
                          salesPersonData.saleUserDetail!.name!,
                          maxLines: 2,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.saleAssignUser != null && salesPersonData.saleAssignUser!.name!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "Assigned To",
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
                            salesPersonData.saleAssignUser!.name!,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.purple, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  if(salesPersonData.salesPersonTask!.isNotEmpty && (salesPersonData.salesPersonTask!.last.date != null && salesPersonData.salesPersonTask!.last.time != null))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Remainder Date/Time",
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
                          "${salesPersonData.salesPersonTask!.last.date!} ${salesPersonData.salesPersonTask!.last.time!}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.salesPersonTask!.isNotEmpty && salesPersonData.salesPersonTask!.last.commentFirst != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Comment",
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
                          salesPersonData.salesPersonTask!.last.commentFirst!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     const Expanded(
                  //       child: Text(
                  //         "Comment 2",
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //           fontSize: 13,
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                  //       child: Text(
                  //         ":",
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       flex: 2,
                  //       child: Text(
                  //         salesPersonData.salesPersonTask!.first.commentSecond!,
                  //         maxLines: 2,
                  //         style: const TextStyle(
                  //           color: Colors.black,
                  //           fontSize: 13,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  if(salesPersonData.salesPersonTask!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Status",
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
                          salesPersonData.salesPersonTask!.last.priorityResponse == null ? "" : salesPersonData.salesPersonTask!.last.priorityResponse!.priority!,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            /* Positioned(
              right: 0.0,
              top: 0.0,
              child: showOptions(listIndex: index, context: context),
            ),*/
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<CommonNameData>> buildDropdownCommonItems(
      List<CommonNameData> complainTypesList) {
    List<DropdownMenuItem<CommonNameData>> items = [];
    for (CommonNameData item in complainTypesList as Iterable<CommonNameData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<PriorityResponse>> buildDropdownPriorityItems(List<PriorityResponse> priorityList) {
    List<DropdownMenuItem<PriorityResponse>> items = [];
    for (PriorityResponse item in priorityList as Iterable<PriorityResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.priority!.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<ProductData>> buildDropdownProductItems(
      List<ProductData> productList) {
    List<DropdownMenuItem<ProductData>> items = [];
    for (ProductData item in productList as Iterable<ProductData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<SalesPersonData>> buildDropdownSalesPersonItems(
      List<SalesPersonData> salesPersonList) {
    List<DropdownMenuItem<SalesPersonData>> items = [];
    for (SalesPersonData item in salesPersonList as Iterable<SalesPersonData>) {
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
