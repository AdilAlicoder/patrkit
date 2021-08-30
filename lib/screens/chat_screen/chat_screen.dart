import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/services/chat_helper.dart';
import 'package:parkit_app/src/pages/call.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:parkit_app/utils/size_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {

  final AppUser chatUser;
  ChatScreen({this.chatUser});

  @override
  _ChatScreenState createState() => _ChatScreenState(chatUser.userId);
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  String chatRoomId;
  Stream chatMessageStream;
  ClientRole _role = ClientRole.Broadcaster;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String username;
  String name;
  String number;
  String  uid;
  String userId;
  String tokan_id;
  final _controller = ScrollController();

  _ChatScreenState(this.userId);
  Future<void> currentuser() async {
    final User user = await auth.currentUser;
    Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot snap) {
      setState(() {
        username = snap['fullName'];
        number = snap['phoneNumber'];
        name = snap['userName'];
        uid = user.uid;
      });
    });
      Firestore.instance
        .collection('token')
        .document(widget.chatUser.userId)
        .get()
        .then((DocumentSnapshot snap) {
          setState(() {
            tokan_id = snap['token'];
          });
        });
  }
  
  @override
  void initState() {
    super.initState();
    currentuser();
    createChatRoom();
    ChatDatabaseModel().getConversationMessages(chatRoomId).then((value){
      setState(() {
        chatMessageStream = value;
        getChatUserDetail();
      });
    });
  }


  void getChatUserDetail() async {
    EasyLoading.show( status: 'Please wait',maskType: EasyLoadingMaskType.black,);
    AppUser chatUserResult = await AppUser.getUserDetailByUserId(widget.chatUser.userId);
    EasyLoading.dismiss();
    if (chatUserResult != null) {
      widget.chatUser.oneSignalUserId = chatUserResult.oneSignalUserId;
    }
  }

  void createChatRoom(){
    chatRoomId = getChatRoomID(widget.chatUser.userId,Constants.appUser.userId);
    //add Pet ID
    chatRoomId = chatRoomId;
    List<String> users = [widget.chatUser.userId, Constants.appUser.userId];
    Map<String, dynamic> chatRoomMap = {
      "users" : users,
      "chatRoomId" : chatRoomId,
      "total_msg" : 0,
      'lastMessageTimeStamp' : FieldValue.serverTimestamp(),     
    };

    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).
      set(chatRoomMap).then((_) async {
        print("success!");
      }).catchError((error) {
        print("Failed to update: $error");
    });
  }

  String getChatRoomID(String a , String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0))
      return "$b\_$a";
    else
      return "$a\_$b";
  }

  void sendMessagePressed(){
    if(messageController.text.trim().isEmpty)
      Constants.showDialog('Please enter message');
    else
    {
      Map<String, dynamic> messageMap = {
        'message' : messageController.text,
        'sendBy' : Constants.appUser.userId,
        'timestamp' : FieldValue.serverTimestamp()
      };
      ChatDatabaseModel().sendConversationMessage(chatRoomId, messageMap);
      AppController().sendChatNotificationToUser(widget.chatUser);
      messageController.text = '';
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }  

  void blockUserDialog() {
    String reportReason = "";
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        title:Text('Report User', style: TextStyle(fontWeight : FontWeight.bold)),
        content: Container(
          width : SizeConfig.blockSizeHorizontal * 90,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text("Reporting user will delete the chat and report user to admin. Enter reporting reason"),
              Container(
                height: SizeConfig.blockSizeVertical * 15,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                    onChanged: (val){
                      reportReason = val;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: 'Enter reason',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel',),
          ),
           FlatButton(
            onPressed: () {
              if(reportReason.length >0)
              {
                Get.back();
                deleteChatAndReportUser(reportReason);
              }
              else
              {
                Constants.showDialog('Please enter reporting reason');
              }
            },
            child: Text('Yes', style: TextStyle(color: Constants.appThemeColor)),
          )
        ],
      )
    );
  }  

  void deleteChatAndReportUser(String reason) async {
    EasyLoading.show( status: 'Please wait',maskType: EasyLoadingMaskType.black,);
    dynamic result = await ChatDatabaseModel().deleteUserChat(chatRoomId, Constants.appUser, widget.chatUser, reason);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      Get.back();
      Constants.showDialog('The user has been reported to admin. Thank you');
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }
  Future<void> onJoin() async {
    // update input validation


    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
            '$userId-$uid',
          _role,
          widget.chatUser.fullName,
          widget.chatUser.userId
        ),
      ),
    );

  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
  callUser(String uid, String name, String recId) async {
    print(recId);
    print('adil alkjsjs');
    try {
            var res=await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':'key=AAAA7LPJY3E:APA91bH2_Qtdi8v50FbncuhNHOw-PsmCB4JQG3pOK5rLsTa26_myT_y7bNHV9eitKp3CIBe02aPcDKg-u9pJ77K2RB2Xr59Nl09wDXsXGEMdcCTPhk7DVA2e5kfqhKgK6gcOwcOqy2i3',
          },
          body:jsonEncode( {
            'registration_ids': [recId],
            'data':{
               'userId':uid,
                'name':name
            }
          }));
      print('Message sent to device!');
      print(res.body.toString());
      print('ADIL ALI');
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Constants.appThemeColor,
          elevation: 0,
          centerTitle: true,
          title:  Text(
            '${widget.chatUser.fullName}',
            textAlign: TextAlign.left,
            style: TextStyle(
            fontSize : SizeConfig.fontSize * 2.7,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Colors.white),
            onPressed: (){
           Firestore.instance.collection('call').document(widget.chatUser.userId).setData({
          'Name': username,
          'Number': number,
          'channelname':'$userId-$uid',
        });
              callUser(uid,username,tokan_id);
              onJoin();
            }
          ),

          IconButton(
            icon: Icon(Icons.report, color: Colors.white, semanticLabel: 'Block',),
            onPressed: blockUserDialog,
          )
        ],
      ),
      body: Container(
        child : Column(
          children: [
            
            if(!Constants.appUser.isAdmin)
            Container(
              //height: SizeConfig.blockSizeVertical * 15,
                //color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      width: SizeConfig.blockSizeVertical * 15,
                      //height: SizeConfig.blockSizeVertical * 10,
                      margin: EdgeInsets.only(top: 15, bottom: 5),
                      //color: Colors.red,
                      child:  CircleAvatar(
                        radius: SizeConfig.blockSizeVertical * 7,
                          backgroundColor: Constants.appThemeColor,
                          child:  ClipRRect(
                            borderRadius: new BorderRadius.circular(100.0),
                            child: Image.asset(
                              'assets/logo2.png',
                              fit: BoxFit.cover,
                              height: SizeConfig.blockSizeVertical * 15,
                              width: SizeConfig.blockSizeVertical * 15,
                            ),
                          ),
                        ),
                      ),
                      /*
                    Container(
                      margin: EdgeInsets.only(bottom: 2, top: SizeConfig.blockSizeVertical * 1),
                      child: Text(
                        '${widget.chatUser.fullName}',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 2.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    */
                  ],
                ),
              ),

              Container(
                height: 1,
                margin: EdgeInsets.only(top: 15, bottom: 15),
                decoration: BoxDecoration(
                color: Color(0XFFC4C4C4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0XFFC4C4C4).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                )
              ),
              
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: chatMessageList(),
                ),
              ),
              /*
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index){
                      return MessageTitle(index: index,);
                    }
                  )
                ),
              ),
              */

              Container(
                child: Container(
                  height: SizeConfig.blockSizeVertical * 8,
                  margin: EdgeInsets.only(bottom: (Platform.isIOS) ? 15 : 0),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Center(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        fillColor:  Colors.white,
                        filled: true,
                        hintText: 'Send a message...',
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(width: 1,color: Color(0XFFD4D4D4)),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFFD4D4D4)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: Constants.appThemeColor), 
                          onPressed: (){
                            sendMessagePressed();
                            FocusScope.of(context).requestFocus(FocusNode());
                          }
                        )
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      )
    );
  }

  Widget chatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          controller: _controller,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index){
            return MessageTitle(messageDetail: snapshot.data.documents[index].data(), selectedChatUser: widget.chatUser,);
          }
        ): Container();
      }
    );
  }
}


class MessageTitle extends StatefulWidget {
  
  final AppUser selectedChatUser;
  final Map messageDetail;
  MessageTitle({this.messageDetail, this.selectedChatUser});

  @override
  _MessageTitleState createState() => _MessageTitleState();
}

class _MessageTitleState extends State<MessageTitle> {

  bool isSendByMe = true;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isSendByMe = (widget.messageDetail['sendBy'] == Constants.appUser.userId) ? true : false; 

    return Align(
      alignment: (isSendByMe) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: (!isSendByMe) ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [

            if(!isSendByMe)
             CircleAvatar(
              radius: 20,
              backgroundColor: Constants.appThemeColor,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(100.0),
                child: (widget.selectedChatUser.userProfilePic.length ==0) ? Image.asset(
                  'assets/user_bg.png',
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ) : CachedNetworkImage(
                  imageUrl: widget.selectedChatUser.userProfilePic,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                )
              ),
            ),
            
            Flexible(
              child: Container(
                margin: EdgeInsets.only(top: 0, bottom: 10, left: (isSendByMe) ? 50 : 10, right: (isSendByMe) ? 10 : 50),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color : (isSendByMe) ? Colors.transparent : Constants.appThemeColor,
                  border: Border.all(
                    color: Constants.appThemeColor,
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  widget.messageDetail['message'],
                  style: TextStyle(
                    color: (isSendByMe) ? Constants.appThemeColor : Colors.white,
                    fontSize: SizeConfig.fontSize * 1.8
                  ),
                ),        
              ),
            ),

            if(isSendByMe)
            CircleAvatar(
              radius: 20,
              backgroundColor: Constants.appThemeColor,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(100.0),
                child: (Constants.appUser.userProfilePic.length == 0) ? Image.asset(
                  'assets/user_bg.png',
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ) : CachedNetworkImage(
                  imageUrl: Constants.appUser.userProfilePic,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                )
              ),
            ),

          ],
        ),
      )
    );
  }
}

/*
  Widget chatCell(int index){
    bool isSendByMe = false;
    if(index == 2)
      isSendByMe = true;

    return Align(
      alignment: (isSendByMe) ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: (!isSendByMe) ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [

          if(!isSendByMe)
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child:  ClipRRect(
              borderRadius: new BorderRadius.circular(100.0),
              child: Image.asset(
                images[0],
                fit: BoxFit.cover,
                height: 40,
                width: 40,
              ),
            ),
          ),
          
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: (isSendByMe) ? 50 : 10, right: (isSendByMe) ? 10 : 50),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: (isSendByMe) ? BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20)
              ): BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)
              )
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ],
            )
          ),

          if(isSendByMe)
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child:  ClipRRect(
              borderRadius: new BorderRadius.circular(100.0),
              child: Image.asset(
                images[0],
                fit: BoxFit.cover,
                height: 40,
                width: 40,
              ),
            ),
          ),
        ],
      )
    );
  }
}
*/