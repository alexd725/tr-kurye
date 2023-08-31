import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:mightydelivery_admin_app/models/DeliveryDocumentListModel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../network/NetworkUtils.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Common.dart';

class DeliveryPersonDocumentScreen extends StatefulWidget {
  static String tag = '/DeliveryPersonDocumentScreen';

  final int? deliveryManId;

  DeliveryPersonDocumentScreen({this.deliveryManId});

  @override
  DeliveryPersonDocumentScreenState createState() => DeliveryPersonDocumentScreenState();
}

class DeliveryPersonDocumentScreenState extends State<DeliveryPersonDocumentScreen> {
  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  List<DeliveryDocumentData> deliveryDocList = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getDocumentListApiCall();
        }
      }
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getDocumentListApiCall();
    });
  }

  /// Verify Documents
  verifyDocument(int docId) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('delivery-man-document-save');
    multiPartRequest.fields["id"] = docId.toString();
    multiPartRequest.fields["is_verified"] = '1';
    multiPartRequest.headers.addAll(buildHeaderTokens());
    appStore.setLoading(true);
    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        currentPage = 1;
        getDocumentListApiCall();
      },
      onError: (error) {
        toast(error.toString(), print: true);
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
    await getDeliveryDocumentList(page: currentPage, isDeleted: true, deliveryManId: widget.deliveryManId).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        deliveryDocList.clear();
      }
      deliveryDocList.addAll(value.data!);
      setState(() {});
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
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context,true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(language.deliveryPersonDocuments)),
        body: Observer(builder: (context) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ListView.builder(
                padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                itemCount: deliveryDocList.length,
                itemBuilder: (context, index) {
                  DeliveryDocumentData mData = deliveryDocList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: containerDecoration(),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        GestureDetector(
                          child: mData.deliveryManDocument!.contains('.pdf')
                              ? Container(
                                  height: 80,
                                  width: 80,
                                  decoration: containerDecoration(),
                                  child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: commonCachedNetworkImage(mData.deliveryManDocument ?? "", fit: BoxFit.cover, height: 80, width: 80),
                                ),
                          onTap: () async {
                            launchUrl(
                              Uri.parse('${mData.deliveryManDocument ?? ""}'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: Text('${mData.documentName ?? ""}', style: boldTextStyle())),
                                  mData.isVerified == 1
                                      ? Text(language.verified, style: primaryTextStyle(color: Colors.green))
                                      : SizedBox(
                                          height: 30,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              commonConfirmationDialog(context, DIALOG_TYPE_ENABLE, () {
                                                if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                                  toast(language.demoAdminMsg);
                                                } else {
                                                  Navigator.pop(context);
                                                  verifyDocument(mData.id!);
                                                }
                                              }, title: language.verifyDocument, subtitle: language.verifyDocumentMsg);
                                            },
                                            child: Text(language.verify),
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.person_outline_sharp, size: 18, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(mData.deliveryManName ?? "", style: secondaryTextStyle()),
                                  Spacer(),
                                  Text('${language.id}: #${mData.id ?? ""}', style: secondaryTextStyle()),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(printDate(mData.createdAt!), style: secondaryTextStyle()),
                                ],
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
                  : deliveryDocList.isEmpty
                      ? emptyWidget()
                      : SizedBox(),
            ],
          );
        }),
      ),
    );
  }
}
