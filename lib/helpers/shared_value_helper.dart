import 'package:omsatya/utils/shared_value/shared_value.dart';

final SharedValue<String?> email = SharedValue(
  value: "", // initial value
  key: "email", // disk storage key for shared_preferences
);

final SharedValue<String?> phoneNo = SharedValue(
  value: "", // initial value
  key: "phoneNO", // disk storage key for shared_preferences
);

final SharedValue<String?> password = SharedValue(
  value: "", // initial value
  key: "password", // disk storage key for shared_preferences
);

final SharedValue<String?> accessToken = SharedValue(
  value: "", // initial value
  key: "accessToken", // disk storage key for shared_preferences
);

final SharedValue<String?> user = SharedValue(
  value: "", // initial value
  key: "user", // disk storage key for shared_preferences
);

final SharedValue<String?> firebaseAccessToken = SharedValue(
  value: "", // initial value
  key: "firebaseAccessToken", // disk storage key for shared_preferences
);

final SharedValue<int?> appBadgeCount = SharedValue(
  value: 0, // initial value
  key: "appBadgeCount", // disk storage key for shared_preferences
);


Future<void> getSharedValueHelperData() async {
  await accessToken.load();
  await email.load();
  await phoneNo.load();
  await password.load();
  await user.load();
  await firebaseAccessToken.load();
  await appBadgeCount.load();
}