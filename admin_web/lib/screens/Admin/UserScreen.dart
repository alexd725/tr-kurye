import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/AddButtonComponent.dart';
import '../../components/Admin/AddUserDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/PaginationWidget.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../network/RestApis.dart';
import 'DeliveryBoyDetailScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class UsersScreen extends StatefulWidget {
  static String route = '/admin/users';

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  int currentIndex = 1;

  List<UserModel> userData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setSelectedMenuIndex(USER_INDEX);
    getUserListApiCall();
  }

  getUserListApiCall() async {
    appStore.setLoading(true);
    await getAllUserList(type: CLIENT, page: currentPage, perPage: perPage).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      userData.clear();
      userData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  updateStatusApiCall(UserModel userData) async {
    Map req = {
      "id": userData.id,
      "status": userData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await updateUserStatus(req).then((value) {
      appStore.setLoading(false);
      getUserListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteUserApiCall(int id) async {
    Map req = {"id": id};
    appStore.setLoading(true);
    await deleteUser(req).then((value) {
      appStore.setLoading(false);
      getUserListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreUserApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await userAction(req).then((value) {
      appStore.setLoading(false);
      getUserListApiCall();
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
    Widget addUserButton() {
      return AddButtonComponent(language.addUser, () {
        showDialog(
          context: context,
          barrierDismissible: false, // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AddUserDialog(
              userType: CLIENT,
              onUpdate: () {
                getUserListApiCall();
                setState(() {});
              },
            );
          },
        );
      });
    }

    return Observer(
      builder: (_) => BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveWidget.isSmallScreen(context) && appStore.isMenuExpanded
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(language.users, style: boldTextStyle(size: 20, color: primaryColor)),
                            addUserButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.users, style: boldTextStyle(size: 20, color: primaryColor)),
                            addUserButton(),
                          ],
                        ),
                  SizedBox(height: 16),
                  userData.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RawScrollbar(
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                              radius: Radius.circular(defaultRadius),
                              child: Container(
                                decoration:
                                    BoxDecoration(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
                                child: SingleChildScrollView(
                                  controller: horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: getBodyWidth(context) - 48),
                                    child: DataTable(
                                      dataRowHeight: 45,
                                      headingRowHeight: 45,
                                      horizontalMargin: 16,
                                      headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                      showCheckboxColumn: false,
                                      dataTextStyle: primaryTextStyle(size: 14),
                                      headingTextStyle: boldTextStyle(),
                                      columns: [
                                        DataColumn(label: Text(language.id)),
                                        DataColumn(label: Text(language.name)),
                                        DataColumn(label: Text(language.contactNumber)),
                                        DataColumn(label: Text(language.email_id)),
                                        DataColumn(label: Text(language.city)),
                                        DataColumn(label: Text(language.country)),
                                        DataColumn(label: Text(language.register_date)),
                                        DataColumn(label: Text(language.status)),
                                        DataColumn(label: Text(language.actions)),
                                      ],
                                      rows: userData.map((e) {
                                        return DataRow(cells: [
                                          DataCell(Text('${e.id}')),
                                          DataCell(Text(e.name ?? "-")),
                                          DataCell(Text(e.contactNumber ?? "-")),
                                          DataCell(Text(e.email ?? "-")),
                                          DataCell(Text(e.cityName ?? "-")),
                                          DataCell(Text(e.countryName ?? "-")),
                                          DataCell(Text(printDate(e.createdAt ?? ""))),
                                          DataCell(
                                            TextButton(
                                              child: Text(e.status == 1 ? language.enable : language.disable, style: primaryTextStyle(color: e.status == 1 ? primaryColor : Colors.red)),
                                              onPressed: () {
                                                commonConfirmationDialog(context, e.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                                  if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                    toast(language.demo_admin_msg);
                                                  } else {
                                                    Navigator.pop(context);
                                                    updateStatusApiCall(e);
                                                  }
                                                },
                                                    title: e.status != 1 ? language.enable_user : language.disable_user,
                                                    subtitle: e.status != 1 ? language.do_you_want_to_enable_this_user : language.do_you_want_to_disable_this_user);
                                              },
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    outlineActionIcon(e.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, '${e.deletedAt == null ? language.edit : language.restore}', () {
                                                      e.deletedAt == null
                                                          ? showDialog(
                                                              context: context,
                                                              barrierDismissible: false, // false = user must tap button, true = tap outside dialog
                                                              builder: (BuildContext dialogContext) {
                                                                return AddUserDialog(
                                                                  userData: e,
                                                                  userType: CLIENT,
                                                                  onUpdate: () {
                                                                    getUserListApiCall();
                                                                  },
                                                                );
                                                              },
                                                            )
                                                          : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                                              if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                                toast(language.demo_admin_msg);
                                                              } else {
                                                                Navigator.pop(context);
                                                                restoreUserApiCall(id: e.id, type: RESTORE);
                                                              }
                                                            }, title: language.restore_user, subtitle: language.restore_user_msg);
                                                    }),
                                                    SizedBox(width: 8),
                                                  ],
                                                ),
                                                outlineActionIcon(
                                                    e.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, '${e.deletedAt == null ? language.delete : language.force_delete}', () {
                                                  commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                                    if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                      toast(language.demo_admin_msg);
                                                    } else {
                                                      Navigator.pop(context);
                                                      e.deletedAt == null ? deleteUserApiCall(e.id!) : restoreUserApiCall(id: e.id, type: FORCE_DELETE);
                                                    }
                                                  }, isForceDelete: e.deletedAt != null, title: language.delete_user, subtitle: language.delete_user_msg);
                                                }),
                                                8.width,
                                                outlineActionIcon(Icons.visibility, primaryColor, language.view, () {
                                                  Navigator.pushNamed(context, DeliveryPersonDetailScreen.route + "?user_Id=${e.id}").then((value) {
                                                    getUserListApiCall();
                                                    setState(() {});
                                                  });
                                                }),
                                              ],
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            paginationWidget(
                              context,
                              currentPage: currentPage,
                              totalPage: totalPage,
                              perPage: perPage,
                              onUpdate: (currentPageVal, perPageVal) {
                                currentPage = currentPageVal;
                                perPage = perPageVal;
                                init();
                              },
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 80),
                ],
              ),
            ),
            appStore.isLoading
                ? loaderWidget()
                : userData.isEmpty
                    ? emptyWidget()
                    : SizedBox()
          ],
        ),
      ),
    );
  }
}
