import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../user/screens/OrderDetailScreen.dart';
import '../components/BodyCornerWidget.dart';
import '../models/NotificationModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';

class NotificationScreen extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  bool mIsLastPage = false;
  List<NotificationData> notificationData = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          appStore.setLoading(true);

          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    print('call');
    getNotification(page: currentPage).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      mIsLastPage = value.notificationData!.length < currentPage;
      if (currentPage == 1) {
        notificationData.clear();
      }
      notificationData.addAll(value.notificationData!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.notifications),
      ),
      body: BodyCornerWidget(
        child: Observer(builder: (context) {
          return Stack(
            children: [
              notificationData.isNotEmpty
                  ? ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: notificationData.length,
                      itemBuilder: (_, index) {
                        NotificationData data = notificationData[index];
                        return Container(
                          padding: EdgeInsets.all(12),
                          color: data.readAt != null ? Colors.transparent : Colors.grey.withOpacity(0.2),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorPrimary.withOpacity(0.15),
                                ),
                                child: ImageIcon(AssetImage(statusTypeIcon(type: data.data!.type)), color: colorPrimary, size: 26),
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${data.data!.subject}', style: boldTextStyle()).expand(),
                                      8.width,
                                      Text(data.createdAt.validate(), style: secondaryTextStyle()),
                                    ],
                                  ),
                                  8.height,
                                  Text('${data.data!.message}', style: primaryTextStyle(size: 14)),
                                ],
                              ).expand(),
                            ],
                          ).onTap(() async {
                            bool? res = await OrderDetailScreen(orderId: data.data!.id.validate()).launch(context);
                            if (res!) {
                              currentPage = 1;
                              init();
                            }
                          }),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                    )
                  : !appStore.isLoading
                      ? emptyWidget()
                      : SizedBox(),
              loaderWidget().center().visible(appStore.isLoading)
            ],
          );
        }),
      ),
    );
  }
}
