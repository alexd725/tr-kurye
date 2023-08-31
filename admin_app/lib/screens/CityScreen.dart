import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/CityListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../components/AddCityDialog.dart';
import '../main.dart';
import '../utils/Common.dart';

class CityScreen extends StatefulWidget {
  static String tag = '/CityComponent';

  @override
  CityScreenState createState() => CityScreenState();
}

class CityScreenState extends State<CityScreen> {
  ScrollController controller = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  List<CityData> cityList = [];

  @override
  void initState() {
    super.initState();
    init();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getCityListApiCall();
        }
      }
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getCityListApiCall();
    });
  }

  getCityListApiCall() async {
    appStore.setLoading(true);
    await getCityList(page: currentPage, isDeleted: true).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        cityList.clear();
      }
      cityList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteCityApiCall(int id) async {
    appStore.setLoading(true);
    await deleteCity(id).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getCityListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreCityApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await cityAction(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getCityListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  updateStatusApiCall(CityData cityData) async {
    Map req = {
      "id": cityData.id,
      "status": cityData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await addCity(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getCityListApiCall();
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
    return Scaffold(
      appBar: AppBar(title: Text(language.city), actions: [
        addButton(language.add, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AddCityDialog(
                onUpdate: () {
                  currentPage = 1;
                  getCityListApiCall();
                },
              );
            },
          );
        }),
      ]),
      body: Observer(builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ListView.builder(
              controller: controller,
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              itemCount: cityList.length,
              itemBuilder: (context, index) {
                CityData mData = cityList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: containerDecoration(),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text('#${mData.id}', style: boldTextStyle()),
                            SizedBox(width: 8),
                            Text('${mData.name ?? "-"}', style: boldTextStyle()),
                            Spacer(),
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: mData.status == 1 ? primaryColor.withOpacity(0.6) : Colors.red.withOpacity(0.6)),
                                    color: mData.status == 1 ? primaryColor.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(defaultRadius)),
                                child: Text(
                                  '${mData.status == 1 ? language.enable : language.disable}',
                                  style: primaryTextStyle(color: mData.status == 1 ? primaryColor : Colors.red),
                                ),
                              ),
                              onTap: () {
                                mData.deletedAt == null
                                    ? commonConfirmationDialog(context, mData.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                  if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                    toast(language.demoAdminMsg);
                                  } else {
                                    Navigator.pop(context);
                                    updateStatusApiCall(mData);
                                  }
                                }, title: mData.status != 1 ? language.enableCity : language.disableCity, subtitle: mData.status != 1 ? language.enableCityMsg : language.disableCityMsg)
                                    : toast(language.youCannotUpdateStatusRecordDeleted);
                              },
                            ),
                            outlineActionIcon(context, mData.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, () {
                              mData.deletedAt == null
                                  ? showDialog(
                                context: context,
                                barrierDismissible: false, // false = user must tap button, true = tap outside dialog
                                builder: (BuildContext dialogContext) {
                                  return AddCityDialog(
                                    cityData: mData,
                                    onUpdate: () {
                                      currentPage = 1;
                                      getCityListApiCall();
                                    },
                                  );
                                },
                              )
                                  : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                  toast(language.demoAdminMsg);
                                } else {
                                  Navigator.pop(context);
                                  restoreCityApiCall(id: mData.id, type: RESTORE);
                                }
                              }, title: language.restoreCity, subtitle: language.restoreCityMsg);
                            }),
                            SizedBox(width: 8),
                            outlineActionIcon(context, mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, () {
                              commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                  toast(language.demoAdminMsg);
                                } else {
                                  Navigator.pop(context);
                                  mData.deletedAt == null ? deleteCityApiCall(mData.id!) : restoreCityApiCall(id: mData.id, type: FORCE_DELETE);
                                }
                              }, isForceDelete: mData.deletedAt != null, title: language.deleteCity, subtitle: language.deleteCityMsg);
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.countryName, style: primaryTextStyle(size: 14)),
                                Text('${mData.countryName}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${language.minimumDistance} (${mData.country!.distanceType})', style: primaryTextStyle(size: 14)),
                                Text('${mData.minDistance}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${language.minimumWeight} (${mData.country!.weightType})', style: primaryTextStyle(size: 14)),
                                Text('${mData.minWeight}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.createdDate, style: primaryTextStyle(size: 14)),
                                Text('${printDate(mData.createdAt.validate())}', style: secondaryTextStyle()),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          language.fixedCharge,
                                          textAlign: TextAlign.center,
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        SizedBox(height: 4),
                                        Text('${mData.fixedCharges ?? 0}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(thickness: 0.9),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          language.cancelCharge,
                                          textAlign: TextAlign.center,
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        SizedBox(height: 4),
                                        Text('${mData.cancelCharges ?? 0}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(thickness: 0.9),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          language.perDistanceCharge,
                                          textAlign: TextAlign.center,
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        SizedBox(height: 4),
                                        Text('${mData.perDistanceCharges ?? 0}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(thickness: 0.9),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          language.perWeightCharge,
                                          textAlign: TextAlign.center,
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        SizedBox(height: 4),
                                        Text('${mData.perWeightCharges ?? 0}', style: boldTextStyle(size: 15)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            appStore.isLoading
                ? loaderWidget()
                : cityList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        );
      }),
    );
  }
}
