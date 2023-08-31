import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../models/CityListModel.dart';
import '../../../../utils/Extensions/bool_extensions.dart';
import '../../../../utils/Extensions/context_extensions.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/string_extensions.dart';
import '../../../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../screens/Admin/AdminLoginScreen.dart';
import '../../screens/Client/DashboardScreen.dart';
import '../../screens/Client/DeliveryPartnerScreen.dart';
import '../../screens/Client/NotificationScreen.dart';
import '../../screens/Client/ProfileScreen.dart';
import '../../screens/Admin/AdminHomeScreen.dart';
import 'SignInComponent.dart';
import 'UserCitySelectComponent.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Images.dart';

class HeaderWidget extends StatefulWidget {
  final bool isPartner;
  final bool isDashboard;
  final bool isNotification;
  final bool isProfile;

  HeaderWidget({this.isPartner = false, this.isDashboard = false, this.isNotification = false, this.isProfile = false});

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mMenuItem(IconData icon, String value, Function onClick) {
    return InkWell(
      onTap: () {
        onClick();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          4.width,
          if (!ResponsiveWidget.isSmallScreen(context)) Text(value, style: primaryTextStyle(color: Colors.white, size: 14)).paddingTop(4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        width: context.width(),
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: mCommonPadding(context)),
        decoration: boxDecorationRoundedWithShadow(0, backgroundColor: primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                if (!widget.isDashboard.validate()) {
                  Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route, (route) {
                    return true;
                  });
                }
              },
              child: Row(
                children: [
                  Image.asset(ic_app_logo_color, height: 35, width: 35),
                  8.width,
                  if (!ResponsiveWidget.isSmallScreen(context)) Text(builderResponse.appName.validate(), style: boldTextStyle(color: Colors.white)),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Align(alignment: AlignmentDirectional.center, child: Icon(Icons.notifications, color: Colors.white)),
                    Observer(builder: (context) {
                      return Positioned(
                        right: 0,
                        top: 8,
                        child: Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}', style: primaryTextStyle(size: appStore.allUnreadCount > 99 ? 8 : 12, color: Colors.white)),
                        ),
                      ).visible(appStore.allUnreadCount != 0);
                    }),
                  ],
                )
                    .withWidth(30)
                    .onTap(() {
                      Navigator.pushNamed(context, NotificationScreen.route);
                    })
                    .paddingRight(8)
                    .visible((appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT && !widget.isNotification)),
                if (getJSONAsync(CITY_DATA).isNotEmpty && getStringAsync(USER_TYPE) == CLIENT)
                  mMenuItem(Icons.location_on, CityData.fromJson(getJSONAsync(CITY_DATA)).name.validate(), () async {
                    await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return UserCitySelectScreen(
                            isBack: true,
                            onUpdate: () {
                              setState(() {});
                            },
                          );
                        });
                  }),
                16.width,
                mMenuItem(Icons.person, language.admin, () {
                  if (appStore.isLoggedIn && (getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN)) {
                    Navigator.pushNamed(context, AdminHomeScreen.route);
                  } else {
                    Navigator.pushNamed(context, AdminLoginScreen.route);
                  }
                }),
                16.width,
                if (!widget.isPartner.validate())
                  mMenuItem(Icons.person_add, language.delivery_person, () {
                    Navigator.pushNamed(context, DeliveryPartnerScreen.route);
                  }),
                16.width,
                if ((appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT))
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                    enabled: !widget.isProfile,
                    child: Row(
                      children: [
                        commonCachedNetworkImage(appStore.userProfile, height: 40, width: 40, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(20),
                        if (!ResponsiveWidget.isSmallScreen(context)) 8.width,
                        if (!ResponsiveWidget.isSmallScreen(context))
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getStringAsync(NAME), style: boldTextStyle(color: Colors.white)),
                              4.height,
                              Text(getStringAsync(USER_EMAIL), style: secondaryTextStyle(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                      ],
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: appStore.isDarkMode ? Colors.white : Colors.grey),
                            SizedBox(width: 8),
                            Text(language.profile),
                          ],
                        ),
                        textStyle: primaryTextStyle(),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: appStore.isDarkMode ? Colors.white : Colors.grey),
                            SizedBox(width: 8),
                            Text(language.logout),
                          ],
                        ),
                        textStyle: primaryTextStyle(),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 1) {
                        if (getIntAsync(CITY_ID) != 0 && getIntAsync(COUNTRY_ID) != 0) {
                          Navigator.pushNamed(context, ProfileScreen.route);
                        } else {
                          await showDialog(
                              context: getContext,
                              barrierDismissible: false,
                              builder: (_) {
                                return UserCitySelectScreen(
                                  onUpdate: () {
                                    Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route, (route) {
                                      return true;
                                    });
                                  },
                                );
                              });
                        }
                      } else if (value == 2) {
                        logOutData(
                            context: context,
                            onAccept: () async {
                              await logout(context);
                            });
                      }
                    },
                    tooltip: language.profile,
                  ),
                if ((appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT)) 16.width,
                if (!(appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT))
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.white, borderRadius: radius(8)),
                    child: Text(language.signIn, style: boldTextStyle(size: 12)),
                  ).onTap(() {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return SignInComponent();
                        });
                  }),
              ],
            )
          ],
        ),
      );
    });
  }
}
