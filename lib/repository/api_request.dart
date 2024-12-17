import 'package:http/http.dart' as http;
import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class ApiRequest {


  static Future<http.Response> get({required String url, Map<String, String>? header}) async {
    Uri uri = Uri.parse(url);
    var response = await http.get(uri, headers: header);
    displayResponses(url: url, headerMap: header, response: response);
    return response;
  }

  static Future<http.Response> post({required String url, Map<String, String>? header, required dynamic body}) async {
    Uri uri = Uri.parse(url);
    var response = await http.post(uri, headers: header, body: body);
    displayResponses(url: url, headerMap: header, body: body, response: response);
    return response;
  }

  static Future<http.Response> delete({required String url, Map<String, String>? header}) async {
    Uri uri = Uri.parse(url);
    var response = await http.delete(uri, headers: header);
    displayResponses(url: url, headerMap: header, response: response);
    return response;
  }

  static displayResponses({url, headerMap, body, response}){
    showMessage("**********************************************************");
    showMessage("Api Url ==> $url");
    showMessage("Header ==> $headerMap");
    showMessage("Request ==> $body");
    showMessage("Response ==> ${response.body}");
    showMessage("**********************************************************");
  }

}
