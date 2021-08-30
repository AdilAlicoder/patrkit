import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class SupportDetail extends StatefulWidget {
  
  Map supportTicket;
  SupportDetail({this.supportTicket});

  @override
  _SupportDetailState createState() => _SupportDetailState();
}

class _SupportDetailState extends State<SupportDetail> {

  TextEditingController messageController = TextEditingController();
  List messages = [];
  @override
  void initState() {
    super.initState();
    messages = widget.supportTicket['messagesList'];
    Constants.callBackFunction = loadOrRefreshChat;
  }


  @override
  void dispose() {
    Constants.callBackFunction = null; 
    super.dispose();
  }

  Future<void> loadOrRefreshChat() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getSupportDetail(widget.supportTicket);
    EasyLoading.dismiss();
    if (result['Status'] == "Success") 
    {
      setState(() {
        widget.supportTicket = result['Data'];      
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  Future<void> sendMessagePressed() async {
    if(messageController.text.trim().isEmpty)
      Constants.showDialog('Please enter message');
    else
    {
       Map messageDetail = {
        'userId' : Constants.appUser.userId,
        'messageText' :  messageController.text,
      };
      
      await AppController().sendSupportMessage(widget.supportTicket, messageDetail);
      AppController().sendSupportMessageNotification(widget.supportTicket);

      messageController.text = '';
      messages.add(messageDetail);
      setState(() {});
    }
  }  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          'Tickets Detail',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize : SizeConfig.fontSize * 2.7,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, i){
                  return supportMessageCell(messages[i]);
                },
              ),
            ),
          ),

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
      ),
    );
  }

  Widget supportMessageCell(Map messageData){
    bool isSendByMe = (messageData['userId'] == Constants.appUser.userId) ? true : false; 

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
              backgroundColor: Colors.black,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(100.0),
                child: Image.asset(
                  'assets/user_bg.png',
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
                  messageData['messageText'],
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
              backgroundColor: Colors.black,
              child:  ClipRRect(
                borderRadius: new BorderRadius.circular(100.0),
                child: Image.asset(
                 'assets/user_bg.png',
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