import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/screens/chat_screen/chat_screen.dart';
import 'package:parkit_app/services/chat_helper.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  Stream chatRoomsStream;

  @override
  void initState() {
    super.initState();
    ChatDatabaseModel().getUserChatRooms(Constants.appUser.userId).then((value){
      setState(() {
        chatRoomsStream = value;        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 5, top: SizeConfig.blockSizeVertical * 4),
              child: Text(
                'My Messages',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize * 3.5,
                  color: Constants.appThemeColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10,right: 10),
                child: chatMessageList(),
              ),
            )  
          ]
        )
      )
    );
  }

  Widget chatMessageList(){
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot){
        return snapshot.hasData ? (snapshot.data.documents.length > 0) ? ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index){
            return MessageCell( messageData: snapshot.data.documents[index].data());
          }
        ) : Container(
          margin: EdgeInsets.only(bottom: 50),
          child: Center(
            child: Text(
              'No Messages Yet',
              style: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.fontSize * 2.5,
                //fontWeight: FontWeight.bold
              ),
            ),
          ),
        )
        : Container();
      }
    );
  }
}

class MessageCell extends StatefulWidget {

  final Map messageData;
  MessageCell({this.messageData});

  @override
  _MessageCellState createState() => _MessageCellState();
}

class _MessageCellState extends State<MessageCell> {

  AppUser chatUser;
  String chatUserID = "";
  String chatUserName = "";
  String chatUserImage = "";

  String formatDate = "";

  @override
  void initState() {
    super.initState();
    var dateTime = widget.messageData['lastMessageTimeStamp'].toDate();
    formatDate = DateFormat('hh:mm a').format(dateTime);

    chatUserID = widget.messageData['chatRoomId'];
    chatUserID = chatUserID.replaceFirst("_", "");
    chatUserID = chatUserID.replaceFirst("${Constants.appUser.userId}", "");
    getUserDetail();
  }

  getUserDetail() async {
    chatUser = await AppUser.getUserDetailByUserId(chatUserID);
    chatUserName = chatUser.userName;
    chatUserImage = chatUser.userProfilePic;
    if(mounted)
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.to(ChatScreen(chatUser: chatUser,));
      },
      child: Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300].withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(3, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            //color: Colors.red,
            margin: EdgeInsets.only(left: 10),
            child: CircleAvatar(
              radius: SizeConfig.blockSizeVertical * 5,
                backgroundColor: Constants.appThemeColor,
                child:  ClipRRect(
                  borderRadius: new BorderRadius.circular(100.0),
                  child: (chatUserImage.length == 0) ? 
                    Image.asset(
                      'assets/user_bg.png',
                      fit: BoxFit.cover,
                      height: SizeConfig.blockSizeVertical * 10,
                      width: SizeConfig.blockSizeVertical * 10,
                    ) : CachedNetworkImage(
                      imageUrl: chatUserImage,
                      fit: BoxFit.cover,
                      height: SizeConfig.blockSizeVertical * 10,
                      width: SizeConfig.blockSizeVertical * 10,
                    ) 
                  )
                ),
              ),

          Expanded(
            child: Container(
              //color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15, bottom: 5, top: SizeConfig.blockSizeVertical * 0),
                    child: Text(
                      '$chatUserName',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2.2,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 15, bottom: 5, top: SizeConfig.blockSizeVertical * 0),
                    child: Text(
                      'Last Message : $formatDate',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.7,
                      ),
                    ),
                  ),

                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}