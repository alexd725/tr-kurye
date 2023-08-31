import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main.dart';
import '../../utils/Extensions/bool_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/scroll_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../components/Client/DashboardComponent/DashboardBody/DownloadComponent.dart';
import '../../components/Client/DashboardComponent/DashboardBody/HeaderComponent.dart';
import '../../components/Client/DashboardComponent/DashboardBody/ReviewComponent.dart';
import '../../components/Client/DashboardComponent/DashboardBody/WhyDeliveryComponent.dart';
import '../../components/Client/DashboardComponent/DashboardFooterComponent.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../network/ClientRestApi.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';

class DashboardScreen extends StatefulWidget {
  static const String route = '/';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  ScrollController scrollController = ScrollController();
  bool isScroll = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    firebaseOnMessage();
    if (appStore.isLoggedIn) {
      await getClientDashboard().then((value) {
        clientStore.availableBal = value.totalAmount ?? 0;
        if (value.appSetting != null) {
          appStore.setCurrencyCode(value.appSetting!.currencyCode ?? defaultCurrencyCode);
          appStore.setCurrencySymbol(value.appSetting!.currency ?? defaultCurrencySymbol);
          appStore.setCurrencyPosition(value.appSetting!.currencyPosition ?? CURRENCY_POSITION_LEFT);
        }
        appStore.setAllUnreadCount(value.allUnreadCount.validate());
      }).catchError((error) {
        log(error.toString());
      });
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        isScroll = true;
        setState(() {});
      }
    });
  }

  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((event) async {
      ElegantNotification.info(
        title: Text(event.notification!.title.validate(), style: boldTextStyle(color: primaryColor, size: 18)),
        description: Text(event.notification!.body.validate(), style: primaryTextStyle(color: Colors.black, size: 16)),
        notificationPosition: NotificationPosition.topCenter,
        autoDismiss: true,
        animation: AnimationType.fromTop,
        showProgressIndicator: false,
        width: 400,
        height: 100,
        toastDuration: Duration(seconds: 10),
        iconSize: 0,
      ).show(context);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              HeaderWidget(isDashboard: true),
              SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    HeaderComponent(),
                    // SelectionComponent(),
                    WhyDeliveryComponent(),
                    ReviewComponent(),
                    70.height,
                    DownloadComponent(),
                    70.height,
                    DashboardFooterComponent(),
                  ],
                ),
              ).expand(),
            ],
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      floatingActionButton: Container(
        decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.white, borderRadius: radius(40)),
        child: IconButton(
            icon: Icon(Icons.arrow_upward, color: primaryColor),
            onPressed: () {
              scrollController.animToTop();
              isScroll = false;
              setState(() {});
            }),
      ).visible(isScroll.validate()),
    );
  }
}
