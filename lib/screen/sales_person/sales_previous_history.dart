import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';
import 'package:omsatya/models/todo/todo_task.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class SalesPreviousHistory extends StatefulWidget {
  final int? leadSalesId;

  const SalesPreviousHistory({super.key, this.leadSalesId});

  @override
  State<SalesPreviousHistory> createState() => _SalesPreviousHistoryState();
}

class _SalesPreviousHistoryState extends State<SalesPreviousHistory> {
  TextEditingController textEditingController = TextEditingController();

  List<TodoTask> lstTodoTask = [];

  LeadSalesPersonData? leadSalesPersonData;

  int defaultComplainStatusKey = 1;

  bool isInitial = true;
  bool isStatus = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await fetchTodoDataByID();
  }

  clearFilter() {}

  reset() async {
    lstTodoTask.clear();
    await fetchTodoDataByID();
  }

  fetchTodoDataByID() async {
    try {
      setState(() {
        isInitial = true;
      });

      var response = await SalesRepository().getLeadSalesPersonById(id: widget.leadSalesId);

      if (response.success!) {
        leadSalesPersonData = response.data!;
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
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.paddingSmall),
          child: Column(
            children: [

              const FieldSpace(SpaceType.small),
              Expanded(
                child: buildTodoList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildTodoList() {
    if (isInitial && lstTodoTask.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (lstTodoTask.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () => reset(),
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 6,
              );
            },
            itemCount: lstTodoTask.length,
            scrollDirection: Axis.vertical,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildTodoItemCard(index, lstTodoTask[index]);
            },
          ),
        ),
      );
    } else if (!isInitial && lstTodoTask.isEmpty) {
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

  Card buildTodoItemCard(index, TodoTask todoTask) {
    return Card(
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
                        "Todo No",
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
                        "${todoTask.todoId!}",
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
                          "Next Date/Time",
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
                          "${todoTask.date} ${todoTask.time}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
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
                          "Comment 1",
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
                          todoTask.commentFirst!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
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
                          "Comment 2",
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
                          todoTask.commentSecond!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
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
                        AppString.priority,
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
                        todoTask.priorityResponse!.priority!,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          // color: AppGlobals().getStatus(complainData.statusId).toLowerCase() ==
                          //     "pending"
                          //     ? Colors.red
                          //     : AppGlobals().getStatus(complainData.statusId).toLowerCase() ==
                          //     "in progress"
                          //     ? Colors.purple
                          //     : AppColors.success,
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
    );
  }

}
