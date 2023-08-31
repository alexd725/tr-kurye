import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../models/LanguageDataModel.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';

class LanguageScreen extends StatefulWidget {
  static String tag = '/AppLanguageScreen';

  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.language)),
      body: ListView(
        children: List.generate(localeLanguageList.length, (index) {
          LanguageDataModel data = localeLanguageList[index];
          return GestureDetector(
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Row(
                children: [
                  Image.asset(data.flag.validate(), width: 34),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.name.validate()}', style: boldTextStyle()),
                        SizedBox(height: 8),
                        Text('${data.subTitle.validate()}', style: secondaryTextStyle()),
                      ],
                    ),
                  ),
                  if ((sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? default_Language) == data.languageCode) Icon(Icons.check_circle, color: primaryColor),
                ],
              ),
            ),
            onTap: ()async{
              await sharedPref.setString(SELECTED_LANGUAGE_CODE, data.languageCode ?? default_Language);
              selectedLanguageDataModel = data;
              appStore.setLanguage(data.languageCode!, context: context);
              setState(() {});
              LiveStream().emit('UpdateLanguage');
              Navigator.pop(context);
            },
          );
        }),
      ),
    );
  }
}
