import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/repository/customer_repository.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CustomerPreviousComplainPDF extends StatefulWidget {
  final ComplainData? complainData;

  const CustomerPreviousComplainPDF({super.key, this.complainData});

  @override
  State<CustomerPreviousComplainPDF> createState() => _CustomerPreviousComplainPDFState();
}

class _CustomerPreviousComplainPDFState extends State<CustomerPreviousComplainPDF> {
  List<ComplainData> complainList = [];
  bool isInitial = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await fetchPreviousComplainList();
  }

  fetchPreviousComplainList() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await CustomerRepository().getCustomerPreviousComplain(
        partyId: AppGlobals.user!.id!,
        machineSalesId: widget.complainData!.salesEntry!.id!,
      );

      if (response.success!) {
        complainList = response.data;
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
          buildRowPdf('Product', complainData.product!.name),
          buildRowPdf('Machine SR. No', "${complainData.salesEntry!.serialNo!} / ${complainData.salesEntry!.mcNo!}"),
          buildRowPdf('Complain', complainData.complaintType!.name),
          buildRowPdf('Service Type', complainData.serviceType!.name),
          buildRowPdf('Remarks', complainData.remarks!),
          if (complainData.engineer != null)
            buildRowPdf('Engineer', complainData.engineer!.name!),
          if (complainData.engineerInDate != null && complainData.engineerInTime != null)
            buildRowPdf('Engineer In', "${complainData.engineerInDate} ${complainData.engineerInTime}"),
          if (complainData.engineerOutDate != null && complainData.engineerOutTime != null)
            buildRowPdf('Engineer Out', "${complainData.engineerOutDate} ${complainData.engineerOutTime}"),
          buildRowPdf('Status', AppGlobals().getStatus(complainData.statusId)),
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
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(": "),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
