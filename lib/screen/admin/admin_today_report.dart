import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/admin_today_report/admin_today_report_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/screen/admin/admin_report_pdf.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminTodayReport extends StatefulWidget {
  const AdminTodayReport({super.key});

  @override
  State<AdminTodayReport> createState() => _AdminTodayReportState();
}

class _AdminTodayReportState extends State<AdminTodayReport> {
  final TextEditingController _txtDateController = TextEditingController();

  List<TodaysTotalDone> totalPendingComplaints = [];
  List<TodaysTotalDone> totalTodaysComplaints = [];
  List<TodaysTotalDone> todaysTotalDones = [];
  AdminTodayReportData? adminTodayReportData;

  DateTime? selectedDate;

  String currentDate = "";

  bool isInitial = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _txtDateController.dispose();
    super.dispose();
  }

  init() async {
    final now = DateTime.now();
    currentDate = DateFormat('dd-MM-yyyy').format(now);
    _txtDateController.text = currentDate;
    // await fetchAdminTodayReport();
  }

  fetchAdminTodayReport(BuildContext context) async {
    try {
      setState(() {
        isInitial = true;
      });

      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      DateTime parsedDate = inputFormat.parse(_txtDateController.text.trim());
      String outputDate = outputFormat.format(parsedDate);

      var response = await ComplainRepository().getTodayReportData(outputDate);

      if (response.success!) {
        adminTodayReportData = response.data!;

        AppGlobals.navigate(
            context,
            AdminTodayReportPDF(
              date: _txtDateController.text.trim(),
              adminTodayReportData: response.data!,
              totalPendingComplaints: response.data!.totalPendingComplaints!,
              totalTodaysComplaints: response.data!.totalTodaysComplaints!,
              todaysTotalDones: response.data!.todaysTotalDones!,
            ),
            false);
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

  Future<void> _selectReminderDate() async {
    final DateTime? picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _txtDateController.text = DateFormat('dd-MM-yyyy').format(picked);
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
      body: Padding(
        padding: const EdgeInsets.all(AppDimen.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _txtDateController,
              decoration: const InputDecoration(
                labelText: AppString.date,
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              readOnly: true,
              onTap: () {
                _selectReminderDate();
              },
              validator: (value) {
                bool isValid = Validations.validateInput(value, true);
                if (!isValid) {
                  return AppString.selectDate;
                }
                return null;
              },
            ),
            const FieldSpace(),
            PrimaryButton(text: "Generate PDF", onPressed: () async {
              await fetchAdminTodayReport(context);
            },),
            isInitial ?
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 2 ,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(),
                  ),
                  FieldSpace(),
                  Text(AppString.pleaseWait),
                ],
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  buildAminTodayReport() {
    if (isInitial && adminTodayReportData == null) {
      return const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(),
            ),
            FieldSpace(),
            Text(AppString.pleaseWait),
          ],
        ),
      );
    } else if (adminTodayReportData != null) {
      return const SizedBox();
    } else if (!isInitial && adminTodayReportData == null) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noDataFond,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }
}
