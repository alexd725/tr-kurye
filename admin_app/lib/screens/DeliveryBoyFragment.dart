import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../components/AddUserDialog.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/UserModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/Common.dart';
import 'UserDetailScreen.dart';
import 'DeliveryPersonDocumentScreen.dart';

class DeliveryBoyFragment extends StatefulWidget {
  @override
  DeliveryBoyFragmentState createState() => DeliveryBoyFragmentState();
}

class DeliveryBoyFragmentState extends State<DeliveryBoyFragment> {
  ScrollController controller = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  int currentIndex = 1;
  List<UserModel> deliveryBoyList = [];

  @override
  void initState() {
    super.initState();
    init();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getDeliveryBoyListApiCall();
        }
      }
    });
  }

  void init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getDeliveryBoyListApiCall();
    });
  }

  getDeliveryBoyListApiCall() async {
    appStore.setLoading(true);
    await getAllUserList(type: DELIVERYMAN, page: currentPage).then((value) {
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        deliveryBoyList.clear();
      }
      deliveryBoyList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      log(error);
    });
    appStore.setLoading(false);
  }

  updateStatusApiCall(UserModel deliveryBoyData) async {
    Map req = {
      "id": deliveryBoyData.id,
      "status": deliveryBoyData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await updateUserStatus(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getDeliveryBoyListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteDeliveryBoyApiCall(int id) async {
    Map req = {"id": id};
    appStore.setLoading(true);
    await deleteUser(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getDeliveryBoyListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreDeliveryBoyApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await userAction(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getDeliveryBoyListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Stack(
        children: [
          ListView.builder(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              controller: controller,
              itemCount: deliveryBoyList.length,
              itemBuilder: (context, i) {
                UserModel mData = deliveryBoyList[i];
                return GestureDetector(
                  onTap: () async {
                    bool? res = await launchScreen(
                        context,
                        UserDetailScreen(
                            userId: mData.id, userType: mData.userType));
                    if (res ?? false) {
                      currentPage = 1;
                      getDeliveryBoyListApiCall();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: containerDecoration(),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text('#${mData.id ?? "-"}',
                                  style: boldTextStyle(color: primaryColor)),
                              Spacer(),
                              GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  margin: EdgeInsets.only(right: 8),
                                  child: Text(
                                    '${mData.status == 1 ? language.enable : language.disable}',
                                    style: primaryTextStyle(
                                        color: mData.status == 1
                                            ? primaryColor
                                            : Colors.red,
                                        size: 14),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: mData.status == 1
                                              ? primaryColor.withOpacity(0.6)
                                              : Colors.red.withOpacity(0.6)),
                                      color: mData.status == 1
                                          ? primaryColor.withOpacity(0.15)
                                          : Colors.red.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius)),
                                ),
                                onTap: () {
                                  mData.deletedAt == null
                                      ? commonConfirmationDialog(
                                          context,
                                          mData.status == 1
                                              ? DIALOG_TYPE_DISABLE
                                              : DIALOG_TYPE_ENABLE, () {
                                          if (sharedPref.getString(USER_TYPE) ==
                                              DEMO_ADMIN) {
                                            toast(language.demoAdminMsg);
                                          } else {
                                            Navigator.pop(context);
                                            updateStatusApiCall(mData);
                                          }
                                        },
                                          title: mData.status != 1
                                              ? language.enableDeliveryPerson
                                              : language.disableDeliveryPerson,
                                          subtitle: mData.status != 1
                                              ? language.enableDeliveryPersonMsg
                                              : language
                                                  .disableDeliveryPersonMsg)
                                      //title: mData.status != 1 ? language.enableDeliveryPerson : language.disableDeliveryPerson, subtitle: mData.status != 1 ? language.enableDeliveryPersonMsg : language.disableDeliveryPersonMsg)
                                      : toast(language
                                          .youCannotUpdateStatusRecordDeleted);
                                },
                              ),
                              //if (mData.deletedAt != null)
                              Row(
                                children: [
                                  outlineActionIcon(
                                      context,
                                      mData.deletedAt == null
                                          ? Icons.edit
                                          : Icons.restore,
                                      Colors.green, () {
                                    mData.deletedAt == null
                                        ? showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // false = user must tap button, true = tap outside dialog
                                            builder:
                                                (BuildContext dialogContext) {
                                              return AddUserDialog(
                                                userData: mData,
                                                userType: DELIVERYMAN,
                                                onUpdate: () {
                                                  currentPage = 1;

                                                  getDeliveryBoyListApiCall();
                                                },
                                              );
                                            },
                                          )
                                        : commonConfirmationDialog(
                                            context, DIALOG_TYPE_RESTORE, () {
                                            /*outlineActionIcon(context, Icons.restore, Colors.green, () {
                                    commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {*/
                                            if (sharedPref
                                                    .getString(USER_TYPE) ==
                                                DEMO_ADMIN) {
                                              toast(language.demoAdminMsg);
                                            } else {
                                              Navigator.pop(context);
                                              restoreDeliveryBoyApiCall(
                                                  id: mData.id, type: RESTORE);
                                            }
                                          },
                                            title:
                                                language.restoreDeliveryPerson,
                                            subtitle: language
                                                .restoreDeliveryPersonMsg);
                                  }),
                                  SizedBox(width: 8),
                                ],
                              ),
                              outlineActionIcon(
                                  context,
                                  mData.deletedAt == null
                                      ? Icons.delete
                                      : Icons.delete_forever,
                                  Colors.red, () {
                                commonConfirmationDialog(
                                    context, DIALOG_TYPE_DELETE, () {
                                  if (sharedPref.getString(USER_TYPE) ==
                                      DEMO_ADMIN) {
                                    toast(language.demoAdminMsg);
                                  } else {
                                    Navigator.pop(context);
                                    mData.deletedAt == null
                                        ? deleteDeliveryBoyApiCall(mData.id!)
                                        : restoreDeliveryBoyApiCall(
                                            id: mData.id, type: FORCE_DELETE);
                                  }
                                },
                                    isForceDelete: mData.deletedAt != null,
                                    title: language.deleteDeliveryPerson,
                                    subtitle: language.deleteDeliveryPersonMsg);
                              }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.15)),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              '${mData.profileImage!}'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${mData.name ?? ""}',
                                                style: boldTextStyle()),
                                            if (mData.deletedAt == null)
                                              Row(
                                                children: [
                                                  mData.isVerifiedDeliveryMan! ==
                                                          1
                                                      ? Text(language.verified,
                                                          style:
                                                              primaryTextStyle(
                                                                  color: Colors
                                                                      .green))
                                                      : SizedBox(
                                                          height: 30,
                                                          child: ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                bool res = await launchScreen(
                                                                    context,
                                                                    DeliveryPersonDocumentScreen(
                                                                        deliveryManId:
                                                                            mData.id!));
                                                                if (res) {
                                                                  currentPage =
                                                                      1;
                                                                  getDeliveryBoyListApiCall();
                                                                }
                                                              },
                                                              child: Text(
                                                                  language
                                                                      .verify))),
                                                  SizedBox(width: 8),
                                                  outlineActionIcon(
                                                      context,
                                                      Icons.location_on,
                                                      primaryColor, () {
                                                    if (mData.latitude !=
                                                            null &&
                                                        mData.longitude !=
                                                            null) {
                                                      MapsLauncher
                                                          .launchCoordinates(
                                                              double.parse(mData
                                                                  .latitude!),
                                                              double.parse(mData
                                                                  .longitude!));
                                                    } else {
                                                      toast(language
                                                          .locationNotExist);
                                                    }
                                                  }),
                                                ],
                                              ),
                                          ],
                                        ),
                                        Text(mData.email.validate(),
                                            style: secondaryTextStyle()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  launchUrl(
                                      Uri.parse('tel:${mData.contactNumber}'));
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.call,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Text(mData.contactNumber.validate(),
                                        style: primaryTextStyle(size: 14)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.numbers_sharp,
                                      color: primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(mData.id_no.validate(),
                                      style: primaryTextStyle(size: 14)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.car_crash,
                                      color: primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(mData.car_or_moto.validate(),
                                      style: primaryTextStyle(size: 14)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.abc,
                                      color: primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(mData.plate_number.validate(),
                                      style: primaryTextStyle(size: 14)),
                                ],
                              ),
                              SizedBox(height: 8),
                              if (mData.cityName != null ||
                                  mData.countryName != null)
                                Row(
                                  children: [
                                    Icon(Icons.location_city,
                                        color: primaryColor, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                        mData.cityName.validate() +
                                            " ," +
                                            mData.countryName.validate(),
                                        style: primaryTextStyle(size: 14)),
                                  ],
                                ),
                              if (mData.cityName != null ||
                                  mData.countryName != null)
                                SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Entypo.calendar,
                                      color: primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(printDate(mData.createdAt.validate()),
                                      style: primaryTextStyle(size: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          appStore.isLoading
              ? loaderWidget()
              : deliveryBoyList.isEmpty
                  ? emptyWidget()
                  : SizedBox()
        ],
      ),
    );
  }
}
