import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/complain_response.dart';
import 'package:omsatya/models/customer_machine_response.dart';
import 'package:omsatya/models/customer_previous_complain_response.dart';
import 'package:omsatya/models/machine_expiry_response.dart';
import 'package:omsatya/models/party_details_by_code_response.dart';
import 'package:omsatya/models/party_update_response.dart';
import 'package:omsatya/repository/api_request.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class CustomerRepository{

  Future<CustomerMachineResponse> getCustomerMachineData(int partyId, String? mcNo, int page) async {
    String url;
    if(mcNo == null){
      url = "${AppConfig.baseUrl}/customer-machines/$partyId?page=$page";
    } else {
      url = "${AppConfig.baseUrl}/customer-machines/$partyId/$mcNo?page=$page";
    }
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return customerMachineResponseFromJson(response.body);
  }

  Future<PartyDetailsByCodeResponse> getPartyDetailsByPartyCode(String partyCode) async {
    String url = "${AppConfig.baseUrl}/party-detail-by-partycode/$partyCode";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return partyDetailsByCodeResponseFromJson(response.body);
  }

  Future<MachineExpiryResponse> getMachineExpiryReport({int? partyId}) async {
    String url = "${AppConfig.baseUrl}/machine-expiry/$partyId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return machineExpiryResponseFromJson(response.body);
  }

  Future<ComplainResponse> getCustomerComplain(int partyId, int statusId) async {
    String url = "${AppConfig.baseUrl}/customer-complaints/$partyId?status_id=$statusId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return complainResponseFromJson(response.body);
  }

  Future<CustomerPreviousComplainResponse> getCustomerPreviousComplain({int? partyId,int? machineSalesId}) async {
    String url = "${AppConfig.baseUrl}/previous-complaints-report/$partyId/$machineSalesId";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return customerPreviousComplainResponseFromJson(response.body);
  }

  Future<PartyUpdateResponse> updatePartyAddress({int? id, String? address}) async {
    var body = {
      "location_address": address,
      "_method": "PUT",
    };
    String url = "${AppConfig.baseUrl}/party/$id";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return partyUpdateResponseFromJson(response.body);
  }
}