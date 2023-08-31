import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../components/AddUserDialog.dart';
import '../main.dart';
import '../models/models.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';
import 'CreateOrderScreen.dart';
import 'NotificationScreen.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/AppDashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<MenuItemModel> menuList = getAppDashboardItems();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? currencyCodeDefault);
      appStore.setCurrencySymbol(value.currency ?? currencySymbolDefault);
      appStore.setCurrencyPosition(
          value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isShowVehicle = value.isVehicleInOrder ?? 0;

      log('********************${appStore.isShowVehicle}');
    }).catchError((error) {
      log(error.toString());
    });
    LiveStream().on('UpdateLanguage', (p0) {
      menuList.clear();
      menuList = getAppDashboardItems();
      setState(() {});
    });
  }

  String getTitle() {
    String title = language.dashboard;
    if (currentIndex == 0) {
      title = language.dashboard;
    } else if (currentIndex == 1) {
      title = language.allOrder;
    } else if (currentIndex == 2) {
      title = language.users;
    } else if (currentIndex == 3) {
      title = language.deliveryPerson;
    } else if (currentIndex == 4) {
      title = language.setting;
    }
    return title;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: Text(getTitle()), actions: [
          Observer(
            builder: (_) => SizedBox(
              width: 55,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NotificationScreen()));
                        },
                        child: Icon(Icons.notifications)),
                  ),
                  if (appStore.allUnreadCount != 0)
                    Positioned(
                      right: 10,
                      top: 8,
                      child: Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange, shape: BoxShape.circle),
                        child: Observer(builder: (_) {
                          return Text(
                              '${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}',
                              style: primaryTextStyle(
                                  size: appStore.allUnreadCount > 99 ? 9 : 12,
                                  color: Colors.white));
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]),
        body: menuList[currentIndex].widget,
        //floatingActionButton: currentIndex == 1
        floatingActionButton: (currentIndex == ORDER_INDEX ||
                currentIndex == USER_INDEX ||
                currentIndex == DELIVERY_PERSON_INDEX)
            ? FloatingActionButton(
                backgroundColor: primaryColor,
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  if (currentIndex == ORDER_INDEX) {
                    launchScreen(context, CreateOrderScreen());
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // false = user must tap button, true = tap outside dialog
                      builder: (BuildContext dialogContext) {
                        return AddUserDialog(
                          userType:
                              currentIndex == USER_INDEX ? CLIENT : DELIVERYMAN,
                          onUpdate: () {
                            getAllUserList();
                          },
                        );
                      },
                    );
                  }
                },
              )
            : SizedBox(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor:
              appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          elevation: 5,
          selectedIconTheme: IconThemeData(size: 18),
          selectedItemColor: Colors.white,
          iconSize: 18,
          unselectedItemColor: Colors.grey.withOpacity(0.6),
          showSelectedLabels: false,
          items: menuList.map((item) {
            return BottomNavigationBarItem(
                icon: Icon(item.icon!),
                activeIcon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: primaryColor, borderRadius: radius(12)),
                    child: Icon(item.icon!)),
                label: item.title);
          }).toList(),
          onTap: (index) {
            currentIndex = index;
            setState(() {});
          },
        ),
      );
    });
  }
}
