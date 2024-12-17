import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/models/admin_today_report/admin_today_report_response.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminTodayReportPDF extends StatefulWidget {
  final AdminTodayReportData? adminTodayReportData;
  final List<TodaysTotalDone>? totalPendingComplaints;
  final List<TodaysTotalDone>? totalTodaysComplaints;
  final List<TodaysTotalDone>? todaysTotalDones;
  final String? date;

  const AdminTodayReportPDF({super.key, this.adminTodayReportData, this.totalPendingComplaints, this.todaysTotalDones, this.totalTodaysComplaints, this.date});

  @override
  State<AdminTodayReportPDF> createState() => _AdminTodayReportPDFState();
}

class _AdminTodayReportPDFState extends State<AdminTodayReportPDF> {
  List<TodaysTotalDone> totalPendingComplaints = [];
  List<TodaysTotalDone> totalTodaysComplaints = [];
  List<TodaysTotalDone> todaysTotalDones = [];
  AdminTodayReportData? adminTodayReportData;

  String currentDate = "";

  bool isInitial = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    showMessage("widget.totalPendingComplaints! ==> ${widget.totalTodaysComplaints!}");
    totalPendingComplaints = widget.totalPendingComplaints!;
    totalTodaysComplaints =  widget.totalTodaysComplaints!;
    todaysTotalDones =  widget.todaysTotalDones!;
    currentDate = widget.date!;
    setState(() {});
  }

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
      PdfPageFormat format,
      BuildContext cont,
      ) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );

    final headers = [
      '#',
      'Date',
      'C.No',
      'Party Name',
      'Mobile',
      'M/c',
      // 'Time',
      // 'Area',
    ];

    // Define the table header
    final headers2 = [
      '#',
      'Date',
      'C.No',
      'Eng Name',
      'Party Name',
      'Mobile',
      'M/c',
      'Time',
      // 'Area',
    ];

    final headers3 = [
      '#',
      'Date',
      'C.No',
      'Eng Name',
      'Party Name',
      'Mobile',
      'M/c',
      // 'Time',
      // 'Area',
    ];

    // Adding the first 100 records
    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) {
          return [
            pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    "Complain report $currentDate - Total: ${totalTodaysComplaints.length}",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    )
                )
            ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FractionColumnWidth(0.1), // Sr No
                1: const pw.FractionColumnWidth(0.17), // Date
                2: const pw.FractionColumnWidth(0.12), // Comp No
                3: const pw.FractionColumnWidth(0.2),  // Party Name
                4: const pw.FractionColumnWidth(0.17), // Mobile
                5: const pw.FractionColumnWidth(0.12), // Machine
                // 6: const pw.FractionColumnWidth(0.1),  // Time
                // 7: const pw.FractionColumnWidth(0.1),  // Area
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: headers.map((header) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                for (int i = 0; i < totalTodaysComplaints.length; i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text("${i + 1}"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(_formatDate(totalTodaysComplaints[i].date!)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalTodaysComplaints[i].complaintNo!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalTodaysComplaints[i].party!.name!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalTodaysComplaints[i].party!.phoneNo!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text("${totalTodaysComplaints[i].machineSalesEntry!.mcNo}"),
                      ),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.all(8.0),
                      //   child: pw.Text(totalTodaysComplaints[i].engineerTimeDuration!),
                      // ),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.all(8.0),
                      //   child: pw.Text(totalTodaysComplaints[i].party!.area!.name!),
                      // ),
                    ],
                  ),
              ],
            ),
            // pw.SizedBox(
            //   height: 50,
            // ),
            pw.NewPage(),
            pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    "Done complain report $currentDate - Total: ${todaysTotalDones.length}",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    )
                )
            ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FractionColumnWidth(0.1), // Sr No
                1: const pw.FractionColumnWidth(0.20), // Date
                2: const pw.FractionColumnWidth(0.12), // Comp No
                3: const pw.FractionColumnWidth(0.2),  // Eng Name
                4: const pw.FractionColumnWidth(0.2),  // Party Name
                5: const pw.FractionColumnWidth(0.22), // Mobile
                6: const pw.FractionColumnWidth(0.12), // Machine
                7: const pw.FractionColumnWidth(0.1),  // Time
                // 8: const pw.FractionColumnWidth(0.1),  // Area
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: headers2.map((header) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                for (int i=0; i < todaysTotalDones.length; i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text("${i + 1}"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(_formatDate(todaysTotalDones[i].date!)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(todaysTotalDones[i].complaintNo!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(todaysTotalDones[i].engineer == null ? "" : todaysTotalDones[i].engineer!.name!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(todaysTotalDones[i].party!.name!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(todaysTotalDones[i].party!.phoneNo!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text("${todaysTotalDones[i].machineSalesEntry!.mcNo}"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(todaysTotalDones[i].engineerTimeDuration!),
                      ),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.all(8.0),
                      //   child: pw.Text(todaysTotalDones[i].party!.area!.name!),
                      // ),
                    ],
                  ),
              ],
            ),
            // pw.SizedBox(
            //   height: 50,
            // ),
            pw.NewPage(),
            pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    "Till pending complain report - Total: ${totalPendingComplaints.length}",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    )
                )
            ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FractionColumnWidth(0.1), // Sr No
                1: const pw.FractionColumnWidth(0.20), // Date
                2: const pw.FractionColumnWidth(0.12), // Comp No
                3: const pw.FractionColumnWidth(0.2),  // Eng Name
                4: const pw.FractionColumnWidth(0.2),  // Party Name
                5: const pw.FractionColumnWidth(0.22), // Mobile
                6: const pw.FractionColumnWidth(0.12), // Machine
                // 7: const pw.FractionColumnWidth(0.1),  // Time
                // 8: const pw.FractionColumnWidth(0.1),  // Area
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: headers3.map((header) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                for (int i=0; i < totalPendingComplaints.length; i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text("${i + 1}"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(_formatDate(totalPendingComplaints[i].date!)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalPendingComplaints[i].complaintNo!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalPendingComplaints[i].engineer == null ? "" : totalPendingComplaints[i].engineer!.name!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalPendingComplaints[i].party!.name!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(totalPendingComplaints[i].party!.phoneNo!),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text("${totalPendingComplaints[i].machineSalesEntry!.mcNo}"),
                      ),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.all(8.0),
                      //   child: pw.Text(totalPendingComplaints[i].engineerTimeDuration!),
                      // ),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.all(8.0),
                      //   child: pw.Text(totalPendingComplaints[i].party!.area!.name!),
                      // ),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  String _formatDate(String date) {
    try {
      // Assuming `totalPendingComplaints[i].date` is a String in ISO format (e.g., "2024-10-16")
      DateTime parsedDate = DateTime.parse(date);
      // Format it as desired, for example: "MM/dd/yyyy"
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      // Handle the case where the date can't be parsed
      return date; // or return a default/fallback string
    }
  }
}
