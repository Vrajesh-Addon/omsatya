import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/screen/complain_detail_pdf.dart';
import 'package:omsatya/screen/view_media.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class ComplainDetailsScreen extends StatefulWidget {
  final ComplainData? complainData;

  const ComplainDetailsScreen({super.key, this.complainData});

  @override
  State<ComplainDetailsScreen> createState() => _ComplainDetailsScreenState();
}

class _ComplainDetailsScreenState extends State<ComplainDetailsScreen> {
  File? videoFile;
  File? engVideoFile;

  @override
  void initState() {
    init();
    super.initState();
  }
  
  init() async {
    if(widget.complainData != null && widget.complainData!.videoUrl!.isNotEmpty){
      videoFile = await AppGlobals.generateThumbnail(widget.complainData!.videoUrl!);
    }

    if(widget.complainData != null && widget.complainData!.engineerVideoUrl!.isNotEmpty){
      engVideoFile = await AppGlobals.generateThumbnail(widget.complainData!.engineerVideoUrl!);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      floatingActionButton:FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: (){
          AppGlobals.navigate(context, ComplainDetailPDF(complainData: widget.complainData), false);
        },
        label: const Text('View PDF'),
        icon: const Icon(Icons.print, color: Colors.white, size: 25),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimen.paddingSmall, bottom: AppDimen.paddingSmall),
                      child: Text(
                        AppGlobals().getStatus(widget.complainData!.statusId),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: AppGlobals().getStatus(widget.complainData!.statusId).toLowerCase() == "pending"
                                  ? Colors.red
                                  : AppGlobals().getStatus(widget.complainData!.statusId).toLowerCase() == "in progress"
                                      ? Colors.purple
                                      : AppColors.success,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const FieldSpace(SpaceType.small),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimen.padding,
                  vertical: AppDimen.paddingSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.partyName,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const FieldSpace(SpaceType.small),
                    Text(
                      widget.complainData!.party!.name!.toCapitalize(),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              const FieldSpace(SpaceType.small),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.complainNo,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const FieldSpace(SpaceType.extraSmall),
                            Text(
                              widget.complainData!.complaintNo!,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.machineNo,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const FieldSpace(SpaceType.extraSmall),
                            Text(
                              "${widget.complainData!.salesEntry!.serialNo!} / ${widget.complainData!.salesEntry!.mcNo!}",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const FieldSpace(SpaceType.small),
                    Row(
                      children: [
                        Text(
                          "${AppString.dateTime}: ",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const FieldSpace(SpaceType.small),
                        Expanded(
                          child: Text(
                            "${AppGlobals.changeDateFormat(widget.complainData!.date!)}  ${widget.complainData!.time!}",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const FieldSpace(SpaceType.small),
                    Row(
                      children: [
                        Text(
                          "${AppString.productName}: ",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const FieldSpace(SpaceType.small),
                        Expanded(
                          child: Text(
                            widget.complainData!.product == null ? "" : widget.complainData!.product!.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const FieldSpace(SpaceType.small),
                    Row(
                      children: [
                        Text(
                          "${AppString.complainType}: ",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const FieldSpace(SpaceType.small),
                        Expanded(
                          child: Text(
                            widget.complainData!.complaintType!.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const FieldSpace(SpaceType.small),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppString.address}: ",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const FieldSpace(SpaceType.small),
                        Expanded(
                          child: Text(
                            widget.complainData!.party!.address!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const FieldSpace(SpaceType.small),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppString.area}: ",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const FieldSpace(SpaceType.small),
                        Expanded(
                          child: Text(
                            widget.complainData!.party!.area!.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const FieldSpace(SpaceType.small),
                    Row(
                      children: [
                        Text(
                          "${AppString.phoneNo}: ",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const FieldSpace(SpaceType.small),
                        Text(
                          widget.complainData!.party!.phoneNo!,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    if (widget.complainData!.party!.otherPhoneNo!.isNotEmpty) const FieldSpace(SpaceType.small),
                    if (widget.complainData!.party!.otherPhoneNo!.isNotEmpty)
                      Row(
                        children: [
                          Text(
                            "${AppString.otherPhoneNo}: ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.complainData!.party!.otherPhoneNo!,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (widget.complainData!.engineerInDate != null && widget.complainData!.engineerInTime != null)
              const FieldSpace(SpaceType.small),
              if (widget.complainData!.engineerInDate != null && widget.complainData!.engineerInTime != null)
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.complainData!.engineer != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${AppString.engineerName}: ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Expanded(
                            flex: 2,
                            child: Text(
                              widget.complainData!.engineer!.name!,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    const FieldSpace(SpaceType.small),
                    if (widget.complainData!.engineerInDate != null && widget.complainData!.engineerInTime != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${AppString.engineerIn}: ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Expanded(
                            child: Text(
                              "${widget.complainData!.engineerInDate}  ${widget.complainData!.engineerInTime}",
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    const FieldSpace(SpaceType.small),
                    if (widget.complainData!.engineerInAddress != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${AppString.engineerInAddress}: ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Expanded(
                            child: Text(
                              widget.complainData!.engineerInAddress!,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    const FieldSpace(SpaceType.small),
                    if (widget.complainData!.engineerOutDate != null && widget.complainData!.engineerOutTime != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${AppString.engineerOut}: ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Expanded(
                            child: Text(
                              "${widget.complainData!.engineerOutDate}  ${widget.complainData!.engineerOutTime}",
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    const FieldSpace(SpaceType.small),
                    if (widget.complainData!.engineerOutAddress != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${AppString.engineerOutAddress}: ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const FieldSpace(SpaceType.small),
                          Expanded(
                            child: Text(
                              widget.complainData!.engineerOutAddress!,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const FieldSpace(SpaceType.small),
              // if(widget.complainData!.imageUrl!.isEmpty && widget.complainData!.videoUrl!.isEmpty && widget.complainData!.audioUrl!.isEmpty)
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: (widget.complainData!.imageUrl!.isEmpty &&
                        widget.complainData!.videoUrl!.isEmpty &&
                        widget.complainData!.audioUrl!.isEmpty)
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(widget.complainData!.imageUrl != null && widget.complainData!.imageUrl!.isNotEmpty)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => AppGlobals.navigate(
                            context,
                            ViewMedia(
                              imageUrl: widget.complainData!.imageUrl,
                            ),
                            false,
                          ),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.image,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const FieldSpace(SpaceType.small),
                            Container(
                              // width: MediaQuery.of(context).size.width / 3.8,
                              alignment: Alignment.center,
                              // color: Colors.red,
                              height: MediaQuery.of(context).size.height / 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.complainData!.imageUrl!,
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
                    if(widget.complainData!.imageUrl != null && widget.complainData!.imageUrl!.isNotEmpty)
                    const FieldSpace(SpaceType.medium),
                    if(widget.complainData!.videoUrl != null && widget.complainData!.videoUrl!.isNotEmpty)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => AppGlobals.navigate(
                          context,
                          ViewMedia(
                            videoUrl: widget.complainData!.videoUrl,
                          ),
                          false,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.video,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const FieldSpace(SpaceType.small),
                            Container(
                              // width: MediaQuery.of(context).size.width / 3.8,
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height / 8,
                              // color: Colors.red,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
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
                    if(widget.complainData!.videoUrl != null && widget.complainData!.videoUrl!.isNotEmpty)
                    const FieldSpace(SpaceType.medium),
                    if(widget.complainData!.audioUrl != null && widget.complainData!.audioUrl!.isNotEmpty)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => AppGlobals.navigate(
                          context,
                          ViewMedia(
                            audioUrl: widget.complainData!.audioUrl,
                          ),
                          false,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.audio,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const FieldSpace(SpaceType.small),
                            Container(
                              // width: MediaQuery.of(context).size.width / 3.8,
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height / 8,
                              // color: Colors.red,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
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
              const FieldSpace(SpaceType.small),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: (widget.complainData!.engineerImageUrl!.isEmpty &&
                        widget.complainData!.engineerVideoUrl!.isEmpty &&
                        widget.complainData!.audioUrl!.isEmpty)
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
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
                              Text(
                                AppString.engImage,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const FieldSpace(SpaceType.small),
                              Container(
                                // width: MediaQuery.of(context).size.width / 3.8,
                                alignment: Alignment.center,
                                // color: Colors.red,
                                height: MediaQuery.of(context).size.height / 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
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
                              Text(
                                AppString.engVideo,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const FieldSpace(SpaceType.small),
                              Container(
                                // width: MediaQuery.of(context).size.width / 3.8,
                                alignment: Alignment.center,
                                height: MediaQuery.of(context).size.height / 8,
                                // color: Colors.red,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(AppDimen.textRadius),
                                ),
                                child: engVideoFile == null ? const Center(child: CircularProgressIndicator(),) : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.file(engVideoFile!),
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
                              Text(
                                AppString.engAudio,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const FieldSpace(SpaceType.small),
                              Container(
                                // width: MediaQuery.of(context).size.width / 3.8,
                                alignment: Alignment.center,
                                height: MediaQuery.of(context).size.height / 8,
                                // color: Colors.red,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
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
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
