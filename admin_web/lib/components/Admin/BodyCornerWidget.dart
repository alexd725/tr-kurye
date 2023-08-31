import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '/../network/RestApis.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../utils/Extensions/string_extensions.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/widget_extensions.dart';
import '/../main.dart';
import '/../models/models.dart';
import '/../screens/Client/DashboardScreen.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/DataProvider.dart';
import '/../utils/Extensions/live_stream.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/on_hover.dart';
import '/../utils/Extensions/text_styles.dart';
import '/../utils/Images.dart';
import 'ChangePasswordDialog.dart';
import 'EditProfileDialog.dart';
import 'LanguageListWidget.dart';
import 'NotificationDialog.dart';

class BodyCornerWidget extends StatefulWidget {
  final Widget? child;

  BodyCornerWidget({this.child});

  @override
  BodyCornerWidgetState createState() => BodyCornerWidgetState();
}

class BodyCornerWidgetState extends State<BodyCornerWidget> {
  List<MenuItemModel> menuList = getMenuItems();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    LiveStream().on(streamLanguage, (p0) {
      menuList.clear();
      menuList = getMenuItems();
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          leadingWidth: MediaQuery.of(context).size.width,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  appStore.setExpandedMenu(!appStore.isMenuExpanded);
                },
                child: Row(
                  children: [
                    Image.asset(app_logo_white, height: 50, width: 50, fit: BoxFit.cover),
                    if (!ResponsiveWidget.isSmallScreen(context))
                      Text(language.app_name, style: boldTextStyle(color: Colors.white, size: 20)),                  ],
                ),
              ),

            ],
          ),
          actions: [
            PopupMenuButton(
              padding: EdgeInsets.zero,
              child: Observer(
                builder: (_) => SizedBox(
                  width: 35,
                  child: Stack(
                    children: [
                      Align(alignment: AlignmentDirectional.center, child: Icon(Icons.notifications)),
                      if (appStore.allUnreadCount != 0)
                        Positioned(
                          right: 2,
                          top: 8,
                          child: Container(
                            height: 18,
                            width: 18,
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: Observer(builder: (_) {
                              return Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}',
                                  style: primaryTextStyle(size: appStore.allUnreadCount > 99 ? 9 : 12, color: Colors.white));
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  child: Container(width: 500, child: NotificationDialog()),
                )
              ],
              tooltip: language.notification,
            ),
            SizedBox(width: 16),
            Tooltip(
              message: language.theme,
              child: FlutterSwitch(
                value: appStore.isDarkMode,
                width: 55,
                height: 30,
                toggleSize: 25,
                borderRadius: 30.0,
                padding: 4.0,
                activeIcon: ImageIcon(AssetImage(ic_moon), color: Colors.white, size: 30),
                inactiveIcon: ImageIcon(AssetImage(ic_sun), color: Colors.white, size: 30),
                activeColor: primaryColor,
                activeToggleColor: Colors.black,
                inactiveToggleColor: Colors.orangeAccent,
                inactiveColor: Colors.white,
                onToggle: (value) {
                  appStore.setDarkMode(value);
                  setValue(THEME_MODE_INDEX, value ? 1 : 0);
                  LiveStream().emit(streamDarkMode);
                },
              ),
            ),
            SizedBox(width: 16),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(defaultRadius)),
              child: LanguageListWidget(
                widgetType: WidgetType.DROPDOWN,
                onLanguageChange: (val) async {
                  appStore.setLanguage(val.languageCode ?? '-');
                  await setValue(SELECTED_LANGUAGE_CODE, val.languageCode ?? '');
                  LiveStream().emit(streamLanguage);
                  setState(() {});
                },
              ),
            ),
            PopupMenuButton(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.only(right: 16, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.15)),
                        shape: BoxShape.circle,
                        image: DecorationImage(image: NetworkImage('${appStore.userProfile}'), fit: BoxFit.cover),
                      ),
                    ),
                    if (!ResponsiveWidget.isSmallScreen(context))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${getStringAsync(NAME)}', style: boldTextStyle(color: Colors.white)),
                          Text(getStringAsync(USER_EMAIL), style: secondaryTextStyle(size: 14, color: Colors.white)),
                        ],
                      ),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: appStore.isDarkMode ? Colors.white : Colors.grey),
                      SizedBox(width: 8),
                      Text(language.editProfile),
                    ],
                  ),
                  textStyle: primaryTextStyle(),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: appStore.isDarkMode ? Colors.white : Colors.grey),
                      SizedBox(width: 8),
                      Text(language.changePassword),
                    ],
                  ),
                  textStyle: primaryTextStyle(),
                ),
                PopupMenuItem(
                  value: 3,
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
              onSelected: (value) {
                if (value == 1) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return EditProfileDialog();
                    },
                  );
                } else if (value == 2) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return ChangePasswordDialog();
                    },
                  );
                } else if (value == 3) {
                  logOutData(
                      context: context,
                      onAccept: () async {
                        await logout(context);
                      });
                }
              },
              tooltip: language.profile,
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: getMenuWidth(),
                child: Container(
                  color: appStore.isDarkMode ? scaffoldColorDark : primaryColor,
                  padding: EdgeInsets.only(top: 16),
                  width: getMenuWidth(),
                  child: Column(
                    children: [
                      HoverWidget(builder: (context, isHovering) {
                        return InkWell(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: appStore.selectedLanguage == 'ar' ? 16 : 0),
                            decoration: BoxDecoration(color: isHovering ? hoverColor : Colors.transparent),
                            child: Row(
                              children: [
                                Tooltip(child: Icon(Icons.arrow_back, size: 24, color: Colors.white), message: language.viewSite),
                                appStore.isMenuExpanded
                                    ? Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16),
                                          child: Text(
                                            language.viewSite,
                                            maxLines: 1,
                                            style: primaryTextStyle(color: Colors.white, size: 14),
                                          ),
                                        ),
                                      )
                                    : Spacer(),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, DashboardScreen.route);
                          },
                        );
                      }),
                      ListView(
                        children: menuList.map((item) {
                          return HoverWidget(builder: (context, isHovering) {
                            return InkWell(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: appStore.selectedLanguage == 'ar' ? 16 : 0),
                                decoration: BoxDecoration(
                                  color: appStore.selectedMenuIndex == item.index
                                      ? hoverColor
                                      : isHovering
                                          ? hoverColor
                                          : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Tooltip(child: ImageIcon(AssetImage(item.imagePath!), size: 24, color: Colors.white), message: item.title.validate()),
                                    appStore.isMenuExpanded
                                        ? Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 16),
                                              child: Text(
                                                item.title!,
                                                maxLines: 1,
                                                style: appStore.selectedMenuIndex == item.index ? boldTextStyle(color: Colors.white, size: 14) : primaryTextStyle(color: Colors.white, size: 14),
                                              ),
                                            ),
                                          )
                                        : Spacer(),
                                    appStore.selectedMenuIndex == item.index
                                        ? Card(
                                            margin: EdgeInsets.zero,
                                            color: Theme.of(context).cardColor,
                                            shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            child: SizedBox(width: 30, height: 30),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                              onTap: () {
                                if (appStore.selectedMenuIndex != item.index!) {
                                  appStore.setSelectedMenuIndex(item.index!);
                                  Navigator.pushNamed(context, item.route!);
                                }
                              },
                            );
                          });
                        }).toList(),
                      ).expand(),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: appStore.selectedLanguage == 'ar' ? 0 : getMenuWidth() - 15,
                right: appStore.selectedLanguage == 'ar' ? getMenuWidth() - 30 : 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: AlignmentDirectional.topStart,
                  width: getBodyWidth(context),
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: appStore.selectedLanguage == 'ar'
                        ? BorderRadius.only(topRight: Radius.circular(defaultRadius))
                        : BorderRadius.only(
                            topLeft: Radius.circular(defaultRadius),
                          ),
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
