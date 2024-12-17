import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omsatya/models/complain_types_response.dart';
import 'package:omsatya/models/customer_machine_response.dart';
import 'package:omsatya/models/get_complain_no_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/screen/audio_recorder.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:video_compress/video_compress.dart';

class CustomerAddComplain extends StatefulWidget {
  final MachineData? machineData;

  const CustomerAddComplain({super.key, this.machineData});

  @override
  State<CustomerAddComplain> createState() => _CustomerAddComplainState();
}

class _CustomerAddComplainState extends State<CustomerAddComplain> {
  final GlobalKey<FormState> _formKeyAddComplain = GlobalKey<FormState>();

  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _txtMachineNoController = TextEditingController();
  final TextEditingController _complainTypeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  List<ComplainTypesData> complainTypesList = [];
  List<DropdownMenuItem<ComplainTypesData>>? _dropdownComplainTypesItems;

  ComplainTypesData? _selectedComplainTypes;
  GetComplainNoResponse? complainNoResponse;

  int defaultComplainStatusKey = 1;
  String date = "";
  String time = "";

  bool isLoading = false;
  bool isStatus = true;

  String avatar = "";
  String videoAvtar = "";
  String recordingPath = "";

  File? imageFile;
  File? videoFile;
  File? audioFile;

  final _progressNotifier = ValueNotifier<double>(0.0);
  double _progress = 0.0;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _productNameController.dispose();
    _complainTypeController.dispose();
    _txtMachineNoController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(false),
      ),
      body: SafeArea(
        child:
            SingleChildScrollView(padding: const EdgeInsets.all(AppDimen.padding), child: _buildComplainForm(context)),
      ),
    );
  }

  Form _buildComplainForm(BuildContext context) {
    return Form(
      key: _formKeyAddComplain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _dateTimeController,
            decoration: const InputDecoration(
              labelText: AppString.dateTime,
              // prefixIcon: Icon(
              //   Icons.date_range_rounded,
              //   color: AppColors.primary,
              // ),
            ),
            textInputAction: TextInputAction.next,
            readOnly: true,
            validator: (value) {
              bool isValid;

              isValid = Validations.validateInput(value, true);

              if (isValid == false) {
                return "Please select date";
              }
              return null;
            },
          ),
          const FieldSpace(),
          TextFormField(
            controller: _productNameController,
            decoration: const InputDecoration(
              labelText: AppString.productName,
              // prefixIcon: Icon(
              //   Icons.inventory_2_rounded,
              //   color: AppColors.primary,
              // ),
            ),
            textInputAction: TextInputAction.next,
            readOnly: true,
            maxLines: 2,
            validator: (value) {
              bool isValid;

              isValid = Validations.validateInput(value, true);

              if (isValid == false) {
                return "Please select date";
              }
              return null;
            },
          ),
          const FieldSpace(),
          TextFormField(
            controller: _txtMachineNoController,
            decoration: const InputDecoration(
              labelText: AppString.machineSrNo,
              // prefixIcon: Icon(
              //   Icons.inventory_2_rounded,
              //   color: AppColors.primary,
              // ),
            ),
            textInputAction: TextInputAction.next,
            readOnly: true,
            maxLines: 1,
            validator: (value) {
              bool isValid;

              isValid = Validations.validateInput(value, true);

              if (isValid == false) {
                return "Please select date";
              }
              return null;
            },
          ),
          const FieldSpace(),
          DropdownButtonFormField2(
            value: _selectedComplainTypes,
            items: _dropdownComplainTypesItems,
            decoration: const InputDecoration(
              labelText: AppString.complainType,
              // prefixIcon: Icon(
              //   Icons.warning_amber_rounded,
              //   color: AppColors.primary,
              // ),
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
            isExpanded: true,
            dropdownStyleData: DropdownStyleData(
              maxHeight: MediaQuery.of(context).size.height / 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                color: Colors.white,
              ),
            ),
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
                    hintStyle: const TextStyle(fontSize: 14,),
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
          const FieldSpace(SpaceType.extraLarge),
          Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isLoading ? null : () => onSubmit(context),
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
    );
  }

  init() async {
    date = AppGlobals().getCurrentDate();
    time = AppGlobals().getCurrentTime();
    await fetchComplainNoData();
    await fetchComplainStatusData();

    _dropdownComplainTypesItems = buildDropdownComplainTypesItems(complainTypesList);

    _dateTimeController.text = "$date  $time";
    _productNameController.text = widget.machineData!.product!.name!;
    _txtMachineNoController.text = "${widget.machineData!.serialNo} / ${widget.machineData!.mcNo}";

    // AppGlobals.requestCameraPermission(context);
  }

  void onSubmit(BuildContext context) async {
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
        partyId: widget.machineData!.partyId!.toString(),
        statusId: "1",
        complainNo: complainNoResponse!.data.toString(),
        complainTypeId: _selectedComplainTypes!.id.toString(),
        productId: widget.machineData!.product!.id.toString(),
        salesEntryId: widget.machineData!.id.toString(),
        serviceTypeId: widget.machineData!.serviceType!.id!.toString(),
        remarks: _remarksController.text.trim(),
        image: imageFile,
        video: videoFile,
        audio: recordingPath.isEmpty ? null : File(recordingPath),
      );

      if(!response.success){
        isLoading = false;
        AppGlobals.showMessage(response.message, MessageType.error);
        setState(() {});
        return;
      }

      if (response.success) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage(response.message, MessageType.success);
        await VideoCompress.deleteAllCache();
        isLoading = false;
        if (mounted) {
          Navigator.of(context).pop(true);
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
    } finally {
    }
  }

  fetchComplainStatusData() async {
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

  List<DropdownMenuItem<ComplainTypesData>> buildDropdownComplainTypesItems(List<ComplainTypesData> complainTypesList) {
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
