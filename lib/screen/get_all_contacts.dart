import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:omsatya/helpers/shimmer_helper.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class GetAllContacts extends StatefulWidget {
  const GetAllContacts({super.key});

  @override
  State<GetAllContacts> createState() => _GetAllContactsState();
}

class _GetAllContactsState extends State<GetAllContacts> {
  final TextEditingController _txtPartyController = TextEditingController();
  List<Contact> _contacts = [];
  List<Contact> results = [];

  bool isInitial = false;
  Timer? _debounce;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _fetchContacts();
    },);
    super.initState();
  }

  Future _fetchContacts() async {
    setState(() {
      isInitial  = true;
    });
    final contacts = await FlutterContacts.getContacts();
    setState(() {
      isInitial  = false;
      _contacts = contacts;
      results = contacts;
    });
  }


  _searchContact(String name){
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      if(name.isEmpty) {
        results = _contacts;
      } else {
        results = _contacts.where((element) => element.displayName.toLowerCase().contains(name.toLowerCase())).toList();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.padding),
          child: Column(
            children: [
              TextFormField(
                controller: _txtPartyController,
                decoration: const InputDecoration(
                  labelText: AppString.partyName,
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                onChanged: (value) => _searchContact(value),
                validator: (value) {
                  bool isValid = Validations.validateInput(value, true, ValidationType.none);
                  if (!isValid) {
                    return AppString.enterPartyName;
                  }
                  return null;
                },
              ),
              const FieldSpace(SpaceType.small),
              Expanded(
                child: buildContactList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildContactList() {
    if (isInitial && _contacts.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ShimmerHelper().buildListShimmer(
          itemCount: 20,
          itemHeight: 60.0,
        ),
      );
    } else if (_contacts.isNotEmpty) {
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
          itemCount: results.length,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(results[index].displayName),
                leading: const Icon(Icons.person, color: AppColors.primary,),
                onTap: () async {
                  Contact? fullContact = await FlutterContacts.getContact(results[index].id);
                  showMessage("Selected contact Name ==> ${fullContact!.displayName}");
                  showMessage("Selected contact Number ==> ${fullContact.phones.first.number}");
                  Navigator.of(context).pop(fullContact);
                },
              ),
            );
          },
        ),
      );
    } else if (!isInitial && _contacts.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppString.noContactFound,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }
}
