import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/location_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/complain_types_response.dart';
import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';
import 'package:omsatya/models/sales_person/sales_person_task.dart';
import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/engineer_repository.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/repository/todo_repository.dart';
import 'package:omsatya/screen/audio_recorder.dart';
import 'package:omsatya/screen/view_media.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';

class SalesInOutScreen extends StatefulWidget {
  final LeadSalesPersonData? leadSalesPersonData;

  const SalesInOutScreen({super.key, this.leadSalesPersonData});

  @override
  State<SalesInOutScreen> createState() => _SalesInOutScreenState();
}

class _SalesInOutScreenState extends State<SalesInOutScreen> {
  final GlobalKey<FormState> _formKeyIn = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyOut = GlobalKey<FormState>();
  FocusNode? _focusNode;

  final TextEditingController _txtCommentFirstController = TextEditingController();
  final TextEditingController _txtSearchStatusController = TextEditingController();

  final FocusNode _complainTypeFocusNode = FocusNode();
  final FocusNode _remarksFocusNode = FocusNode();

  final _progressNotifier = ValueNotifier<double>(0.0);

  List<ComplainStatusData> complainStatusList = [];
  List<ComplainTypesData> complainTypesList = [];
  List<PriorityResponse> priorityList = [];

  List<DropdownMenuItem<ComplainStatusData>>? _dropdownComplainStatusItems;
  List<DropdownMenuItem<ComplainTypesData>>? _dropdownComplainTypesItems;
  List<DropdownMenuItem<PriorityResponse>>? _dropdownPriority;

  PriorityResponse? _selectedPriority;
  ComplainStatusData? _selectedComplainStatus;
  ComplainTypesData? _selectedComplainTypes;

  int defaultComplainStatusKey = 2;

  String _inDateTime = '';
  String _inAddress = '';
  String _outDateTime = '';
  String _outAddress = '';
  String? inDateTime;
  String? outDateTime;

  int statusId = 0;

  String avatar = "";
  String videoAvtar = "";
  String recordingPath = "";

  File? imageFile;
  File? videoFile;
  File? audioFile;

  bool isInLoading = false;
  bool isOutLoading = false;
  bool isOut = false;
  bool isIn = false;

  @override
  void initState() {
    init();
    super.initState();
  }


  @override
  void dispose() {
    _txtCommentFirstController.dispose();
    _txtSearchStatusController.dispose();
    super.dispose();
  }

  init() async {


   if(widget.leadSalesPersonData != null){
     statusId = widget.leadSalesPersonData!.statusId ?? 0;
     _inAddress = widget.leadSalesPersonData!.inAddress ?? "";
     inDateTime = widget.leadSalesPersonData!.inDateTime;
     _inDateTime = widget.leadSalesPersonData!.inDateTime ?? "";

     _outAddress = widget.leadSalesPersonData!.outAddress ?? "";
     outDateTime = widget.leadSalesPersonData!.outDateTime;
     _outDateTime = widget.leadSalesPersonData!.outDateTime ?? "";

     // for (int x = 0; x < _dropdownComplainTypesItems!.length; x++) {
     //   if (_dropdownComplainTypesItems![x].value!.id == widget.leadSalesPersonData!.complaintType!.id) {
     //     _selectedComplainTypes = _dropdownComplainTypesItems![x].value;
     //   }
     // }
     //
     // if(widget.leadSalesPersonData!.engineerVideoUrl != null && widget.leadSalesPersonData!.engineerVideoUrl!.isNotEmpty){
     //   videoFile = await AppGlobals.generateThumbnail(widget.leadSalesPersonData!.engineerVideoUrl!);
     //   setState(() {});
     // }
   }

   if(inDateTime != null) {
     await fetchPriority();
     _dropdownPriority = buildDropdownPriorityItems(priorityList);

     for (int x = 0; x < _dropdownPriority!.length; x++) {
       if (_dropdownPriority![x].value!.id == widget.leadSalesPersonData!.salesPersonTask!.last.priorityId) {
         _selectedPriority = _dropdownPriority![x].value;
       }
     }
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

  Future<String?> _getCurrentLocation(BuildContext context) async {
    Position? currentPosition = await LocationHelper.getCurrentPosition(context);
    String? currentAddress;
    if(currentPosition != null) {
      currentAddress = await LocationHelper.getAddressFromLatLng(currentPosition!);
    } else {
      AppGlobals.showMessage("Please allow location permission", MessageType.error);
    }
    setState(() {});
    return currentAddress;
  }

  void _recordIn() async {
    bool result = await LocationHelper.handleLocationPermission(context);
    if(!result) return;

    setState(() {
      isIn = true;
    });

    String? address = "";
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = formatter.format(now);
    DateTime dateTime = DateTime.parse(formattedDate);

    address = await _getCurrentLocation(context);


    setState(() {
      isIn = false;
      _inDateTime = formattedDate;
      _inAddress = address!;
    });
  }

   _recordInSubmit() async {
    bool result = await LocationHelper.handleLocationPermission(context);
    if(!result) return;
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = formatter.format(now);

    try {
      setState(() {
        isInLoading = true;
      });

      String? address = await _getCurrentLocation(context);
      var response = await SalesRepository().getSalesInResponse(
        id: widget.leadSalesPersonData!.id,
        inDateTime: formattedDate,
        inAddress: address
      );

      if (response.status!) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage("Sales In Successfully", MessageType.success);
        isInLoading = false;
        inDateTime = response.data!.inDateTime!;
        _inDateTime = response.data!.inDateTime!;
        _inAddress = response.data!.inAddress!;
        Navigator.of(context).pop(true);
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isInLoading = false;
      });
    } finally {

    }
  }

  void _recordOut() async {
    bool result = await LocationHelper.handleLocationPermission(context);
    if(!result) return;

    setState(() {
      isOut = true;
    });

    String? address = "";
    String date = AppGlobals().getCurrentDate();
    String time = AppGlobals().getCurrentTime();

    address = await _getCurrentLocation(context);

    setState(() {
      isOut = false;
      _outDateTime = "$date $time";
      _outAddress = address!;
    });
  }

  _recordOutSubmit(BuildContext context) async {
    String date = AppGlobals().getCurrentDate();
    String time = AppGlobals().getCurrentTime();

    try {
      _focusNode = null;
      if (!_formKeyOut.currentState!.validate()) {
        return;
      }

      setState(() {
        isOutLoading = true;
      });

      final now = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final formattedDate = formatter.format(now);

      // DateTime now = DateTime.now();
      showMessage("inTime ==> ${widget.leadSalesPersonData!.inDateTime!}");
      DateTime inTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.leadSalesPersonData!.inDateTime!);
      DateTime outsTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDate);

      // Calculating the difference (Duration)
      Duration difference = outsTime.difference(inTime);

      // Extract hours, minutes, and seconds from the duration
      String hours = difference.inHours.toString().padLeft(2, '0');
      String minutes = difference.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds = difference.inSeconds.remainder(60).toString().padLeft(2, '0');

      String timeDuration = "$hours:$minutes:$seconds";

      showMessage("TimeDuration ==> $timeDuration");

      var body = {
          "id": widget.leadSalesPersonData!.id.toString(),
          "out_date_time": formattedDate,
          "out_address": _outAddress,
          "time_duration": timeDuration,
          "status_id": _selectedPriority!.id.toString(),
      };

      widget.leadSalesPersonData!.salesPersonTask!.add(SalesPersonTask(
        date: widget.leadSalesPersonData!.salesPersonTask!.last.date,
        time:  widget.leadSalesPersonData!.salesPersonTask!.last.time,
        // assignUserId: _selectedSalesPerson!.id,
        commentFirst: _txtCommentFirstController.text,
        commentSecond: "-",
        priorityId: _selectedPriority!.id,
      ));

      for (var i = 0; i < widget.leadSalesPersonData!.salesPersonTask!.length; i++) {
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

      var response = await SalesRepository().getSalesOutResponse(
          body: body
      );

      if(!response.status!){
        isOutLoading = false;
        setState(() {});
        return;
      }

      if (response.status!) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage("Sales Out Successfully", MessageType.success);
        _txtCommentFirstController.clear();
        isOutLoading = false;
        outDateTime = response.data!.outDateTime!;
        _outDateTime = response.data!.outDateTime!;
        _outAddress = response.data!.outAddress!;
        if (mounted) {
          Navigator.of(context).pop(true);
        }
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isOutLoading = false;
      });
    } finally {
      // setState(() {
      //   isOutLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(inDateTime != null){
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop(false);
        }
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          isShowBackButton: true,
          onBackPressed: () {
            if(inDateTime != null){
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).pop(false);
            }
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimen.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Row(
                      children: [
                        // (inDate != null && inTime != null)
                        (_inDateTime.isNotEmpty && _inAddress.isNotEmpty)
                            ? Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0.0),
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
                                ),
                              )
                            : Expanded(
                                child: PrimaryButton(
                                  onPressed: isInLoading ? null : _recordInSubmit,
                                  text: AppString.ins,
                                ),
                              ),
                      ],
                    ),
                    if (isInLoading) const ButtonLoader(),
                  ],
                ),
                const FieldSpace(SpaceType.medium),
                Visibility(
                  // visible: (inDate != null && inTime != null),
                  visible: (_inDateTime.isNotEmpty && _inAddress.isNotEmpty),
                  child: buildInForm(context),
                ),
                const FieldSpace(SpaceType.medium),
                Stack(
                  children: [
                    Row(
                      children: [
                        (inDateTime == null) || (_outDateTime.isNotEmpty && _outAddress.isNotEmpty)
                            ? Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18, horizontal: 0.0),
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
                                ),
                              )
                            : Expanded(
                                child: PrimaryButton(
                                  onPressed: isOut ? null : _recordOut,
                                  text: AppString.out,
                                ),
                              ),
                      ],
                    ),
                    if (isOut) const ButtonLoader(),
                  ],
                ),
                Visibility(
                  visible: _outDateTime.isNotEmpty && _outAddress.isNotEmpty,
                  child: buildOutForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildInForm(BuildContext context){
    return Form(
      key: _formKeyIn,
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
          // const FieldSpace(SpaceType.medium),
          // if(inDateTime == null)
          // Stack(
          //   children: [
          //     Row(
          //       children: [
          //         Expanded(
          //           child: PrimaryButton(
          //             onPressed: isInLoading ? null : () => _recordInSubmit(),
          //             text: AppString.submit,
          //           ),
          //         ),
          //       ],
          //     ),
          //     if (isInLoading)
          //       const ButtonLoader(),
          //   ],
          // ),
        ],
      ),
    );
  }

  buildOutForm(BuildContext context) {
    return Form(
      key: _formKeyOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldSpace(SpaceType.medium),
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
          const FieldSpace(SpaceType.medium),
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
          const FieldSpace(SpaceType.medium),
          Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isOutLoading ? null : () => _recordOutSubmit(context),
                      text: AppString.submit,
                    ),
                  ),
                ],
              ),
              if (isOutLoading)
                const ButtonLoader(),
            ],
          ),
        ],
      ),
    );
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

  void handleOnImageChanged(file) async {
    if (file == null) {
      avatar = "";
    } else {

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.absolute.parent.path}/compressed_${file.path.split('/').last}',
        quality: 85,
        // rotate: 180,
      );

      File filePath = File(result!.path);
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

      String? compressPath = await _compressVideo(file);

      if(compressPath!.isNotEmpty) {
        File filePath = File(compressPath!);
        Uint8List imageBytes = await filePath.readAsBytes();
        String base64string = base64.encode(imageBytes);
        videoFile = filePath;
        avatar = base64string;
      }
    }
    setState(() {});
  }

  Future<String?> _compressVideo(file) async {
    if (file == null) {
      return "";
    }
    await VideoCompress.setLogLevel(0);

    // Display the progress dialog
    if (mounted) {
      _showProgressDialog(context);
    }

    // Start video compression and track the progress
    final subscription = VideoCompress.compressProgress$.subscribe((progress) {
      _progressNotifier.value = progress;
    });

    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    subscription.unsubscribe(); // Stop listening to progress

    // Close the progress dialog when compression is complete
    if(mounted) {
      await Future.delayed(Duration.zero, () {
        _progressNotifier.value = 0.0;
        Navigator.of(context).pop();
      });
    }

    showMessage("info!.path ==> ${info!.path}");

    return info.path;
  }

  Future<void> _showProgressDialog(BuildContext context) async {
    await Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevents closing the dialog
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Compressing Video'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please wait...'),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<double>(
                      valueListenable: _progressNotifier,
                      builder: (context, progress, child) {
                        return Column(
                          children: [
                            CircularProgressIndicator(
                              value: progress / 100,
                            ),
                            const SizedBox(height: 10),
                            Text('${_progressNotifier.value.toStringAsFixed(0)}%'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });

  }
}
