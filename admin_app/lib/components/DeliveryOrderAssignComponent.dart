import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/OrderModel.dart';
import 'package:mightydelivery_admin_app/models/UserModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/Images.dart';
import '../utils/Common.dart';

class DeliveryOrderAssignComponent extends StatefulWidget {
  final int orderId;
  final OrderModel orderModel;
  final Function()? onUpdate;

  DeliveryOrderAssignComponent(
      {this.onUpdate, required this.orderId, required this.orderModel});

  @override
  DeliveryOrderAssignComponentState createState() =>
      DeliveryOrderAssignComponentState();
}

class DeliveryOrderAssignComponentState
    extends State<DeliveryOrderAssignComponent> {
  ScrollController controller = ScrollController();
  int currentPage = 1;
  int totalPage = 0;

  List<UserModel> deliveryList = [];

  @override
  void initState() {
    super.initState();
    init();
    controller.addListener(() {
      scrollHandler();
    });
  }

  void init() async {
    getDeliveryBoyApi();
  }

  Future<void> scrollHandler() async {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if (currentPage < totalPage) {
        currentPage++;
        setState(() {});
        getDeliveryBoyApi();
      }
    }
  }

  getDeliveryBoyApi() async {
    appStore.setLoading(true);
    await getAllDeliveryBoyList(
            type: DELIVERYMAN,
            countryId: widget.orderModel.countryId,
            cityID: widget.orderModel.cityId,
            page: currentPage)
        .then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        deliveryList.clear();
      }
      deliveryList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
      appStore.setLoading(false);
    });
  }

  orderAssignApi({required int orderId, required int deliveryBoyID}) async {
    Navigator.pop(context);
    Navigator.pop(context);
    appStore.setLoading(true);
    Map req = {
      "id": orderId,
      "type": ORDER_ASSIGNED,
      "delivery_man_id": deliveryBoyID,
      "status": ORDER_ASSIGNED,
    };
    await orderAssign(req).then((value) {
      appStore.setLoading(false);
      widget.onUpdate!.call();
      //Navigator.pop(context);
      //Navigator.pop(context);
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
    return Dialog(
      child: Container(
        decoration: BoxDecoration(borderRadius: radius(8)),
        height: MediaQuery.of(context).size.height / 1.5,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
                widget.orderModel.deliveryManId == null
                    ? language.assignOrder
                    : language.orderTransfer,
                style: boldTextStyle(color: Colors.white, size: 20)),
            actions: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.close))),
            ],
          ),
          body: Observer(
            builder: (_) {
              return Stack(
                children: [
                  deliveryList.isNotEmpty
                      ? ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider();
                          },
                          shrinkWrap: true,
                          controller: controller,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          itemCount: deliveryList.length,
                          itemBuilder: (C, i) {
                            UserModel data = deliveryList[i];
                            return Row(
                              children: [
                                data.profileImage != null
                                    ? ClipRRect(
                                        borderRadius: radius(25),
                                        child: commonCachedNetworkImage(
                                            data.profileImage,
                                            width: 50,
                                            height: 50))
                                    : Container(
                                        decoration: BoxDecoration(
                                            borderRadius: radius(20)),
                                        child: Image.asset(AppImg,
                                            height: 40, width: 40)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data.name.toString(),
                                          style: boldTextStyle()),
                                      SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () {
                                          launchUrl(Uri.parse(
                                              'tel:${data.contactNumber.validate()}'));
                                        },
                                        child: Text(
                                            data.contactNumber.validate(),
                                            style: secondaryTextStyle()),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 28,
                                  child: OutlinedButton(
                                    child: Text(
                                        widget.orderModel.deliveryManId == null
                                            ? language.assign
                                            : language.transfer,
                                        style: primaryTextStyle(
                                            color: primaryColor, size: 14)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: primaryColor),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    onPressed: () {
                                      if (sharedPref.getString(USER_TYPE) ==
                                          DEMO_ADMIN) {
                                        toast(language.demoAdminMsg);
                                      } else {
                                        commonConfirmationDialog(
                                            context,
                                            widget.orderModel.deliveryManId ==
                                                    null
                                                ? DIALOG_TYPE_ASSIGN
                                                : DIALOG_TYPE_TRANSFER,
                                            () async {
                                          if (sharedPref.getString(USER_TYPE) ==
                                              DEMO_ADMIN) {
                                            toast(language.demoAdminMsg);
                                          } else {
                                            await orderAssignApi(
                                                orderId: widget.orderId,
                                                deliveryBoyID: data.id!);
                                          }
                                        },
                                            title: language.areYouSure,
                                            subtitle: widget.orderModel
                                                        .deliveryManId ==
                                                    null
                                                ? "${language.assignOrderConfirmationMsg} ${data.name}?"
                                                : "${language.transferOrderConfirmationMsg} ${data.name}?");
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : !appStore.isLoading
                          ? emptyWidget()
                          : SizedBox(),
                  Visibility(
                    visible: appStore.isLoading,
                    child: loaderWidget(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
