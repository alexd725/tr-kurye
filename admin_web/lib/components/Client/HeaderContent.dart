import 'package:flutter/material.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/context_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/int_extensions.dart';

import '../../main.dart';
import '../../screens/Client/DashboardScreen.dart';
import '../../screens/Client/SendPackageFragment.dart';
import 'SignInComponent.dart';
import 'UserCitySelectComponent.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class HeaderContent extends StatefulWidget {

  @override
  _HeaderContentState createState() => _HeaderContentState();
}

class _HeaderContentState extends State<HeaderContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        mHeading(builderResponse.appName.validate()),
        20.height,
        Text(
          '${builderResponse.createOrderDescription.validate()}',
          style: secondaryTextStyle(weight: FontWeight.w500, wordSpacing: 0.5, size: 16),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.justify,
        ),
        40.height,
        SizedBox(
          width: !ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.13 : context.width(),
          child: appButton(context, title: language.crete_order.toUpperCase(), onCall: () async {
            if (appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT) {
              if (getIntAsync(CITY_ID) != 0 && getIntAsync(COUNTRY_ID) != 0) {
                Navigator.of(context).pushNamed(SendPackageFragment.route);
              } else {
                await showDialog(
                    context: getContext,
                    builder: (_) {
                      return UserCitySelectScreen(
                        onUpdate: () {
                          Navigator.pushNamedAndRemoveUntil(getContext, DashboardScreen.route, (route) {
                            return true;
                          });
                        },
                      );
                    });
              }
            } else {
              showDialog(
                  context: context,
                  builder: (_) {
                    return SignInComponent();
                  });
            }
          }),
        ),
      ],
    );
  }
}
