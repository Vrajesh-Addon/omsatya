import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omsatya/helpers/location_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/customer_machine_response.dart';
import 'package:omsatya/models/get_complain_no_response.dart';
import 'package:omsatya/models/party_details_by_code_response.dart';
import 'package:omsatya/repository/complain_repository.dart';
import 'package:omsatya/repository/customer_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPartyAddress extends StatefulWidget {
  final Function(int index)? changeIndex;

  const AddPartyAddress({super.key, this.changeIndex});

  @override
  State<AddPartyAddress> createState() => _AddPartyAddressState();
}

class _AddPartyAddressState extends State<AddPartyAddress> {
  final GlobalKey<FormState> _formKeyAddComplain = GlobalKey<FormState>();

  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _partyCodeController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Party> partyNameList = [];

  List<DropdownMenuItem<Party>>? _dropdownPartyNameItems;

  Party? _selectedParty;
  String? currentAddress;

  bool isLoading = false;
  bool isAddressLoading = false;
  bool isInitial = false;

  Timer? _debounce;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _partyCodeController.dispose();
    _partyNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }


  init() async {

    await fetchPartyNameData();

    _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.isNotEmpty) {
        // fetchPartyDataByCode(query);
        Party? party = partyNameList.firstWhere((element) {
          return element.code!.toLowerCase() == query.toLowerCase();
        }, orElse: () {
          return Party.fromJson({});
        });

        if (party != null && party.code != null) {
          _selectedParty = party;
          _addressController.text = _selectedParty!.locationAddress!;
          setState(() {});
        } else {
          partyNameList.clear();
          _selectedParty = null;
          _dropdownPartyNameItems = null;
          currentAddress = null;
          _selectedParty = null;
          _addressController.clear();
          setState(() {});

          await fetchPartyNameData();
          _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
        }
      } else {
        partyNameList.clear();
        _selectedParty = null;
        _dropdownPartyNameItems = null;
        currentAddress = null;
        _selectedParty = null;
        _addressController.clear();
        setState(() {});

        await fetchPartyNameData();
        _dropdownPartyNameItems = buildDropdownPartyNameItems(partyNameList);
      }
    });
  }

   onSubmit() async {
    try {
      if(_selectedParty == null){
        AppGlobals.showMessage("Please select party", MessageType.error);
        return;
      }
      if(currentAddress == null){
        AppGlobals.showMessage("Please get address", MessageType.error);
        return;
      }

      setState(() {
        isLoading = true;
      });

      var response = await CustomerRepository().updatePartyAddress(
        id: _selectedParty!.id,
        address: currentAddress
      );

      if (!response.success) {
        isLoading = false;
        AppGlobals.showMessage(response.message, MessageType.error);
        setState(() {});
        return;
      }

      if (response.success) {
        // complainStatusList = response.data!;
        AppGlobals.showMessage(response.message, MessageType.success);
        isLoading = false;
        if (mounted) {
          _selectedParty = null;
          _partyCodeController.clear();
          currentAddress = null;
          // widget.changeIndex!.call(1);
        }
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  fetchPartyNameData() async {
    try {
      var response = await ComplainRepository().getAllPartyResponse();

      if (response.success) {
        List<Party> list = response.data;
        list.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        partyNameList = list;
        setState(() {});
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        // isParty = false;
      });
    } finally {
      setState(() {
        // isParty = false;
      });
    }
  }

   _getCurrentLocation() async {
     bool result = await LocationHelper.handleLocationPermission(context);
     if(!result) return;

     setState(() {
       isAddressLoading = true;
     });

    Position? currentPosition = await LocationHelper.getCurrentPosition(context);
    if(currentPosition != null) {
      currentAddress = await LocationHelper.getAddressFromLatLng(currentPosition!);
      _addressController.text = currentAddress!;
      if(_selectedParty != null && _selectedParty!.locationAddress!.isEmpty){
        _selectedParty!.locationAddress = currentAddress!;
      }
      isAddressLoading = false;
    } else {
      AppGlobals.showMessage("Please allow location permission", MessageType.error);
      isAddressLoading = false;
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimen.padding),
          child: _buildComplainForm(context),
        ),
      ),
    );
  }

  Column _buildComplainForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextFormField(
          controller: _partyCodeController,
          decoration: const InputDecoration(
            labelText: AppString.code,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          inputFormatters: [LengthLimitingTextInputFormatter(10)],
          maxLines: 1,
          onChanged: _onSearchChanged,
          validator: (value) {
            bool isValid = Validations.validateInput(value, true);

            if (isValid == false) {
              return AppString.enterCode;
            }
            return null;
          },
        ),
        const FieldSpace(),
        DropdownButtonFormField2(
          value: _selectedParty,
          items: _dropdownPartyNameItems,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: AppString.partyName,
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: MediaQuery.of(context).size.height * 0.64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimen.textRadius),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding, vertical: 0),
          ),
          onChanged: (value) {
            setState(() {
              _selectedParty = value;
              _partyCodeController.text = _selectedParty!.code!;
            });
          },
          validator: (value) {
            if (value == null) {
              return AppString.selectPartyName;
            }
            return null;
          },
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              _partyNameController.clear();
            }
          },
          dropdownSearchData: DropdownSearchData(
            searchController: _partyNameController,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 60,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: _partyNameController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimen.padding,
                    vertical: AppDimen.paddingSmall,
                  ),
                  hintText: AppString.partyName,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (DropdownMenuItem<Party>? item, searchValue) {
              return item!.value!.name!.toLowerCase().contains(searchValue);
            },
          ),
        ),
        if((_selectedParty == null && currentAddress == null) || (_selectedParty != null && _selectedParty!.locationAddress!.isEmpty))
        const FieldSpace(),
        if((_selectedParty == null && currentAddress == null) || (_selectedParty != null && _selectedParty!.locationAddress!.isEmpty))
        Stack(
          children: [
            PrimaryButton(
              onPressed: isAddressLoading ? null : _getCurrentLocation,
              text: "Get Address",
            ),
            if (isAddressLoading) ButtonLoader(
              width: MediaQuery.of(context).size.width * 0.34,
            ),
          ],
        ),
        const FieldSpace(),
        if(currentAddress != null)
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: AppString.address,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.multiline,
          maxLines: 2,
          readOnly: true,
          onChanged: _onSearchChanged,
          validator: (value) {
            bool isValid = Validations.validateInput(value, true);

            if (isValid == false) {
              return AppString.enterAddress;
            }
            return null;
          },
        ),
        if(currentAddress == null && (_selectedParty != null && _selectedParty!.locationAddress!.isNotEmpty))
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
                labelText: AppString.address,
                suffixIcon: GestureDetector(
                  onTap: () {
                    if(_selectedParty != null && _selectedParty!.locationAddress!.isNotEmpty){
                      _selectedParty!.locationAddress = "";
                      currentAddress = null;
                      setState(() {});
                    }
                  },
                  child: const Icon(
                      Icons.delete
                  ),
                )
            ),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            readOnly: true,
            onChanged: _onSearchChanged,
            validator: (value) {
              bool isValid = Validations.validateInput(value, true);

              if (isValid == false) {
                return AppString.enterAddress;
              }
              return null;
            },
          ),
        const FieldSpace(SpaceType.extraLarge),
        Stack(
          children: [
            Row(
              children: [
                /*(_selectedParty != null && _selectedParty!.locationAddress!.isNotEmpty)
                    ? Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppDimen.textRadius),
                    ),
                    child: const Text(
                      AppString.submit,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ) :*/ Expanded(
                  child: PrimaryButton(
                    onPressed: isLoading ? null : onSubmit,
                    text: AppString.submit,
                  ),
                ),
              ],
            ),
            if (isLoading) const ButtonLoader(),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<Party>> buildDropdownPartyNameItems(List<Party> machineDataList) {
    List<DropdownMenuItem<Party>> items = [];
    for (Party item in machineDataList as Iterable<Party>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!.toCapitalize(),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      );
    }
    return items;
  }
}
