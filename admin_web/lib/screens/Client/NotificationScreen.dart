import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../screens/Client/OrderDetailScreen.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../main.dart';
import '../../models/NotificationModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';

class NotificationScreen extends StatefulWidget {
  static const String route = '/notifications';

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
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
  }

  void init({Map? request}) async {
    appStore.setLoading(true);
    getNotification(page: currentPage,req: request).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.all_unread_count.validate());
      mIsLastPage = value.notification_data!.length < currentPage;
      if (currentPage == 1) {
        notificationData.clear();
      }
      notificationData.addAll(value.notification_data!);
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
      backgroundColor: Colors.white,
      body: Observer(builder: (context) {
        return Column(
          children: [
            HeaderWidget(isNotification: true),
            Container(
              margin: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: 16),
              decoration: boxDecorationWithRoundedCorners(border: Border.all(color: borderColor)),
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Observer(builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.notification, style: primaryTextStyle()),
                        if(appStore.allUnreadCount>0) Row(
                          children: [
                           Container(
                              margin:EdgeInsets.only(right:8),
                              padding:EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                              decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: primaryColor,
                              ),
                              child: Text('${appStore.allUnreadCount}',style: primaryTextStyle(color: Colors.white)),
                            ),
                            GestureDetector(
                              child: Text(language.markAllAsRead, style: primaryTextStyle(size: 14, color: primaryColor)),
                              onTap: () {
                                Map req = {
                                  "type": "markas_read",
                                };
                                currentPage = 1;
                                init(request: req);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    16.height,
                    Stack(
                      children: [
                        notificationData.isNotEmpty
                            ? ListView.separated(
                                shrinkWrap: true,
                                controller: scrollController,
                                padding: EdgeInsets.zero,
                                itemCount: notificationData.length,
                                itemBuilder: (_, index) {
                                  NotificationData data = notificationData[index];
                                  return InkWell(
                                    onTap: () async {
                                      var res = await Navigator.pushNamed(context, OrderDetailScreen.route + "?order_Id=${data.data!.id}");
                                      if (res != null) {
                                        currentPage = 1;
                                        init();
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      color: data.read_at != null ? Colors.transparent : Colors.grey.withOpacity(0.2),
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
                                                    Text(data.created_at.validate(), style: secondaryTextStyle()),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text('${data.data!.message}', style: primaryTextStyle(size: 14)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                        Visibility(visible: appStore.isLoading, child: loaderWidget()),
                      ],
                    ).expand(),
                  ],
                );
              }),
            ).expand(),
          ],
        );
      }),
    );
  }
}
