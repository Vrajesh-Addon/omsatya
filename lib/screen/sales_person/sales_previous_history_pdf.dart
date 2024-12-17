import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';
import 'package:omsatya/models/sales_person/sales_person_task.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalesPreviousHistoryPDF extends StatefulWidget {
  final int? leadSalesId;

  const SalesPreviousHistoryPDF({super.key, this.leadSalesId});

  @override
  State<SalesPreviousHistoryPDF> createState() => _SalesPreviousHistoryPDFState();
}

class _SalesPreviousHistoryPDFState extends State<SalesPreviousHistoryPDF> {
  List<SalesPersonTask> lstTodoTask = [];
  LeadSalesPersonData? leadSalesPersonData;
  bool isInitial = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await fetchTodoDataByID();
  }

  fetchTodoDataByID() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await SalesRepository().getLeadSalesPersonById(id: widget.leadSalesId);

      if (response.success!) {
        leadSalesPersonData = response.data;
        lstTodoTask = response.data!.salesPersonTask!;
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
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: buildTodoTaskList(),
      ),
    );
  }

  buildTodoTaskList() {
    if (isInitial && lstTodoTask.isEmpty) {
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
    } else if (lstTodoTask.isNotEmpty) {
      return PdfPreview(
        build: (format) => _createPdf(
          format,
          context,
        ),
      );
    } else if (!isInitial && lstTodoTask.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noSalesAssign,
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
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 8),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey200, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildRow("Todo No", leadSalesPersonData!.id.toString()),
                buildRow("Date/Time", "${leadSalesPersonData!.date} ${leadSalesPersonData!.time}"),
                buildRow("Party Name", leadSalesPersonData!.partyname!),
                buildRow("Mobile No", leadSalesPersonData!.mobileNo!),
                buildRow("Product Name", leadSalesPersonData!.product!.name!),
                buildRow("Assigned By", leadSalesPersonData!.saleUserDetail!.name!, color: const PdfColor.fromInt(0xFF243D7C)),
                buildRow("Assigned To", leadSalesPersonData!.saleAssignUser!.name!, color: PdfColors.purple),
                if(leadSalesPersonData!.salesPersonTask!.isNotEmpty && (leadSalesPersonData!.salesPersonTask!.last.date != null && leadSalesPersonData!.salesPersonTask!.last.time != null))
                buildRow("Next Date/Time", "${leadSalesPersonData!.salesPersonTask!.last.date ?? ""} ${leadSalesPersonData!.salesPersonTask!.last.time ?? ""}"),
                buildRow("Comment", leadSalesPersonData!.salesPersonTask!.last.commentFirst!),
                // buildRow("Comment 2", leadSalesPersonData!.salesPersonTask!.first.commentSecond!),
                buildRow("Lead Stage", leadSalesPersonData!.salesPersonTask!.last.priorityResponse!.priority!),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: lstTodoTask.map((todoTask) {
              return buildTodoTaskCard(todoTask);
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget buildTodoTaskCard(SalesPersonTask todoTask) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.black, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildRow("Todo No", todoTask.todoId.toString()),
          if(todoTask.assignUserDetail != null)
          buildRow("Assign To", todoTask.assignUserDetail!.name ?? ""),
          if(todoTask.date != null && todoTask.time != null)
          buildRow("Remainder Date/Time", "${todoTask.date} ${todoTask.time}"),
          buildRow("Comment", todoTask.commentFirst ?? "N/A"),
          // buildRow("Comment 2", todoTask.commentSecond ?? "N/A"),
          buildRow("Priority", todoTask.priorityResponse?.priority ?? "N/A"),
        ],
      ),
    );
  }

  pw.Widget buildRow(String label, String value, {PdfColor color = PdfColors.black}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
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
          flex: 2,
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }

}
