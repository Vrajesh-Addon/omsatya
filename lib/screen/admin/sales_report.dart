import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/sales_person/sales_report_response.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/screen/admin/sales_user_report.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final TextEditingController _txtDateController = TextEditingController();
  List<SalesReportData> salesReportList = [];
  SalesReportResponse? salesReportData;
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
    await fetchSalesReport();
  }

  Future<void> reset() async {
    salesReportList.clear();
    await fetchSalesReport();
  }

  clear() {

  }

  fetchSalesReport() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await SalesRepository().getSalesReport(date: _txtDateController.text);

      if (response.status!) {
        salesReportData = response;
        salesReportList = response.data!;

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
      await fetchSalesReport();
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
        child: RefreshIndicator(
          onRefresh: () => reset(),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppDimen.paddingSmall),
            child: Column(
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
                // buildFilterDropDown(context),
                const FieldSpace(SpaceType.small),
                Expanded(
                  child: buildSalesReportList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView buildFilterDropDown(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      child: Row(
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
        ],
      ),
    );
  }

  buildSalesReportList() {
    if (isInitial && salesReportList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 10,
          itemHeight: 80.0,
        ),
      );
    } else if (salesReportList.isNotEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 6,
            );
          },
          itemCount: salesReportList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildLeadSalesItemCard(index, salesReportList[index]);
          },
        ),
      );
    } else if (!isInitial && salesReportList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noLeadAssign,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  GestureDetector buildLeadSalesItemCard(index, SalesReportData salesReportData) {
    return GestureDetector(
      onTap: () {
        AppGlobals.navigate(
            context,
            SalesUserReportScreen(
              date: _txtDateController.text,
              userId: salesReportData.saleUserId!.toString(),
            ),
            false);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
        ),
        elevation: 2,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.sales,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          salesReportData.salseUserDetail!.name!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.count,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "${salesReportData.totalSales!}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
