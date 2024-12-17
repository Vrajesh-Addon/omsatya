import 'package:flutter/services.dart';
import 'package:validators/validators.dart';

class Validations {
  static bool validateInput(String? input, bool isRequired,
      [ValidationType validationtype = ValidationType.none]) {
    if (input == null || input == "") {
      if (isRequired) {
        return false;
      } else {
        return true;
      }
    }

    switch (validationtype) {
      case ValidationType.none:
        return true;
      case ValidationType.numericOnlyPositive:
        int? number = int.tryParse(input);
        if (number == null || number < 0) {
          return false;
        }
        break;
      case ValidationType.decimalOnlyPositive:
        double? number = double.tryParse(input);
        if (number == null || number < 0) {
          return false;
        }
        break;
      case ValidationType.numeric:
        return isInt(input);
      case ValidationType.decimal:
        return isFloat(input);
      case ValidationType.dateTime:
        DateTime? dateTime = DateTime.tryParse(input);
        if (dateTime == null) {
          return false;
        }
        break;
      case ValidationType.email:
        return isEmail(input);
      case ValidationType.url:
        return isURL(input);
      case ValidationType.percentage:
        double? number = double.tryParse(input);
        if (number == null || number < 0 || number > 100) {
          return false;
        }
        break;
      case ValidationType.phone:
        return matches(input, "^\\d{10,15}");
      case ValidationType.alphabetsOnly:
        return isAlpha(input);
      case ValidationType.alphaNumericOnly:
        return isAlphanumeric(input);
      case ValidationType.alphabetsOnlyWithSpace:
        return matches(input, "^[a-zA-Z ]*");
      case ValidationType.creditCard:
        return isCreditCard(input);
      case ValidationType.domain:
        return isFQDN(input);
      case ValidationType.hexColor:
        return isHexColor(input);
      case ValidationType.ipAddress:
        return isIP(input);
    }

    return true;
  }
}

enum ValidationType {
  none,
  numericOnlyPositive,
  decimalOnlyPositive,
  numeric,
  decimal,
  dateTime,
  email,
  url,
  percentage,
  phone,
  creditCard,
  domain,
  hexColor,
  ipAddress,
  alphabetsOnly,
  alphaNumericOnly,
  alphabetsOnlyWithSpace,
}

class PasswordInputFormatter extends FilteringTextInputFormatter {
  PasswordInputFormatter()
      : super.allow(RegExp(r'[a-zA-Z0-9@#$%^&+=.]'));

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // You can customize the formatting logic here if needed.
    return super.formatEditUpdate(oldValue, newValue);
  }
}


class PhoneInputFormatter extends FilteringTextInputFormatter {
  
  PhoneInputFormatter() : super.allow(RegExp(r'[0-9]'));

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // You can customize the formatting logic here if needed.
    return super.formatEditUpdate(oldValue, newValue);
  }
}

class NameInputFormatter extends FilteringTextInputFormatter {

  NameInputFormatter() : super.allow(RegExp(r'[A-Za-z ]'));

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // You can customize the formatting logic here if needed.
    return super.formatEditUpdate(oldValue, newValue);
  }
}
