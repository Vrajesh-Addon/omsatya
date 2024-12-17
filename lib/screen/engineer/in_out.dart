import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/location_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/complain_types_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/engineer_repository.dart';
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
import 'package:video_compress/video_compress.dart';

class InOutScreen extends StatefulWidget {
  final ComplainData? complainData;

  const InOutScreen({super.key, this.complainData});

  @override
  State<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends State<InOutScreen> {
  final GlobalKey<FormState> _formKeyIn = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyOut = GlobalKey<FormState>();
  FocusNode? _focusNode;

  final TextEditingController _complainTypeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  final FocusNode _complainTypeFocusNode = FocusNode();
  final FocusNode _remarksFocusNode = FocusNode();

  final _progressNotifier = ValueNotifier<double>(0.0);

  List<ComplainStatusData> complainStatusList = [];
  List<ComplainTypesData> complainTypesList = [];

  List<DropdownMenuItem<ComplainStatusData>>? _dropdownComplainStatusItems;
  List<DropdownMenuItem<ComplainTypesData>>? _dropdownComplainTypesItems;

  ComplainStatusData? _selectedComplainStatus;
  ComplainTypesData? _selectedComplainTypes;

  int defaultComplainStatusKey = 2;

  String _inDateTime = '';
  String _inAddress = '';
  String _outDateTime = '';
  String _outAddress = '';
  String? inDate;
  String? inTime;
  String? outDate;
  String? outTime;
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
    _complainTypeController.dispose();
    super.dispose();
  }

  init() async {
    await fetchComplainTypeData();
    _dropdownComplainTypesItems = buildDropdownComplainTypesItems(complainTypesList);

   if(widget.complainData != null){
     statusId = widget.complainData!.statusId!;
     _inAddress = widget.complainData!.engineerInAddress ?? "";
     inDate = widget.complainData!.engineerInDate;
     inTime = widget.complainData!.engineerInTime;
     _inDateTime = "${widget.complainData!.engineerInDate}  ${widget.complainData!.engineerInTime}";

     _outAddress = widget.complainData!.engineerOutAddress ?? "";
     outDate = widget.complainData!.engineerOutDate;
     outTime = widget.complainData!.engineerOutTime;
     _outDateTime = "${widget.complainData!.engineerOutDate}  ${widget.complainData!.engineerOutTime}";

     for (int x = 0; x < _dropdownComplainTypesItems!.length; x++) {
       if (_dropdownComplainTypesItems![x].value!.id == widget.complainData!.complaintType!.id) {
         _selectedComplainTypes = _dropdownComplainTypesItems![x].value;
       }
     }

     if(widget.complainData!.engineerVideoUrl != null && widget.complainData!.engineerVideoUrl!.isNotEmpty){
       videoFile = await AppGlobals.generateThumbnail(widget.complainData!.engineerVideoUrl!);
       setState(() {});
     }
   }

   if(inDate != null && inTime != null) {
     await fetchComplainStatusData();
     _dropdownComplainStatusItems = buildDropdownComplainStatusItems(complainStatusList);

     for (int x = 0; x < _dropdownComplainStatusItems!.length; x++) {
       if (_dropdownComplainStatusItems![x].value!.id == defaultComplainStatusKey) {
         _selectedComplainStatus = _dropdownComplainStatusItems![x].value;
       }
     }
   }
  }

  fetchComplainStatusData() async {
    try {
      var response = await ComplainRepository().getComplainStatusResponse();

      if (response.success!) {
        complainStatusList = response.data!;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
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
        // isStatus = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      // setState(() {
      //   isStatus = false;
      // });
    } finally {
      // setState(() {
      //   isStatus = false;
      // });
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
    String date = AppGlobals().getCurrentDate();
    String time = AppGlobals().getCurrentTime();

    address = await _getCurrentLocation(context);

    setState(() {
      isIn = false;
      _inDateTime = "$date  $time";
      _inAddress = address!;
    });
  }

  void _recordInSubmit(BuildContext context) async {
    bool result = await LocationHelper.handleLocationPermission(context);
    if(!result) return;
    String date = AppGlobals().getCurrentDate();
    String time = AppGlobals().getCurrentTime();

    try {
      setState(() {
        isInLoading = true;
      });

      String? address = await _getCurrentLocation(context);
      var response = await EngineerRepository().getEngineerInResponse(
        complainId: widget.complainData!.id,
        inDate: date,
        inTime: time,
        statusId: 2,
        address: address,
        actualComplainTypeId: _selectedComplainTypes!.id,
        image: imageFile,
        video: videoFile,
        audio: recordingPath.isEmpty ? null : File(recordingPath),
      );

      if (response.success) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage("Engineer In Successfully", MessageType.success);
        statusId = 2;
        isInLoading = false;
        inDate = response.data.engineerInDate;
        inTime = response.data.engineerInTime;
        _inDateTime = "${response.data.engineerInDate}  ${response.data.engineerInTime}";
        _inAddress = response.data.engineerInAddress!;
        Navigator.of(context).pop(true);
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

      // DateTime now = DateTime.now();
      DateTime inTime = DateFormat('HH:mm:ss').parse(widget.complainData!.engineerInTime!);
      DateTime outsTime = DateFormat('HH:mm:ss').parse(time);

      // inTime = DateTime(now.year, now.month, now.day, inTime.hour, inTime.minute, inTime.second);
      // outsTime = DateTime(now.year, now.month, now.day, outsTime.hour, outsTime.minute, outsTime.second);
      //
      // if (inTime.isAfter(outsTime)) {
      //   inTime = inTime.subtract(const Duration(days: 1));
      // }

      // Calculating the difference (Duration)
      Duration difference = outsTime.difference(inTime);

      // Extract hours, minutes, and seconds from the duration
      String hours = difference.inHours.toString().padLeft(2, '0');
      String minutes = difference.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds = difference.inSeconds.remainder(60).toString().padLeft(2, '0');

      String timeDuration = "$hours:$minutes:$seconds";

      var response = await EngineerRepository().getEngineerOutResponse(
          complainId: widget.complainData!.id,
          statusId: _selectedComplainStatus!.id,
          outDate: date,
          outTime: time,
          remarks: _remarksController.text.trim(),
          address: _outAddress,
          timeDuration: timeDuration,
      );

      if(!response.success){
        isOutLoading = false;
        setState(() {});
        return;
      }

      if (response.success) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage("Engineer Out Successfully", MessageType.success);
        _remarksController.clear();
        isOutLoading = false;
        outDate = response.data.engineerOutDate;
        outTime = response.data.engineerOutTime;
        _outDateTime = "${response.data.engineerOutDate}  ${response.data.engineerOutTime}";
        _outAddress = response.data.engineerOutAddress!;
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
      setState(() {
        isOutLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(inDate != null && inTime != null){
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
            if(inDate != null && inTime != null){
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
                                  onPressed: isIn ? null : _recordIn,
                                  text: AppString.ins,
                                ),
                              ),
                      ],
                    ),
                    if (isIn) const ButtonLoader(),
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
                        (inDate == null && inTime == null) || (_outDateTime.isNotEmpty && _outAddress.isNotEmpty)
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
          const FieldSpace(),
          DropdownButtonFormField2<ComplainTypesData>(
            value: _selectedComplainTypes,
            items: _dropdownComplainTypesItems,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: AppString.actualComplainType,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                color: Colors.white,
              ),
            ),
            onChanged: (inDate != null && inTime != null) ? null : (value) {
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
          if(inDate == null && inTime == null)
          const FieldSpace(),
          if(inDate == null && inTime == null)
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()
            ),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppString.image,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const FieldSpace(SpaceType.extraSmall),
                    ImageFormField(
                      widgetShape: WidgetShape.rounded,
                      onChanged: (file) => handleOnImageChanged(file),
                      imageUrl: avatar,
                    ),
                  ],
                ),
                const FieldSpace(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppString.video,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const FieldSpace(SpaceType.extraSmall),
                    VideoFormField(
                      widgetShape: WidgetShape.rounded,
                      onChanged: (file) => handleOnVideoChanged(file),
                      // onChanged: (file) => handleOnImageChanged(file),
                    ),
                  ],
                ),
                const FieldSpace(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppString.audio,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const FieldSpace(SpaceType.extraSmall),
                    Stack(
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: WidgetMethods.getBorderRadius(WidgetShape.rounded, 100, 100),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: InkWell(
                            onTap: () async {
                              String? recordingFile =
                              await AppGlobals.navigateAndReturn(context, const AudioRecorderScreen(), false);
                              if (recordingFile != null) {
                                setState(() {
                                  recordingPath = recordingFile;
                                });
                              }
                              showMessage("recordingPath ==> $recordingPath");
                            },
                            borderRadius: WidgetMethods.getBorderRadius(WidgetShape.rounded, 100, 100),
                            // child: Container(),
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                // color: recordingPath.isEmpty ? Colors.white : AppColors.primary.withOpacity(0.2),
                                borderRadius: WidgetMethods.getBorderRadius(WidgetShape.rounded, 100, 100),
                              ),
                              child: (recordingPath.isEmpty)
                                  ? const Icon(Icons.mic_rounded)
                                  : const Icon(Icons.audiotrack_rounded),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2.0,
                          bottom: 2.0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                color: AppColors.primary,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(color: Colors.white, size: 20, (recordingPath.isEmpty) ? Icons.add : Icons.edit),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            // color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(widget.complainData!.engineerImageUrl != null && widget.complainData!.engineerImageUrl!.isNotEmpty)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppGlobals.navigate(
                        context,
                        ViewMedia(
                          imageUrl: widget.complainData!.engineerImageUrl,
                        ),
                        false,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppString.image,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height / 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: widget.complainData!.engineerImageUrl!,
                              progressIndicatorBuilder: (context, string, progress) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorWidget: (context, url, error) => Image.asset(
                                AppImages.placeholder,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if(widget.complainData!.engineerImageUrl != null && widget.complainData!.engineerImageUrl!.isNotEmpty)
                  const FieldSpace(SpaceType.medium),
                if(widget.complainData!.engineerVideoUrl != null && widget.complainData!.engineerVideoUrl!.isNotEmpty)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppGlobals.navigate(
                        context,
                        ViewMedia(
                          videoUrl: widget.complainData!.engineerVideoUrl,
                        ),
                        false,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppString.video,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height / 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            ),
                            child: videoFile == null ? const Center(child: CircularProgressIndicator(),) : Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(videoFile!),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(width: 1, color: Colors.white),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white,),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if(widget.complainData!.engineerVideoUrl != null && widget.complainData!.engineerVideoUrl!.isNotEmpty)
                  const FieldSpace(SpaceType.medium),
                if(widget.complainData!.engineerAudioUrl != null && widget.complainData!.engineerAudioUrl!.isNotEmpty)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppGlobals.navigate(
                        context,
                        ViewMedia(
                          audioUrl: widget.complainData!.engineerAudioUrl,
                        ),
                        false,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppString.audio,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height / 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            ),
                            child: const Icon(Icons.audiotrack_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const FieldSpace(SpaceType.medium),
          if(inDate == null && inTime == null)
          Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isInLoading ? null : () => _recordInSubmit(context),
                      text: AppString.submit,
                    ),
                  ),
                ],
              ),
              if (isInLoading)
                const ButtonLoader(),
            ],
          ),
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
          /*const FieldSpace(SpaceType.medium),
          TextFormField(
            controller: _complainTypeController,
            focusNode: _complainTypeFocusNode,
            decoration: const InputDecoration(
              labelText: "Actual Complain",
            ),
            textInputAction: TextInputAction.next,
            // validator: (value) {
            //   bool isValid;
            //
            //   isValid = Validations.validateInput(value, true);
            //
            //   if (isValid == false) {
            //     if (_focusNode == null) {
            //       _focusNode = _complainTypeFocusNode;
            //       FocusScope.of(context).requestFocus(_focusNode);
            //     }
            //     return "Enter First Name.";
            //   }
            //   return null;
            // },
          ),*/
          const FieldSpace(SpaceType.medium),
          DropdownButtonFormField(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            isDense: true,
            decoration: const InputDecoration(
              labelText: "Complain Status",
            ),
            value: _selectedComplainStatus,
            items: _dropdownComplainStatusItems,
            onChanged: (ComplainStatusData? selectedFilter) {
              setState(() {
                _selectedComplainStatus = selectedFilter;
              });
            },
            // validator: (String? value) {
            //   bool isValid = Validations.validateInput(value, true);
            //   if (isValid == false) {
            //     return "Select Return Reason.";
            //   }
            //   return null;
            // },
          ),
          const FieldSpace(SpaceType.medium),
          TextFormField(
            controller: _remarksController,
            focusNode: _remarksFocusNode,
            decoration: const InputDecoration(
              labelText: "Remarks",
            ),
            textInputAction: TextInputAction.done,
            validator: (value) {
              bool isValid = Validations.validateInput(value, true);
              if (isValid == false) {
                if (_focusNode == null) {
                  _focusNode = _remarksFocusNode;
                  FocusScope.of(context).requestFocus(_focusNode);
                }
                return AppString.enterRemarks;
              }
              return null;
            },
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

  List<DropdownMenuItem<ComplainStatusData>> buildDropdownComplainStatusItems(List<ComplainStatusData> complainStatusList) {
    List<DropdownMenuItem<ComplainStatusData>> items = [];
    for (ComplainStatusData item in complainStatusList as Iterable<ComplainStatusData>) {
      if(item.name!.toLowerCase() != "pending") {
        items.add(
          DropdownMenuItem(
            value: item,
            child: Text(
              item.name!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    }
    return items;
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
