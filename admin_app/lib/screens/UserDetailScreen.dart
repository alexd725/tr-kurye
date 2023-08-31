import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../components/AddMoneyDialog.dart';
import '../main.dart';
import '../models/UserModel.dart';
import '../models/UserProfileDetailModel.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/StringExtensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/AddUserDialog.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import 'DeliveryPersonDocumentScreen.dart';

class UserDetailScreen extends StatefulWidget {
  final int? userId;
  final String? userType;

  UserDetailScreen({this.userId, this.userType});

  @override
  UserDetailScreenState createState() => UserDetailScreenState();
}

class UserDetailScreenState extends State<UserDetailScreen> {
  UserProfileDetailModel? userProfileData;
  UserModel? userData;
  WalletHistory? walletHistory;
  EarningDetail? earningDetail;
  EarningList? earningList;

  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getUserDetailApiCall();
  }

  getUserDetailApiCall() async {
    appStore.setLoading(true);
    await getUserProfile(widget.userId!).then((value) {
      appStore.setLoading(false);
      userProfileData = value;
      userData = value.data;
      walletHistory = value.walletHistory;
      earningDetail = value.earningDetail;
      earningList = value.earningList;
      setState(() {});
    }).catchError((e) {
      log(e.toString());
      appStore.setLoading(false);
    });
  }

  updateStatusApiCall() async {
    Map req = {
      "id": userData!.id,
      "status": userData!.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await updateUserStatus(req).then((value) {
      appStore.setLoading(false);
      getUserDetailApiCall();
      isUpdated = true;
      setState(() {});
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteDeliveryBoyApiCall() async {
    Map req = {"id": userData!.id};
    appStore.setLoading(true);
    await deleteUser(req).then((value) {
      appStore.setLoading(false);
      getUserDetailApiCall();
      isUpdated = true;
      setState(() {});
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreDeliveryBoyApiCall({@required String? type}) async {
    Map req = {"id": userData!.id, "type": type};
    appStore.setLoading(true);
    await userAction(req).then((value) {
      appStore.setLoading(false);
      getUserDetailApiCall();
      isUpdated = true;
      setState(() {});
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  getWalletListApi(int currentPage) async {
    appStore.setLoading(true);
    await getWalletList(page: currentPage, userId: userData!.id).then((value) {
      appStore.setLoading(false);
      walletHistory = value;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      log(e);
    });
  }

  getPaymentListApi(int currentPage) async {
    appStore.setLoading(true);
    await getPaymentList(page: currentPage, userId: userData!.id).then((value) {
      appStore.setLoading(false);
      earningList = value;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      log(e);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, isUpdated);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.userType == CLIENT ? language.viewUser : language.viewDeliveryPerson)),
        body: Observer(builder: (context) {
          return Stack(
            children: [
              if (userProfileData != null)
                SingleChildScrollView(
                  // padding: EdgeInsets.all(16),
                  child: Column(
                    children: [

                      // SizedBox(height:8),
                      if (userData != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: containerDecoration(),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0)),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Text('#${userData?.id ?? "-"}', style: boldTextStyle(color: primaryColor)),
                                    Spacer(),
                                    // GestureDetector(
                                    //   child: Container(
                                    //     alignment: Alignment.center,
                                    //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    //     margin: EdgeInsets.only(right: 8),
                                    //     child: Text(
                                    //       '${userData!.status == 1 ? language.enable : language.disable}',
                                    //       style: primaryTextStyle(color: userData!.status == 1 ? primaryColor : Colors.red, size: 14),
                                    //     ),
                                    //     decoration: BoxDecoration(
                                    //         border: Border.all(color: userData!.status == 1 ? primaryColor.withOpacity(0.6) : Colors.red.withOpacity(0.6)),
                                    //         color: userData!.status == 1 ? primaryColor.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                    //         borderRadius: BorderRadius.circular(defaultRadius)),
                                    //   ),
                                    //   onTap: () {
                                    //     userData!.deletedAt == null
                                    //         ? commonConfirmationDialog(context, userData!.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                    //             if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                    //               toast(language.demoAdminMsg);
                                    //             } else {
                                    //               Navigator.pop(context);
                                    //               updateStatusApiCall();
                                    //             }
                                    //           },
                                    //             title: userData!.status != 1 ? language.enableDeliveryPerson : language.disableDeliveryPerson,
                                    //             subtitle: userData!.status != 1 ? language.enableDeliveryPersonMsg : language.disableDeliveryPersonMsg)
                                    //         : toast(language.youCannotUpdateStatusRecordDeleted);
                                    //   },
                                    // ),
                                    Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: ElevatedButton(onPressed: (){
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AddMoneyDialog(userId: userData?.id,onUpdate: (){
                                                  getUserDetailApiCall();
                                                });
                                              },
                                            );
                                          }, child: Text('Add Money')),
                                        ),
                                        SizedBox(width: 8),
                                        outlineActionIcon(context, userData!.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, () {
                                          userData!.deletedAt == null
                                              ? showDialog(
                                                  context: context,
                                                  barrierDismissible: false, // false = user must tap button, true = tap outside dialog
                                                  builder: (BuildContext dialogContext) {
                                                    return AddUserDialog(
                                                      userData: userData!,
                                                      userType: DELIVERYMAN,
                                                      onUpdate: () {
                                                        isUpdated = true;
                                                        getUserDetailApiCall();
                                                        setState(() {});
                                                      },
                                                    );
                                                  },
                                                )
                                              : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                                  if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                                    toast(language.demoAdminMsg);
                                                  } else {
                                                    Navigator.pop(context);
                                                    restoreDeliveryBoyApiCall(type: RESTORE);
                                                  }
                                                }, title: language.restoreDeliveryPerson, subtitle: language.restoreDeliveryPersonMsg);
                                        }),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                    outlineActionIcon(context, userData!.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, () {
                                      commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                        if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                          toast(language.demoAdminMsg);
                                        } else {
                                          Navigator.pop(context);
                                          userData!.deletedAt == null ? deleteDeliveryBoyApiCall() : restoreDeliveryBoyApiCall(type: FORCE_DELETE);
                                        }
                                      }, isForceDelete: userData!.deletedAt != null, title: language.deleteDeliveryPerson, subtitle: language.deleteDeliveryPersonMsg);
                                    }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 60,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage('${userData!.profileImage!}')
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text('${userData!.name ?? ""}', style: boldTextStyle()),
                                    SizedBox(height: 4),
                                    Row(
                                        children : <Widget>[
                                          Expanded(

                                            child:  Padding(
                                              padding: EdgeInsets.only(left: 50,right: 0,top: 8,bottom: 0),
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  margin: EdgeInsets.only(right: 8),
                                                  child: Text(
                                                    '${userData!.status == 1 ? language.enable : language.disable}',
                                                    style: primaryTextStyle(color: userData!.status == 1 ? primaryColor : Colors.red, size: 14),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: userData!.status == 1 ? primaryColor.withOpacity(0.6) : Colors.red.withOpacity(0.6)),
                                                      color: userData!.status == 1 ? primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(defaultRadius)),
                                                ),
                                                onTap: () {
                                                  userData!.deletedAt == null
                                                      ? commonConfirmationDialog(context, userData!.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                                    if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                                      toast(language.demoAdminMsg);
                                                    } else {
                                                      Navigator.pop(context);
                                                      updateStatusApiCall();
                                                    }
                                                  },
                                                      title: userData!.status != 1 ? language.enableDeliveryPerson : language.disableDeliveryPerson,
                                                      subtitle: userData!.status != 1 ? language.enableDeliveryPersonMsg : language.disableDeliveryPersonMsg)
                                                      : toast(language.youCannotUpdateStatusRecordDeleted);
                                                },
                                              ),
                                            )

                                          ),
                                          SizedBox(height: 4),
                                          Expanded(
                                                  child: Padding(
                                                    padding:  EdgeInsets.only(left: 0,right: 50,top: 8,bottom: 0),

                                                    child: GestureDetector(
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        margin: EdgeInsets.only(right: 8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            if (widget.userType == DELIVERYMAN && userData!.deletedAt == null)
                                                            Row(

                                                                children: [
                                                                  userData!.isVerifiedDeliveryMan! == 1
                                                                      ? Text(language.verified, style: primaryTextStyle(color: Colors.white))
                                                                      : SizedBox(
                                                                      height: 30,
                                                                      child: ElevatedButton(
                                                                          onPressed: () async {
                                                                            bool res = await launchScreen(context, DeliveryPersonDocumentScreen(deliveryManId: userData!.id!));
                                                                            if (res) {
                                                                              isUpdated = true;
                                                                              getUserDetailApiCall();
                                                                              setState(() {});
                                                                            }
                                                                          },
                                                                          child: Text(language.verify))),
                                                                  SizedBox(width: 8),
                                                                ],

                                                            )

                                                          ],
                                                        ),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(color:  primaryColor),
                                                            color: primaryColor,
                                                            borderRadius: BorderRadius.circular(defaultRadius)),
                                                      ),
                                                      onTap: () {
                                                        if (userData!.latitude != null && userData!.longitude != null) {
                                                          MapsLauncher.launchCoordinates(double.parse(userData!.latitude!), double.parse(userData!.longitude!));
                                                        } else {
                                                          toast(language.locationNotExist);
                                                        }
                                                      },
                                                    ),
                                                  ),


                                          ),
                                          
                                        ]),


                                    //SizedBox(height: 20),
                                    // Row(
                                    //   children: [
                                    //     Container(
                                    //       height: 60,
                                    //       width: 60,
                                    //       decoration: BoxDecoration(
                                    //         border: Border.all(color: Colors.grey.withOpacity(0.15)),
                                    //         shape: BoxShape.circle,
                                    //         image: DecorationImage(image: NetworkImage('${userData!.profileImage!}'), fit: BoxFit.cover),
                                    //       ),
                                    //     ),
                                    //     SizedBox(width: 8),
                                    //     Expanded(
                                    //       child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.start,
                                    //         children: [
                                    //           Row(
                                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //             children: [
                                    //               Text('${userData!.name ?? ""}', style: boldTextStyle()),
                                    //               if (widget.userType == DELIVERYMAN && userData!.deletedAt == null)
                                    //                 Row(
                                    //                   children: [
                                    //                     userData!.isVerifiedDeliveryMan! == 1
                                    //                         ? Text(language.verified, style: primaryTextStyle(color: Colors.green))
                                    //                         : SizedBox(
                                    //                             height: 30,
                                    //                             child: ElevatedButton(
                                    //                                 onPressed: () async {
                                    //                                   bool res = await launchScreen(context, DeliveryPersonDocumentScreen(deliveryManId: userData!.id!));
                                    //                                   if (res) {
                                    //                                     isUpdated = true;
                                    //                                     getUserDetailApiCall();
                                    //                                     setState(() {});
                                    //                                   }
                                    //                                 },
                                    //                                 child: Text(language.verify))),
                                    //                     SizedBox(width: 8),
                                    //                     outlineActionIcon(context, Icons.location_on, primaryColor, () {
                                    //                       if (userData!.latitude != null && userData!.longitude != null) {
                                    //                         MapsLauncher.launchCoordinates(double.parse(userData!.latitude!), double.parse(userData!.longitude!));
                                    //                       } else {
                                    //                         toast(language.locationNotExist);
                                    //                       }
                                    //                     }),
                                    //                   ],
                                    //                 ),
                                    //             ],
                                    //           ),
                                    //           Text(userData!.email.validate(), style: secondaryTextStyle()),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    // SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        launchUrl(Uri.parse('tel:${userData!.contactNumber}'));
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 6,left: 50,right: 0,bottom: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.call, color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Text(userData!.contactNumber.validate(), style: primaryTextStyle(size: 14)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        print("email");
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 0,left: 50,right: 0,bottom: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.email, size: 20),
                                            SizedBox(width: 8),
                                            Text(userData!.email.validate(), style: primaryTextStyle(size: 14)),
                                          ],
                                        ),
                                      ),
                                    ),



                                    if (userData!.cityName != null || userData!.countryName != null)
                                      Padding(
                                          padding: EdgeInsets.only(top: 4,left: 50,right: 0,bottom: 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_city, color: primaryColor, size: 20),
                                            SizedBox(width: 8),
                                            Text(userData!.cityName.validate() + " ," + userData!.countryName.validate(), style: primaryTextStyle(size: 14)),
                                          ],
                                        ),
                                      ),

                                    if (userData!.cityName != null || userData!.countryName != null) SizedBox(height: 8),
                                    Padding(
                                        padding: EdgeInsets.only(top: 4,left: 50,right: 0,bottom: 0),
                                      child: Row(
                                        children: [
                                          Icon(Entypo.calendar, color: primaryColor, size: 20),
                                          SizedBox(width: 8),
                                          Text(printDate(userData!.createdAt.validate()), style: primaryTextStyle(size: 14)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (userData != null && userData!.userBankAccount != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: containerDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Text(language.bankDetails, style: boldTextStyle(color: primaryColor)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.bankName, style: primaryTextStyle(size: 14)),
                                        Text('${userData!.userBankAccount!.bankName.validate()}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                    Divider(thickness: 0.9, height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.ifscCode, style: primaryTextStyle(size: 14)),
                                        Text('${userData!.userBankAccount!.bankCode.validate()}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                    Divider(thickness: 0.9, height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.accountHolderName, style: primaryTextStyle(size: 14)),
                                        Text('${userData!.userBankAccount!.accountHolderName.validate()}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                    Divider(thickness: 0.9, height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.accountNumber, style: primaryTextStyle(size: 14)),
                                        Text('${userData!.userBankAccount!.accountNumber.validate()}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (earningDetail != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              totalUserWidget(context, title: language.walletBalance, totalCount: printAmount(earningDetail!.walletBalance ?? 0), isThree: true),
                              totalUserWidget(context, title: language.totalWithdraw, totalCount: printAmount(earningDetail!.totalWithdrawn ?? 0), isThree: true),
                              totalUserWidget(context, title: language.totalOrder, totalCount: earningDetail!.totalOrder ?? 0, isThree: true),
                              totalUserWidget(context, title: language.paidOrder, totalCount: earningDetail!.paidOrder ?? 0, isThree: true),
                              totalUserWidget(context, title: language.adminCommission, totalCount: printAmount(earningDetail!.adminCommission ?? 0), isThree: true),
                              totalUserWidget(context, title: language.deliveryManCommission, totalCount: printAmount(earningDetail!.deliveryManCommission ?? 0), isThree: true),
                            ],
                          ),
                        ),
                      if (walletHistory != null && (walletHistory!.data ?? []).isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: containerDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Text(language.walletHistory, style: boldTextStyle(color: primaryColor)),
                              ),
                              ListView.builder(
                                  padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                                  primary: true,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: walletHistory!.data!.length,
                                  itemBuilder: (context, i) {
                                    WalletData data = walletHistory!.data![i];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(8),
                                      decoration: containerDecoration(),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(transactionType(data.transactionType!), style: boldTextStyle(size: 16)),
                                              Spacer(),
                                              Text('${printAmount(data.amount ?? 0)}', style: primaryTextStyle(color: data.type == CREDIT ? Colors.green : Colors.red))
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(printDate(data.createdAt.validate()), style: secondaryTextStyle()),
                                              Spacer(),
                                              if(data.orderId!=null) Text('${language.orderId}: #${data.orderId}', style: secondaryTextStyle()),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              if (walletHistory!.pagination!.totalItems! > walletHistory!.pagination!.perPage!)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12, right: 12),
                                  child: paginationWidget(
                                      currentPage: walletHistory!.pagination!.currentPage!,
                                      totalPage: walletHistory!.pagination!.totalPages!,
                                      onUpdate: (currentPage) {
                                        getWalletListApi(currentPage);
                                      }),
                                ),
                            ],
                          ),
                        ),
                      if (earningList != null && (earningList!.data ?? []).isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: containerDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Text(language.earningHistory, style: boldTextStyle(color: primaryColor)),
                              ),
                              ListView.builder(
                                  padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                                  primary: true,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: earningList!.data!.length,
                                  itemBuilder: (context, i) {
                                    EarningData data = earningList!.data![i];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(8),
                                      decoration: containerDecoration(),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('${language.orderId}: #${data.orderId}', style: boldTextStyle()),
                                              Spacer(),
                                              Text(
                                                '${data.paymentType}',
                                                style: primaryTextStyle(),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(printDate(data.createdAt.validate()), style: secondaryTextStyle()),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                language.deliveryManEarning,
                                                textAlign: TextAlign.center,
                                                style: primaryTextStyle(size: 14),
                                              ),
                                              Text('${printAmount(data.deliveryManCommission ?? 0)}', style: boldTextStyle(size: 15)),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                language.adminCommission,
                                                textAlign: TextAlign.center,
                                                style: primaryTextStyle(size: 14),
                                              ),
                                              Text('${printAmount(data.adminCommission ?? 0)}', style: boldTextStyle(size: 15)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              if (earningList!.pagination!.totalItems! > earningList!.pagination!.perPage!)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12, right: 12),
                                  child: paginationWidget(
                                      currentPage: earningList!.pagination!.currentPage!,
                                      totalPage: earningList!.pagination!.totalPages!,
                                      onUpdate: (currentPage) {
                                        getPaymentListApi(currentPage);
                                      }),
                                ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              if (appStore.isLoading) loaderWidget(),
            ],
          );
        }),
      ),
    );
  }
}
