import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/customer_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PreviousComplainPDF extends StatefulWidget {
  final int? complainId;

  const PreviousComplainPDF({super.key, this.complainId});

  @override
  State<PreviousComplainPDF> createState() => _PreviousComplainPDFState();
}

class _PreviousComplainPDFState extends State<PreviousComplainPDF> {
  TextEditingController textEditingController = TextEditingController();

  List<ComplainData> complainList = [];

  Data? data;
  int defaultComplainStatusKey = 1;
  bool isInitial = true;


  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await fetchPreviousComplainList();
  }

  clearFilter() {}

  reset() {
    complainList.clear();
    fetchPreviousComplainList();
  }

  fetchPreviousComplainList() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await ComplainRepository().getPreviousComplain(widget.complainId!);

      if (response.success) {
        complainList = response.data!.pastComplaints;
        isInitial = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: buildComplainList(),
      ),
    );
  }

  buildComplainList() {
    if (isInitial && complainList.isEmpty) {
      return const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            FieldSpace(),
            Text(AppString.pleaseWait),
          ],
        ),
      );
    } else if (complainList.isNotEmpty) {
      return PdfPreview(
        build: (format) => _createPdf(
          format,
          context,
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

  Future<Uint8List> _createPdf(
      PdfPageFormat format,
      BuildContext cont,
      ) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: complainList.map((complainData) {
              // showMessage("complainData.engineer ==> ${complainData.complaintNo} = ${complainData.engineer}");
              return buildComplainCardPdf(complainData);
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget buildComplainCardPdf(ComplainData complainData) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildRowPdf('Complaint No', complainData.complaintNo!),
          buildRowPdf('Date/Time', "${complainData.date!} ${complainData.time!}"),
          buildRowPdf('Party', complainData.party!.name!),
          buildRowPdf('Product Name', complainData.product!.name),
          buildRowPdf('Machine SR. No', "${complainData.salesEntry!.serialNo!} / ${complainData.salesEntry!.mcNo!}"),
          buildRowPdf('Complain', complainData.complaintType!.name),
          buildRowPdf('Service Type', complainData.serviceType!.name),
          buildRowPdf('Remarks', complainData.remarks!),
          if (complainData.engineerDetail != null)
            buildRowPdf('Engineer', complainData.engineerDetail!.name!),
          if (complainData.engineerInDate != null && complainData.engineerInTime != null)
            buildRowPdf('Engineer In', "${complainData.engineerInDate} ${complainData.engineerInTime}"),
          if (complainData.engineerOutDate != null && complainData.engineerOutTime != null)
            buildRowPdf('Engineer Out', "${complainData.engineerOutDate} ${complainData.engineerOutTime}"),
          // pw.Row(
          //   children: [
          //     pw.Expanded(
          //       child: pw.Text(
          //         "Assign ${AppString.status}",
          //         style: pw.TextStyle(
          //           color: PdfColors.black,
          //           fontWeight: pw.FontWeight.bold,
          //           fontSize: 13,
          //         ),
          //       ),
          //     ),
          //     pw.Text(
          //       ": ",
          //     ),
          //     pw.Expanded(
          //       child: pw.RichText(text:
          //       pw.TextSpan(
          //           text: AppGlobals().getAdminStatus(complainData.isAssign),
          //           style: pw.TextStyle(
          //             fontSize: 13,
          //             fontWeight: pw.FontWeight.bold,
          //             color: AppGlobals()
          //                 .getAdminStatus(complainData.isAssign)
          //                 .toLowerCase() ==
          //                 "not assign"
          //                 ? PdfColors.red
          //                 : PdfColors.green,
          //           ),
          //           children: [
          //             if(complainData.engineerAssignDate != null && complainData.engineerAssignTime != null)
          //               pw.TextSpan(
          //                 text: "  ${complainData.engineerAssignDate}  ${complainData.engineerAssignTime}",
          //                 style: pw.TextStyle(
          //                   fontSize: 13,
          //                   fontWeight: pw.FontWeight.bold,
          //                   color: PdfColors.green,
          //                 ),
          //               ),
          //           ]
          //       ),
          //       ),
          //     ),
          //   ],
          // ),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  "Status",
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              pw.Text(
                ": ",
              ),
              pw.Expanded(
                child: pw.Text(
                  AppGlobals().getStatus(complainData!.statusId),
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: AppGlobals().getStatus(complainData!.statusId).toLowerCase() == "pending"
                        ? PdfColors.red
                        : AppGlobals().getStatus(complainData!.statusId).toLowerCase() == "in progress"
                            ? PdfColors.purple
                            : PdfColors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildRowPdf(String label, String value) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(": "),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
