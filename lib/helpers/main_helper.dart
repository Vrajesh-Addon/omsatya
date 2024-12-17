import 'package:omsatya/helpers/shared_value_helper.dart';

Map<String,String> get commonHeader =>  {
  "Content-Type": "application/json",
  "Accept": "application/json",
};

Map<String,String> get acceptHeader =>  {
  "Accept": "application/json",
};

Map<String,String> get authHeader => {
  "Authorization": "Bearer ${accessToken.$}"
};