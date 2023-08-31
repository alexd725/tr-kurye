import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/CountryListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../components/AddCountryDialog.dart';
import '../utils/Common.dart';

class CountryScreen extends StatefulWidget {
  static String tag = '/CountryComponent';

  @override
  CountryScreenState createState() => CountryScreenState();
}

class CountryScreenState extends State<CountryScreen> {
  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  List<CountryData> countryList = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getCountryListApiCall();
    });
  }

  Future<void> scrollHandler() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (currentPage < totalPage) {
        currentPage++;
        setState(() {});
        getCountryListApiCall();
      }
    }
  }

  getCountryListApiCall() async {
    appStore.setLoading(true);
    await getCountryList(page: currentPage, isDeleted: true).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        countryList.clear();
      }
      countryList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteCountryApiCall(int id) async {
    appStore.setLoading(true);
    await deleteCountry(id).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getCountryListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreCountryApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await countryAction(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getCountryListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  updateStatusApiCall(CountryData countryData) async {
    Map req = {
      "id": countryData.id,
      "status": countryData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await addCountry(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getCountryListApiCall();
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
      appBar: AppBar(title: Text(language.country), actions: [
        addButton(
          language.add,
          () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AddCountryDialog(onUpdate: () {
                  currentPage = 1;
                  getCountryListApiCall();
                });
              },
            );
          },
        )
      ]),
      body: Observer(builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                itemCount: countryList.length,
                itemBuilder: (context, i) {
                  CountryData mData = countryList[i];
                  return Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: containerDecoration(),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(mData.name.toString(), style: boldTextStyle()),
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
                                          }, title: mData.status != 1 ? language.enableCountry : language.disableCountry, subtitle: mData.status != 1 ? language.enableCountryMsg : language.disableCountryMsg)
                                        : toast(language.youCannotUpdateStatusRecordDeleted);
                                  },
                                ),
                                outlineActionIcon(context, mData.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, () {
                                  mData.deletedAt == null
                                      ? showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext dialogContext) {
                                            return AddCountryDialog(
                                              countryData: mData,
                                              onUpdate: () {
                                                getCountryListApiCall();
                                              },
                                            );
                                          },
                                        )
                                      : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                          if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                            toast(language.demoAdminMsg);
                                          } else {
                                            Navigator.pop(context);
                                            restoreCountryApiCall(id: mData.id, type: RESTORE);
                                          }
                                        }, title: language.restoreCountry, subtitle: language.restoreCountryMsg);
                                }),
                                SizedBox(width: 8),
                                outlineActionIcon(context, mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, () {
                                  commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                    if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                      toast(language.demoAdminMsg);
                                    } else {
                                      Navigator.pop(context);
                                      mData.deletedAt == null ? deleteCountryApiCall(mData.id!) : restoreCountryApiCall(id: mData.id, type: FORCE_DELETE);
                                    }
                                  }, isForceDelete: mData.deletedAt != null, title: language.deleteCountry, subtitle: language.deleteCountryMsg);
                                }),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(MaterialCommunityIcons.map_marker_distance, color: Colors.grey, size: 18),
                                    SizedBox(width: 8),
                                    Text(mData.distanceType.toString(), style: primaryTextStyle()),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Container(height: 12, width: 1, color: Colors.grey),
                                SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(MaterialCommunityIcons.weight, color: Colors.grey, size: 18),
                                    SizedBox(width: 8),
                                    Text(mData.weightType.toString(), style: primaryTextStyle()),
                                  ],
                                ),
                                Spacer(),
                                Text('${language.id}: #${mData.id ?? ""}', style: secondaryTextStyle()),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Entypo.calendar, color: Colors.grey, size: 16),
                                SizedBox(width: 8),
                                Text(printDate(mData.createdAt.toString()), style: secondaryTextStyle()),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            appStore.isLoading
                ? loaderWidget()
                : countryList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        );
      }),
    );
  }
}
