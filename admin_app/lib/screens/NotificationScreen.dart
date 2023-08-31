import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/NotificationModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../main.dart';
import 'OrderDetailScreen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  ScrollController controller = ScrollController();

  bool mIsLastPage = false;
  List<NotificationData> notificationData = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(init);
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
  }

  void init() async {
    appStore.setLoading(true);
    getNotification(page: currentPage).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount ?? 0);
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
      appBar: AppBar(title: Text(language.notification)),
      body: Observer(
        builder: (context) {
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
                          child: GestureDetector(
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor.withOpacity(0.15),
                                  ),
                                  child: ImageIcon(AssetImage(statusTypeIcon(type: data.data!.type)), color: primaryColor, size: 26),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: Text('${data.data!.subject}', style: boldTextStyle())),
                                          SizedBox(width: 8),
                                          Text(data.createdAt.validate(), style: secondaryTextStyle()),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('${data.data!.message}', style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              bool? res = await launchScreen(context, OrderDetailScreen(orderId: data.data!.id ?? 0));
                              if (res ?? false) {
                                currentPage = 1;
                                init();
                              }
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                    )
                  : !appStore.isLoading
                      ? emptyWidget()
                      : SizedBox(),
              Visibility(visible: appStore.isLoading,child: loaderWidget()),
            ],
          );
        }
      ),
    );
  }
}
