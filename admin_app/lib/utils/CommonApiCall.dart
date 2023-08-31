import 'package:mightydelivery_admin_app/network/RestApis.dart';

import '../main.dart';
import 'Extensions/app_common.dart';

getAllCountryApiCall() async{
  await getCountryList().then((value) {
    appStore.countryList.clear();
    appStore.countryList.addAll(value.data!);
  }).catchError((error) {
    toast(error.toString());
  });
}
