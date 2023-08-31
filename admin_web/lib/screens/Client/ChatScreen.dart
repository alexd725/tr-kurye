import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../models/UserModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../components/Client/ChatItemWidget.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../main.dart';
import '../../models/Client/ChatMessageModel.dart';
import '../../models/Client/FileModel.dart';
import '../../services/ChatMessagesService.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class ChatScreen extends StatefulWidget {
  static const String route = '/chat';

  final int? userId;

  ChatScreen({this.userId});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  String id = '';
  String receiverId = '';

  TextEditingController messageCont = TextEditingController();
  FocusNode messageFocus = FocusNode();
  bool isMe = false;

  UserModel? receiverUser;

  late List<FileModel> fileList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  UserModel sender = UserModel(
    username: getStringAsync(NAME),
    profileImage: getStringAsync(USER_PROFILE_PHOTO),
    uid: getStringAsync(UID),
    playerId: getStringAsync(USER_PLAYER_ID),
  );

  void init() async {
    log("helo---------------------------------------" + widget.userId.toString());
    log("hello---------------------------------------" + getStringAsync(UID).toString());

    await getUserDetail(widget.userId.validate()).then((value) async {
      receiverUser = value;
      await userService.getUser(email: value.email.validate()).then((v) async {
        receiverId = v.uid!;
      }).catchError((e) {
        log(e.toString());
        if (e.toString() == "User not found") {
          toast('user Not Found');
        }
      });
    }).catchError((e) {});
    id = getStringAsync(UID);

    chatMessageService = ChatMessageService();
    chatMessageService.setUnReadStatusToTrue(senderId: sender.uid!, receiverId: receiverId);
    setState(() {});
  }

  sendMessage({FilePickerResult? result}) async {
    if (result == null) {
      if (messageCont.text.trim().isEmpty) {
        messageFocus.requestFocus();
        return;
      }
    }
    ChatMessageModel data = ChatMessageModel();
    data.receiverId = receiverUser!.uid;
    data.senderId = sender.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;

    if (receiverUser!.uid == getStringAsync(UID)) {
      //
    }
    if (result != null) {
      if (result.files.single.path!.isNotEmpty) {
        data.messageType = MessageType.IMAGE.name;
      } else {
        data.messageType = MessageType.TEXT.name;
      }
    } else {
      data.messageType = MessageType.TEXT.name;
    }

    notificationService.sendPushNotifications(getStringAsync(USER_NAME), messageCont.text, receiverPlayerId: receiverUser!.playerId).catchError((e) {});
    messageCont.clear();
    setState(() {});
    return await chatMessageService.addMessage(data).then((value) async {
      if (result != null) {
        FileModel fileModel = FileModel();
        fileModel.id = value.id;
        fileModel.file = File(result.files.single.path!);
        fileList.add(fileModel);

        setState(() {});
      }

      await chatMessageService.addMessageToDb(value, data, sender, receiverUser, image: result != null ? File(result.files.single.path!) : null).then((value) {
        //
      });

      userService.fireStore
          .collection(USER_COLLECTION)
          .doc(getIntAsync(USER_ID).toString())
          .collection(CONTACT_COLLECTION)
          .doc(receiverUser!.uid)
          .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
        log(e);
      });
      userService.fireStore
          .collection(USER_COLLECTION)
          .doc(receiverUser!.uid)
          .collection(CONTACT_COLLECTION)
          .doc(getIntAsync(USER_ID).toString())
          .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
        log(e);
      });
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
            HeaderWidget(),
            if (receiverUser != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: 16),
                decoration: boxDecorationWithRoundedCorners(border: Border.all(color: borderColor)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius)),
                      ),
                      child: Row(
                        children: [
                          commonCachedNetworkImage(receiverUser!.profileImage.validate(), height: 60, width: 60).cornerRadiusWithClipRRect(30),
                          16.width,
                          Text('${receiverUser!.name.validate()}', style: TextStyle(color: Colors.white)).paddingSymmetric(vertical: 16).expand(),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          height: context.height(),
                          width: context.width(),
                          child: PaginateFirestore(
                            reverse: true,
                            isLive: true,
                            padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                            physics: BouncingScrollPhysics(),
                            query: chatMessageService.chatMessagesWithPagination(currentUserId: getStringAsync(UID), receiverUserId: receiverId),
                            itemsPerPage: PER_PAGE_CHAT_COUNT,
                            shrinkWrap: true,
                            onEmpty: Offstage(),
                            itemBuilderType: PaginateBuilderType.listView,
                            itemBuilder: (context, snap, index) {
                              ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);
                              data.isMe = data.senderId == sender.uid;
                              return ChatItemWidget(data: data);
                            },
                          ),
                        ).expand(),
                        8.height,
                        Container(
                          decoration: boxDecorationWithShadow(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            spreadRadius: 1,
                            blurRadius: 1,
                            backgroundColor: Colors.grey.withOpacity(0.1),
                          ),
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            children: [
                              TextField(
                                controller: messageCont,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: language.writeMsg,
                                  hintStyle: secondaryTextStyle(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                                ),
                                cursorColor: Colors.black,
                                focusNode: messageFocus,
                                textCapitalization: TextCapitalization.sentences,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                style: primaryTextStyle(),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (s) {
                                  sendMessage();
                                },
                                cursorHeight: 20,
                                maxLines: 5,
                              ).expand(),
                              IconButton(
                                icon: Icon(Icons.send, color: primaryColor),
                                onPressed: () {
                                  sendMessage();
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ).paddingAll(16).expand(),
                  ],
                ),
              ).expand(),
          ],
        );
      }),
    );
  }
}
