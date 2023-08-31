import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/Admin/LanguageListWidget.dart';
import '../../components/Client/EditProfileComponent.dart';
import '../../components/Client/FilterOrderComponent.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/live_stream.dart';
import '../../utils/Extensions/on_hover.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../utils/ResponsiveWidget.dart';

class ProfileScreen extends StatefulWidget {
  static const String route = '/profile';

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  List<ClientMenuItemModel> menuList = getClientMenuItems();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    LiveStream().on(streamLanguage, (p0) {
      menuList.clear();
      menuList = getClientMenuItems();
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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            HeaderWidget(isProfile: true),
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    color: primaryColor.withOpacity(0.08),
                    padding: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            commonCachedNetworkImage(appStore.userProfile, height: 50, width: 50, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(25),
                            8.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getStringAsync(NAME), style: boldTextStyle()),
                                4.height,
                                Text(getStringAsync(USER_EMAIL), style: secondaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ).expand()
                          ],
                        ).expand(),
                        16.width,
                        ResponsiveWidget.isSmallScreen(context)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          ImageIcon(AssetImage('assets/ic_filter.png'), size: 18, color: primaryColor),
                                          Observer(builder: (context) {
                                            return Positioned(
                                              right: 8,
                                              top: 0,
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                              ),
                                            ).visible(clientStore.isFiltering);
                                          }),
                                        ],
                                      ).withWidth(40).onTap(
                                        () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: FilterOrderComponent(),
                                              );
                                            },
                                          );
                                        },
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                      ).visible(clientStore.isCurrentIndex == ORDER_LIST_INDEX),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: radius(20)),
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
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: boxDecorationWithRoundedCorners(border: Border.all(color: primaryColor), backgroundColor: Colors.transparent, borderRadius: radius(20)),
                                        child: Text(language.editProfile, style: boldTextStyle(color: primaryColor, size: 14)),
                                      ).onTap(
                                        () {
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return EditProfileScreen();
                                              });
                                        },
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                      ),
                                      8.width,
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: boxDecorationWithRoundedCorners(border: Border.all(color: Colors.red), backgroundColor: Colors.transparent, borderRadius: radius(20)),
                                        child: Text(language.logout, style: boldTextStyle(color: redColor, size: 14)),
                                      ).onTap(
                                        () async {
                                          logOutData(
                                              context: context,
                                              onAccept: () async {
                                                await logout(context);
                                              });
                                        },
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      ImageIcon(AssetImage('assets/ic_filter.png'), size: 18, color: primaryColor),
                                      Observer(builder: (context) {
                                        return Positioned(
                                          right: 8,
                                          top: 0,
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                          ),
                                        ).visible(clientStore.isFiltering);
                                      }),
                                    ],
                                  ).withWidth(40).onTap(
                                    () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: FilterOrderComponent(),
                                          );
                                        },
                                      );
                                    },
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                  ).visible(clientStore.isCurrentIndex == ORDER_LIST_INDEX),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: radius(20)),
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
                                  8.width,
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: boxDecorationWithRoundedCorners(border: Border.all(color: primaryColor), backgroundColor: Colors.transparent, borderRadius: radius(20)),
                                    child: Text(language.editProfile, style: boldTextStyle(color: primaryColor, size: 14)),
                                  ).onTap(
                                    () {
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return EditProfileScreen();
                                          });
                                    },
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                  ),
                                  8.width,
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: boxDecorationWithRoundedCorners(border: Border.all(color: Colors.red), backgroundColor: Colors.transparent, borderRadius: radius(20)),
                                    child: Text(language.logout, style: boldTextStyle(color: redColor, size: 14)),
                                  ).onTap(
                                    () async {
                                      logOutData(
                                          context: context,
                                          onAccept: () async {
                                            await logout(context);
                                          });
                                    },
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                  )
                                ],
                              )
                      ],
                    ),
                  ),
                  Container(
                    height: context.height() - 100,
                    width: context.width(),
                    margin: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: ResponsiveWidget.isExtraSmallScreen(context) ? 110 : 210,
                              height: context.height() - 235,
                              decoration: boxDecorationWithRoundedCorners(backgroundColor: accentColor),
                              child: ListView(
                                children: menuList.map((item) {
                                  return HoverWidget(builder: (context, isHovering) {
                                    return InkWell(
                                      onTap: () {
                                        if (item.index == ABOUT_US_INDEX) {
                                          Navigator.of(context).pushNamed(item.widgetRoute!);
                                        } else {
                                          clientStore.isCurrentIndex = item.index!;
                                        }
                                        setState(() {});
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(8),
                                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                                        decoration: BoxDecoration(
                                          color: clientStore.isCurrentIndex == item.index
                                              ? primaryColor
                                              : isHovering
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: radius(8),
                                        ),
                                        child: Text(
                                          item.title!,
                                          maxLines: 1,
                                          style: clientStore.isCurrentIndex == item.index
                                              ? boldTextStyle(color: Colors.white, size: ResponsiveWidget.isExtraSmallScreen(context) ? 12 : 14)
                                              : primaryTextStyle(size: ResponsiveWidget.isExtraSmallScreen(context) ? 12 : 14),
                                        ),
                                      ),
                                    );
                                  });
                                }).toList(),
                              ),
                            ),
                            22.width,
                            Container(
                              height: context.height() - 235,
                              child: menuList[clientStore.isCurrentIndex].widget!,
                            ).expand()
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ).expand(),
          ],
        ),
      );
    });
  }
}
