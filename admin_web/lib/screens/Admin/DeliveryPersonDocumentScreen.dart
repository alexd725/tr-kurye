import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:local_delivery_admin/utils/Extensions/context_extensions.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import '/../main.dart';
import '/../models/DeliveryDocumentListModel.dart';
import '/../network/NetworkUtils.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';
import '../../components/PaginationWidget.dart';

class DeliveryPersonDocumentScreen extends StatefulWidget {
  static String route = '/admin/deliverypersondocuments';

  final int? deliveryManId;

  DeliveryPersonDocumentScreen({this.deliveryManId});

  @override
  DeliveryPersonDocumentScreenState createState() => DeliveryPersonDocumentScreenState();
}

class DeliveryPersonDocumentScreenState extends State<DeliveryPersonDocumentScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<DeliveryDocumentData> deliveryDocList = [];
  List<String> document = [PENDING, APPROVEDText, REJECTED];
  int selected = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(DELIVERY_PERSON_DOCUMENT_INDEX);
    getDocumentListApiCall();
  }

  /// Verify Documents
  verifyDocument(int docId) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('delivery-man-document-save');
    multiPartRequest.fields["id"] = docId.toString();
    multiPartRequest.fields["is_verified"] = selected.toString();
    multiPartRequest.headers.addAll(buildHeaderTokens());
    appStore.setLoading(true);
    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        getDocumentListApiCall();
      },
      onError: (error) {
        toast(error.toString());
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  /// Delivery Document List
  getDocumentListApiCall() async {
    appStore.setLoading(true);
    await getDeliveryDocumentList(page: currentPage, isDeleted: true, deliveryManId: widget.deliveryManId, perPage: perPage).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      deliveryDocList.clear();
      deliveryDocList.addAll(value.data!);
      if (currentPage != 1 && deliveryDocList.isEmpty) {
        currentPage -= 1;
        getDocumentListApiCall();
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  int docDataValue(String name) {
    if (name == PENDING) {
      return 0;
    } else if (name == APPROVEDText) {
      return 1;
    } else if (name == REJECTED) {
      return 2;
    }
    return 0;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return BodyCornerWidget(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              controller: ScrollController(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.delivery_person_documents, style: boldTextStyle(size: 20, color: primaryColor)),
                  deliveryDocList.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 16),
                            RawScrollbar(
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                              radius: Radius.circular(defaultRadius),
                              child: Container(
                                decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
                                child: SingleChildScrollView(
                                  controller: horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: getBodyWidth(context) - 48),
                                    child: DataTable(
                                        dataRowHeight: 100,
                                        headingRowHeight: 45,
                                        horizontalMargin: 16,
                                        headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                        showCheckboxColumn: false,
                                        dataTextStyle: primaryTextStyle(size: 14),
                                        headingTextStyle: boldTextStyle(),
                                        columns: [
                                          DataColumn(label: Text(language.id)),
                                          DataColumn(label: Text(language.delivery_person_name)),
                                          DataColumn(label: Text(language.document_name)),
                                          DataColumn(label: Text(language.document)),
                                          DataColumn(label: Text(language.created)),
                                          DataColumn(label: Text(language.actions)),
                                        ],
                                        rows: deliveryDocList.map(
                                          (mData) {
                                            return DataRow(
                                              cells: [
                                                DataCell(Text('${mData.id}')),
                                                DataCell(Text('${mData.deliveryManName ?? "-"}')),
                                                DataCell(Text('${mData.documentName ?? "-"}')),
                                                DataCell(
                                                  TextButton(
                                                    child: mData.deliveryManDocument!.contains('.pdf')
                                                        ? Container(
                                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(defaultRadius)),
                                                            child: Text(mData.deliveryManDocument!.split('/').last, style: primaryTextStyle()),
                                                          )
                                                        : commonCachedNetworkImage(mData.deliveryManDocument ?? "", height: 80, width: 80),
                                                    onPressed: () {
                                                      launchUrl(Uri.parse(mData.deliveryManDocument ?? ""));
                                                    },
                                                  ),
                                                ),
                                                DataCell(Text(printDate(mData.createdAt!))),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: DropdownButtonFormField<int>(
                                                          dropdownColor: Theme.of(context).cardColor,
                                                          decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            fillColor: context.cardColor,
                                                            focusedBorder: InputBorder.none,
                                                            filled: true,
                                                          ),
                                                          value: mData.isVerified ?? selected,
                                                          items: document.map((e) {
                                                            return DropdownMenuItem(
                                                              child: Text(documentData(e), style: primaryTextStyle()),
                                                              value: docDataValue(e),
                                                            );
                                                          }).toList(),
                                                          onChanged: (int? val) {
                                                            selected = val!;
                                                            setState(() {});
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            commonConfirmationDialog(context, DIALOG_TYPE_ENABLE, () {
                                                              if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                                toast(language.demo_admin_msg);
                                                              } else {
                                                                Navigator.pop(context);
                                                                verifyDocument(mData.id!);
                                                              }
                                                            }, title: language.verify_document, subtitle: language.do_you_want_to_verify_document);
                                                          },
                                                          child: Text(language.verify),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).toList()),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            paginationWidget(context, currentPage: currentPage, totalPage: totalPage, perPage: perPage, onUpdate: (currentPageVal, perPageVal) {
                              currentPage = currentPageVal;
                              perPage = perPageVal;
                              getDocumentListApiCall();
                              setState(() {});
                            }),
                            SizedBox(height: 80),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
            appStore.isLoading
                ? loaderWidget()
                : deliveryDocList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        ),
      );
    });
  }
}
