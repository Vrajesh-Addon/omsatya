import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';
import 'package:omsatya/models/sales_person/sales_person_response.dart';
import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/repository/sales_repository.dart';
import 'package:omsatya/repository/todo_repository.dart';
import 'package:omsatya/screen/sales_person/add_sales_person.dart';
import 'package:omsatya/screen/sales_person/sales_in_out.dart';
import 'package:omsatya/screen/sales_person/sales_previous_history_pdf.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class Sales extends StatefulWidget {
  final int complainStatusKey;
  final bool isAdmin;

  const Sales({super.key, this.complainStatusKey = 1, this.isAdmin = false});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> with TickerProviderStateMixin{
  TabController? _tabController;

  TextEditingController txtSalesEditingController = TextEditingController();
  TextEditingController txtDateController = TextEditingController();

  List<LeadSalesPersonData> salesPersonList = [];
  List<PriorityResponse> priorityList = [];
  List<SalesPersonData> lstAllSalesUser = [];

  List<DropdownMenuItem<PriorityResponse>>? _dropdownPriorityItems;
  List<DropdownMenuItem<SalesPersonData>>? _dropdownAllSalesUser;

  PriorityResponse? _selectedPriority;
  SalesPersonData? _selectedSalesUser;
  PriorityResponse? _priorityDone;

  DateTime? selectedDate;

  int defaultComplainStatusKey = 1;

  bool isInitial = false;
  bool isPriority = false;
  bool isSalesUser = false;
  bool isChecked = false;

  ScrollController scrollController = ScrollController();
  bool isFabExtended = true;

  bool isFavourite = false;

  int _page = 1;

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_toggleFab);
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_onTabChanged);
    init();
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.removeListener(_onTabChanged);
    _tabController!.dispose();
    scrollController.removeListener(_toggleFab);
    scrollController.dispose();
    super.dispose();
  }

  init() async {
    defaultComplainStatusKey = widget.complainStatusKey;
    await fetchSalesPerson();
    await fetchPriorityData();

    _dropdownPriorityItems = buildDropdownPriorityItems(priorityList);
    _dropdownAllSalesUser = buildDropdownUserItems(lstAllSalesUser);

    // for (int x = 0; x < _dropdownPriorityItems!.length; x++) {
    //   if (_dropdownPriorityItems![x].value!.id == defaultComplainStatusKey) {
    //     _selectedPriority = _dropdownPriorityItems![x].value;
    //   }
    // }

    await fetchLeadSalesPerson();
  }


  void _toggleFab() {
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (isFabExtended) {
        setState(() {
          isFabExtended = false;
        });
      }
    } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!isFabExtended) {
        setState(() {
          isFabExtended = true;
        });
      }
    }
  }

  void _onTabChanged() {
    if (_tabController!.indexIsChanging) return;
    // Perform API call based on the tab index
    fetchDataForTab(_tabController!.index);
  }

  Future<void> fetchDataForTab(int index) async {
    // Simulate an API call with a delay
    showMessage("Index ==> $index");
    if(index == 0){
      clearFilter();
      // txtDateController.clear();
      // selectedDate = null;
      // salesPersonList.clear();
      // fetchLeadSalesPerson();
    } else {
      clearFilter();
      // txtDateController.clear();
      // selectedDate = null;
      // salesPersonList.clear();
      // fetchLeadSalesPerson();
    }
  }

  clearFilter() {
    salesPersonList.clear();
    _selectedPriority = null;
    _selectedSalesUser = null;
    selectedDate = null;
    txtDateController.clear();
    isFavourite = false;
    reset();
  }

  Future<void> reset() async {
    salesPersonList.clear();
    fetchLeadSalesPerson();
  }

  fetchPriorityData() async {
    try {
      setState(() {
        isPriority = true;
      });

      var response = await TodoRepository().getPriorityResponse(priority: 0, status: 1);

      if (response.success) {
        priorityList = response.data;
        isPriority = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isPriority = false;
      });
    } finally {
      setState(() {
        isPriority = false;
      });
    }
  }

  fetchSalesPerson() async {
    try {
      setState(() {
        isSalesUser = true;
      });

      var response = await SalesRepository().getSalesPerson(isEmb: 1, isCir: 1);

      if (response.success) {
        List<SalesPersonData> list = response.data;
        lstAllSalesUser = list;
        isSalesUser = false;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isSalesUser = false;
      });
    } finally {
      setState(() {
        isSalesUser = false;
      });
    }
  }

  fetchLeadSalesPerson() async {
    try {
      setState(() {
        isInitial = true;
      });

      String? closedDate;
      if(_selectedPriority != null && _selectedPriority!.id == 7){
        closedDate =  txtDateController.text.isEmpty ? null : txtDateController.text;
      }

      var response = await SalesRepository().getLeadSalesPerson(
          userId: _selectedSalesUser?.id.toString(),
          priorityId: _priorityDone == null ? _selectedPriority?.id.toString() : _priorityDone?.id.toString(),
          date: _tabController!.index == 0 ? AppGlobals().getCurrentDate() : txtDateController.text,
          closedDate: closedDate,
          favourite: isFavourite ? "1" : null,
          index: _tabController!.index
      );

      if (response.success) {
        if (_selectedSalesUser != null || _selectedPriority != null) {
          List<LeadSalesPersonData> list = response.data;
          list.removeWhere((element) {
            return element.salesPersonTask!.isEmpty;
          });
          salesPersonList = list;
        } else {
          salesPersonList = response.data;
        }
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

  favouriteSales(int? salesId, int? favourite) async {
    try {
      var response = await SalesRepository().favouriteSales(salesId: salesId, favourite: favourite);

      if (response.status!) {
        AppGlobals.showMessage(response.message!, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  _deleteTodo(BuildContext context, int? id) async {
    try {
      var response = await SalesRepository().deleteSalesDataById(id: id);

      if (response.success) {
        Navigator.pop(context);
        AppGlobals.showMessage(response.message, MessageType.success);
        reset();
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
    } finally {}
  }

  _tabOption(int index, listIndex, context) async {
    showMessage("Index ==> $index");
    switch (index) {
      case 0:
        AppGlobals.navigate(
          context,
          SalesPreviousHistoryPDF(leadSalesId: salesPersonList[listIndex].id),
          false,
        );
        break;
      case 1:
        bool result = await AppGlobals.navigateAndReturn(
          context,
          SalesInOutScreen(leadSalesPersonData: salesPersonList[listIndex]),
          false,
        );
        if (result) reset();
        break;
      case 2:
        // if (salesPersonList[listIndex].saleUserId != AppGlobals.user!.id) {
        bool result = await AppGlobals.navigateAndReturn(
          context,
          AddSalesPerson(leadSalesPersonData: salesPersonList[listIndex]),
          false,
        );
        if (result) reset();
        // } else {
        // AppGlobals.showMessage("You created", MessageType.error);
        // }
        break;
      case 3:
        showDeleteDialog(id: salesPersonList[listIndex].id);
        break;
      default:
        break;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        txtDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: AppColors.grey153,
          labelColor: AppColors.primary,
          tabs: const <Widget>[
            Tab(
              text: "Today",
            ),
            Tab(
              text: "All",
            ),
          ],
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            AppImages.appLogo,
            width: 100,
            height: 100,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 25,
          splashColor: AppColors.primary.withOpacity(0.1),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(AppDimen.padding),
              child: Text(
                AppGlobals.user != null ? AppGlobals.user!.name! : "",
                style: const TextStyle(
                  color: AppColors.primary,
                  // color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isFabExtended ? 160.0 : 56.0,
        height: 56.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            bool? result = await AppGlobals.navigateAndReturn(context, const AddSalesPerson(), false);
            if (result != null && result) reset();
          },
          isExtended: isFabExtended,
          label: isFabExtended ? const Text(AppString.addLead) : Container(),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () => fetchLeadSalesPerson(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(AppDimen.paddingSmall),
                child: Column(
                  children: [
                    buildFilterDropDown(context),
                    const FieldSpace(SpaceType.small),
                    Expanded(
                      child: buildLeadAssignList(),
                    ),
                  ],
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: () => fetchLeadSalesPerson(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(AppDimen.paddingSmall),
                child: Column(
                  children: [
                    buildFilterDropDown(context),
                    const FieldSpace(SpaceType.small),
                    Expanded(
                      child: buildLeadAssignList(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      // body: SafeArea(
      //   child: RefreshIndicator(
      //     onRefresh: () => fetchLeadSalesPerson(),
      //     color: AppColors.primary,
      //     backgroundColor: Colors.white,
      //     child: Padding(
      //       padding: const EdgeInsets.all(AppDimen.paddingSmall),
      //       child: Column(
      //         children: [
      //           // buildFilterDropDown(context),
      //           const FieldSpace(SpaceType.small),
      //           Expanded(
      //             child: buildLeadAssignList(),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  SingleChildScrollView buildFilterDropDown(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Container(
          //   margin: const EdgeInsets.only(top: AppDimen.margin),
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: AppDimen.paddingSmall,
          //         vertical: 10,
          //       ),
          //     ),
          //     onPressed: () async {
          //       bool? result = await AppGlobals.navigateAndReturn(context, const AddSalesPerson(), false);
          //       if (result != null && result) reset();
          //     },
          //     child: const Text(
          //       AppString.addLeadAssign,
          //       style: TextStyle(
          //         fontSize: 13,
          //       ),
          //     ),
          //   ),
          // ),
          // const FieldSpace(SpaceType.small),
          if(_tabController!.index == 1)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppString.date,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const FieldSpace(SpaceType.extraSmall),
              Container(
                height: MediaQuery.of(context).size.height * 0.045,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimen.textRadius),
                ),
                child: TextFormField(
                  controller: txtDateController,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    labelText: AppString.selectDate,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () {
                    _selectDate();
                  },
                  validator: (value) {
                    // bool isValid = Validations.validateInput(value, true);
                    // if (!isValid) {
                    //   return AppString.selectDate;
                    // }
                    return null;
                  },
                ),
              ),
            ],
          ),
          if(_tabController!.index == 1)
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isSalesUser
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.user,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isSalesUser
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.56,
                      height: MediaQuery.of(context).size.height * 0.045,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<SalesPersonData>(
                          isExpanded: true,
                          hint: Text(
                            AppString.selectUser,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            width: MediaQuery.of(context).size.width * 0.56,
                            maxHeight: MediaQuery.of(context).size.height / 1.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            width: MediaQuery.of(context).size.width * 0.56,
                            padding: const EdgeInsets.only(
                              left: AppDimen.paddingSmall,
                              right: AppDimen.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                              color: Colors.white,
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: MediaQuery.of(context).size.height * 0.045,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedSalesUser,
                          items: _dropdownAllSalesUser,
                          onChanged: (SalesPersonData? selectedFilter) {
                            setState(() {
                              _selectedSalesUser = selectedFilter;
                            });
                            reset();
                          },
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              txtSalesEditingController.clear();
                            }
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: txtSalesEditingController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: txtSalesEditingController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: AppString.searchForName,
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              return item.value!.name!.toLowerCase().contains(searchValue);
                            },
                          ),
                        ),
                      ),
                    ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPriority
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.015,
                      radius: 4)
                  : const Text(
                      AppString.status,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const FieldSpace(SpaceType.extraSmall),
              isPriority
                  ? ShimmerHelper().buildBasicShimmer(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.048,
                      radius: AppDimen.textRadius)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.048,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<PriorityResponse>(
                          isExpanded: true,
                          hint: Text(
                            AppString.selectStatus,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              color: Colors.white,
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: const EdgeInsets.only(
                              left: AppDimen.paddingSmall,
                              right: AppDimen.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                              color: Colors.white,
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: MediaQuery.of(context).size.height * 0.05,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
                          ),
                          value: _selectedPriority,
                          items: _dropdownPriorityItems,
                          onChanged: (PriorityResponse? selectedPriority) {
                            setState(() {
                              _selectedPriority = selectedPriority;
                            });
                            reset();
                          },
                        ),
                      ),
                    ),
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
            children: [
              const Text(
                AppString.clear,
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(onPressed: () {
                if(isFavourite) {
                  isFavourite = false;
                } else {
                  isFavourite = true;
                }
                setState(() {});
                reset();
              }, icon: isFavourite ? const Icon(Icons.star_rounded,) : const Icon(Icons.star_border_rounded,),
              ),
              /*Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    // Initial checkbox state (true or false)
                    onChanged: (newValue) {
                      if (isChecked) {
                        isChecked = newValue!;
                        _priorityDone = null;
                      } else {
                        isChecked = newValue!;
                        _selectedPriority = null;
                        _priorityDone = PriorityResponse(id: 7, priority: "Done");
                      }
                      setState(() {});
                      reset();
                    },
                    checkColor: Colors.white,
                    // Color of the checkmark inside the checkbox
                    activeColor: AppColors.primary,
                    // Color of the checkbox border when unchecked
                    shape: const RoundedRectangleBorder(),
                  ),
                  const Text("Done"),
                ],
              ),*/
            ],
          ),
          const FieldSpace(SpaceType.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppString.clear,
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => clearFilter(),
                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                highlightColor: AppColors.primary.withOpacity(0.2),
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.045,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                  child: Text(
                    AppString.clear,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildLeadAssignList() {
    if (isInitial && salesPersonList.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 5,
          itemHeight: 180.0,
        ),
      );
    } else if (salesPersonList.isNotEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 6,
            );
          },
          itemCount: salesPersonList.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildLeadSalesItemCard(index, salesPersonList[index]);
          },
        ),
      );
    } else if (!isInitial && salesPersonList.isEmpty) {
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

  GestureDetector buildLeadSalesItemCard(index, LeadSalesPersonData salesPersonData) {
    return GestureDetector(
      onTap: () async {
        // if (salesPersonData.saleUserId != AppGlobals.user!.id) {
        bool result = await AppGlobals.navigateAndReturn(
          context,
          AddSalesPerson(leadSalesPersonData: salesPersonList[index]),
          false,
        );
        if (result) reset();
        // } else {
        // AppGlobals.showMessage("You created", MessageType.error);
        // }
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
                          "Lead No",
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
                          "${salesPersonData.id!}",
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
                          AppString.dateTime,
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
                          "${salesPersonData.date!}  ${salesPersonData.time!}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.partyname != null && salesPersonData.partyname!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.partyName,
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
                          salesPersonData.partyname!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.mobileNo != null && salesPersonData.mobileNo!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.phoneNo,
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
                          salesPersonData.mobileNo!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.product != null && salesPersonData.product!.name!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          AppString.productName,
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
                          salesPersonData.product!.name!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.saleUserDetail != null && salesPersonData.saleUserDetail!.name!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Assigned By",
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
                          salesPersonData.saleUserDetail!.name!,
                          maxLines: 2,
                          style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.saleAssignUser != null && salesPersonData.saleAssignUser!.name!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Assigned To",
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
                          salesPersonData.saleAssignUser!.name!,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.purple, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (salesPersonData.inDateTime != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            AppString.inDateTime,
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
                            salesPersonData.inDateTime ?? "",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (salesPersonData.inAddress != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            AppString.inAddress,
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
                            salesPersonData.inAddress!,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (salesPersonData.outDateTime != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            AppString.outDateTime,
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
                            salesPersonData.outDateTime ?? "",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (salesPersonData.outAddress != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            AppString.outAddress,
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
                            salesPersonData.outAddress ?? "",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (salesPersonData.timeDuration != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            AppString.totalTime,
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
                            salesPersonData.timeDuration!,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if(salesPersonData.salesPersonTask!.isNotEmpty && (salesPersonData.salesPersonTask!.last.date != null && salesPersonData.salesPersonTask!.last.time != null))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Remainder Date/Time",
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
                          "${salesPersonData.nextReminderDate!} ${salesPersonData.nextReminderTime}",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.salesPersonTask!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Comment",
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
                          salesPersonData.salesPersonTask!.last.commentFirst ?? "",
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     const Expanded(
                  //       child: Text(
                  //         "Comment 2",
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //           fontSize: 13,
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                  //       child: Text(
                  //         ":",
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       flex: 2,
                  //       child: Text(
                  //         salesPersonData.salesPersonTask!.last.commentSecond!,
                  //         maxLines: 2,
                  //         style: const TextStyle(
                  //           color: Colors.black,
                  //           fontSize: 13,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  if(salesPersonData.salesPersonTask!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          "Status",
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
                          salesPersonData.salesPersonTask!.last.priorityResponse!.priority ?? "",
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(salesPersonData.address != null && salesPersonData.address!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          salesPersonData.address! ?? "",
                          maxLines: 4,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const FieldSpace(SpaceType.small),
                      GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Open in Google Maps'),
                                content: const Text('Do you want to open this address in Google Maps?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(); // Close the dialog
                                      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(salesPersonData.address!)}';
                                      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                                        await launchUrl(Uri.parse(googleMapsUrl));
                                      } else {
                                        throw 'Could not launch $googleMapsUrl';
                                      }
                                    },
                                    child: const Text('Open'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Clipboard.setData(ClipboardData(text: complainData.party!.address!));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 0),
                          padding: const EdgeInsets.all(AppDimen.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppDimen.textRadius),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20,),
                        ),
                      ),
                      // const Expanded(
                      //   child: Text(
                      //     AppString.address,
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 13,
                      //     ),
                      //   ),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
                      //   child: Text(
                      //     ":",
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //     ),
                      //   ),
                      // ),
                      /*Row(
                        children: [
                          Text(
                            complainData.party!.address! ?? "",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: complainData.party!.address!));
                              // AppGlobals.showMessage("Address copied", MessageType.success);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 0),
                              padding: const EdgeInsets.all(AppDimen.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppDimen.textRadius),
                              ),
                              child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20,),
                            ),
                          ),
                        ],
                      ),*/

                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: showOptions(listIndex: index, context: context, data: salesPersonData),
            ),
            Positioned(
              bottom: (salesPersonData.address != null && salesPersonData.address!.isNotEmpty) ? 55.0 : 10.0,
              right: 10.0,
              child: IconButton(
                onPressed: () {
                  favouriteSales(salesPersonData.id, salesPersonData.favourite == 0 ? 1 : 0);
                },
                icon: Icon(
                  salesPersonData.favourite == 1 ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showOptions({listIndex, context, LeadSalesPersonData? data}) {
    return PopupMenuButton<SalesMenuOptions>(
      offset: const Offset(-25, 0),
      onSelected: (SalesMenuOptions result) {
        _tabOption(result.index, listIndex, context);
      },
      splashRadius: 25,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SalesMenuOptions>>[
        const PopupMenuItem<SalesMenuOptions>(
          value: SalesMenuOptions.previousDetails,
          child: Text("Previous History"),
        ),
        if(data!.saleUserId != AppGlobals.user!.id && (data.inDateTime == null || data.outDateTime == null))
        const PopupMenuItem<SalesMenuOptions>(
          value: SalesMenuOptions.inOut,
          child: Text("In/Out"),
        ),
        const PopupMenuItem<SalesMenuOptions>(
          value: SalesMenuOptions.edit,
          child: Text("Edit"),
        ),
        if(data.saleUserId == AppGlobals.user!.id)
        const PopupMenuItem<SalesMenuOptions>(
          value: SalesMenuOptions.delete,
          child: Text("Delete"),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimen.paddingSmall,
            vertical: AppDimen.paddingSmall,
          ),
          alignment: Alignment.topRight,
          child: const Icon(Icons.more_vert_rounded),
        ),
      ),
    );
  }

  List<DropdownMenuItem<PriorityResponse>> buildDropdownPriorityItems(List<PriorityResponse> priorityList) {
    List<DropdownMenuItem<PriorityResponse>> items = [];
    for (PriorityResponse item in priorityList as Iterable<PriorityResponse>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.priority!.toCapitalize(),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<SalesPersonData>> buildDropdownUserItems(List<SalesPersonData> salesList) {
    List<DropdownMenuItem<SalesPersonData>> items = [];
    for (SalesPersonData item in salesList as Iterable<SalesPersonData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  showDeleteDialog({int? id}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // contentPadding: EdgeInsets.zero,
          // titlePadding: EdgeInsets.zero,
          title: const Text(
            AppString.deleteTitle,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppString.deleteSubtitleSales,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () => _deleteTodo(context, id),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
