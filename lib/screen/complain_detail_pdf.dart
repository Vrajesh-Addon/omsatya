import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class ComplainDetailPDF extends StatefulWidget {
  final ComplainData? complainData;

  const ComplainDetailPDF({super.key, this.complainData});

  @override
  State<ComplainDetailPDF> createState() => _ComplainDetailPDFState();
}

class _ComplainDetailPDFState extends State<ComplainDetailPDF> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: PdfPreview(
          build: (format) => _createPdf(
            format,
            context,
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _createPdf(
    PdfPageFormat format, BuildContext cont,
  ) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );
    pdf.addPage(
      pw.Page(
        // pageTheme: pw.PageTheme(
        //   buildBackground: (context) => pw.Container(
        //     color: PdfColors.grey100,
        //   ),
        // ),
        // pageFormat: const PdfPageFormat(
        //   (80 * (72.0 / 25.4)),
        //   600,
        //   marginAll: 5 * (72.0 / 25.4),
        // ),
        build: (context) {
          return pw.Column(
            children: [
              pw.Container(
                width: MediaQuery.of(cont).size.width,
                color:  const PdfColor.fromInt(0XFFFFFF),
                padding: const pw.EdgeInsets.symmetric(horizontal: AppDimen.padding),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: AppDimen.paddingSmall, bottom: AppDimen.paddingSmall),
                      child: pw.RichText(
                        text: pw.TextSpan(
                          text: "Status: ",
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                          children: [
                            pw.TextSpan(
                              text: AppGlobals().getStatus(widget.complainData!.statusId),
                              style: pw.TextStyle(
                                fontSize: 18, // Set a manual font size equivalent to titleLarge
                                color: AppGlobals().getStatus(widget.complainData!.statusId).toLowerCase() == "pending"
                                    ? PdfColors.red
                                    : AppGlobals().getStatus(widget.complainData!.statusId).toLowerCase() ==
                                            "in progress"
                                        ? PdfColors.purple
                                        : PdfColors.green, // Replace AppColors.success with PdfColors.green
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: MediaQuery.of(cont).size.width,
                color: const PdfColor.fromInt(0XFFFFFF),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: AppDimen.padding,
                  vertical: AppDimen.paddingSmall,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      AppString.partyName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      widget.complainData!.party!.name!.toCapitalize(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.normal,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: MediaQuery.of(cont).size.width,
                color: const PdfColor.fromInt(0XFFFFFFF),
                padding: const pw.EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              AppString.complainNo,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              widget.complainData!.complaintNo!,
                              textAlign: pw.TextAlign.end,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              AppString.machineNo,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "${widget.complainData!.salesEntry!.serialNo!} / ${widget.complainData!.salesEntry!.mcNo!}",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Text(
                          "${AppString.dateTime}: ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Expanded(
                          child: pw.Text(
                            "${AppGlobals.changeDateFormat(widget.complainData!.date!)}  ${widget.complainData!.time!}",
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Text(
                          "${AppString.productName}: ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Expanded(
                          child: pw.Text(
                            widget.complainData!.product == null ? "" : widget.complainData!.product!.name,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Text(
                          "${AppString.complainType}: ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Expanded(
                          child: pw.Text(
                            widget.complainData!.complaintType!.name,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: MediaQuery.of(cont).size.width,
                color: const PdfColor.fromInt(0XFFFFFF),
                padding: const pw.EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "${AppString.address}: ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Expanded(
                          child: pw.Text(
                            widget.complainData!.party!.address!,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "${AppString.area}: ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Expanded(
                          child: pw.Text(
                            widget.complainData!.party!.area!.name,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Text(
                          "${AppString.phoneNo}: ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          widget.complainData!.party!.phoneNo!,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.normal,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                    if (widget.complainData!.party!.otherPhoneNo!.isNotEmpty) pw.SizedBox(height: 8),
                    if (widget.complainData!.party!.otherPhoneNo!.isNotEmpty)
                      pw.Row(
                        children: [
                          pw.Text(
                            "${AppString.otherPhoneNo}: ",
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Flexible(
                            child:  pw.Text(
                              widget.complainData!.party!.otherPhoneNo!,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (widget.complainData!.engineerInDate != null && widget.complainData!.engineerInTime != null)
                pw.SizedBox(height: 8),
              if (widget.complainData!.engineerInDate != null && widget.complainData!.engineerInTime != null)
                pw.Container(
                  width: MediaQuery.of(cont).size.width,
                  color: const PdfColor.fromInt(0XFFFFFF),
                  padding: const pw.EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (widget.complainData!.engineer != null)
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${AppString.engineerName}: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                widget.complainData!.engineer!.name!,
                                maxLines: 2,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      pw.SizedBox(height: 8),
                      if (widget.complainData!.engineerInDate != null && widget.complainData!.engineerInTime != null)
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${AppString.engineerIn}: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Expanded(
                              child: pw.Text(
                                "${widget.complainData!.engineerInDate}  ${widget.complainData!.engineerInTime}",
                                maxLines: 2,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      pw.SizedBox(height: 8),
                      if (widget.complainData!.engineerInAddress != null)
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${AppString.engineerInAddress}: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Expanded(
                              child: pw.Text(
                                widget.complainData!.engineerInAddress!,
                                maxLines: 2,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      pw.SizedBox(height: 8),
                      if (widget.complainData!.engineerOutDate != null && widget.complainData!.engineerOutTime != null)
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${AppString.engineerOut}: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Expanded(
                              child: pw.Text(
                                "${widget.complainData!.engineerOutDate}  ${widget.complainData!.engineerOutTime}",
                                maxLines: 2,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      pw.SizedBox(height: 8),
                      if (widget.complainData!.engineerOutAddress != null)
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${AppString.engineerOutAddress}: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Expanded(
                              child: pw.Text(
                                widget.complainData!.engineerOutAddress!,
                                maxLines: 2,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: MediaQuery.of(cont).size.width,
                  color: const PdfColor.fromInt(0XFFFFFF),
                  padding: const pw.EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: AppDimen.padding),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${AppString.createdBy}: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                AppGlobals.user!.name!,
                                maxLines: 2,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}
