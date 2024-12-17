import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/models/todo/todo_data_by_id.dart';
import 'package:omsatya/models/todo/todo_task.dart';
import 'package:omsatya/repository/todo_repository.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TodoPreviousHistoryPDF extends StatefulWidget {
  final int? todoId;

  const TodoPreviousHistoryPDF({super.key, this.todoId});

  @override
  State<TodoPreviousHistoryPDF> createState() => _TodoPreviousHistoryPDFState();
}

class _TodoPreviousHistoryPDFState extends State<TodoPreviousHistoryPDF> {
  List<TodoTask> lstTodoTask = [];
  TodoDataById? todoData;
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

      var response =
      await TodoRepository().getTodoDataById(todoId: widget.todoId);

      if (response.status!) {
        todoData = response.data!;
        lstTodoTask = response.data!.todoTasks!;
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
            AppString.noTodoAssign,
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
                buildRow("Todo No", todoData!.id.toString()),
                buildRow("Date/Time", "${todoData!.assignDateTime!}"),
                buildRow("Title", todoData!.title!),
                buildRow("Description", todoData!.description!),
                // buildRow("Assign to", "${todoData!.userResponse!.name}"),
                buildRow("Remainder Date/Time", "${todoData!.todoTasks!.first.date} ${todoData!.todoTasks!.first.time}"),
                buildRow("Comment", todoData!.todoTasks!.first.commentFirst!),
                // buildRow("Comment 2", todoData!.todoTasks!.first.commentSecond!),
                buildRow("Priority", todoData!.todoTasks!.first.priorityResponse!.priority!),
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

  pw.Widget buildTodoTaskCard(TodoTask todoTask) {
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
          // buildRow("Todo No", todoTask.todoId.toString()),
          buildRow("Remainder Date/Time", "${todoTask.date} ${todoTask.time}"),
          buildRow("Comment", todoTask.commentFirst ?? "N/A"),
          // buildRow("Comment 2", todoTask.commentSecond ?? "N/A"),
          // buildRow("Priority", todoTask.priorityResponse?.priority ?? "N/A"),
        ],
      ),
    );
  }

  pw.Widget buildRow(String label, String value) {
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
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
