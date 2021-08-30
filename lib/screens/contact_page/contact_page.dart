import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';


class ContactPage extends StatefulWidget {

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool isLoading = false;
  TextEditingController subject = TextEditingController();
  TextEditingController message = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

  void submitContactUsQuery() async {
    if(subject.text.isEmpty)
      Constants.showDialog('Please enter subject');
    else if(message.text.isEmpty)
      Constants.showDialog('Please enter message');
    else
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().submitContactUsQuery(subject.text, message.text);
      EasyLoading.dismiss();
      setState(() => isLoading = false); 
      if (result['Status'] == "Success") 
      {
        Get.back();
        Constants.showDialog("You message has been successfully sent to our support team");
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          'Contact Us',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize : SizeConfig.fontSize * 2.7,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            print('close');
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus)
              currentFocus.unfocus();
          },
          child: Container(
            margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8, top: SizeConfig.blockSizeHorizontal * 5,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 3,
                        fontWeight: FontWeight.bold,
                        color: Constants.appThemeColor
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),                   
                  alignment: Alignment.center,
                  child: Text(
                    'Any questions? Just write us a message',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize : SizeConfig.fontSize * 2,
                      color: Constants.appThemeColor,
                      //fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5, left: 10),                   
                  child: Text(
                    'Subject',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: SizeConfig.fontSize * 1.6
                      ),
                    ),
                  ),
                  Container(
                    height: SizeConfig.blockSizeVertical * 7,
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: TextField(
                        style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                        controller: subject,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          hintText: 'Enter subject',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                          fillColor: Colors.grey[100],
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  //MESSAGE
                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3, left: 10),                   
                    child: Text(
                      'Message',
                      style: TextStyle(
                          color: Colors.grey,
                        fontSize: SizeConfig.fontSize * 1.6
                      ),
                    ),
                  ),
                  Container(
                    height: SizeConfig.blockSizeVertical * 40,
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                      controller: message,
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        hintText: 'Enter message',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: (){
                      submitContactUsQuery();
                    },
                    child: Container(
                      height: SizeConfig.blockSizeVertical * 7,
                      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
                      decoration: BoxDecoration(
                        color: Constants.appThemeColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(
                        child: Text(
                          'SUBMIT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize : SizeConfig.fontSize * 1.8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}