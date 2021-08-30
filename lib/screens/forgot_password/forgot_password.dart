import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = new TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> backPressed() async {
    if (isLoading)
      return false;
    else
      return true;
  }

  void forgotPasswordPressed() async {
    if (email.text.isEmpty)
      Constants.showDialog("Please enter email address");
    else if (!GetUtils.isEmail(email.text))
      Constants.showDialog("Please enter valid email address");
    else {
      setState(() => isLoading = true);
      EasyLoading.show( status: 'Please wait',maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().forgotPassword(email.text,);
      EasyLoading.dismiss();
      setState(() => isLoading = false);
      if (result['Status'] == "Success") {
        Navigator.pop(context);
        Constants.showDialog('You password reset email is emailed to you successfully');
      } else {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: backPressed,
      child: Scaffold(
       backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Constants.appThemeColor,
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          centerTitle: true,
          title: Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize : SizeConfig.fontSize * 3,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8, top: SizeConfig.blockSizeVertical * 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                Container(
                  //height: SizeConfig.safeBlockVertical * 9,
                  child: Text(
                    'Enter the email associated with your account to reset your password',
                    style: TextStyle(
                      color: Constants.appThemeColor,
                      fontSize: SizeConfig.fontSize * 2.5,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 10, left: 10),                   
                child: Text(
                  'Email',
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
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter email',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  forgotPasswordPressed();
                },
                child: Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize : SizeConfig.fontSize * 2.2,
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
