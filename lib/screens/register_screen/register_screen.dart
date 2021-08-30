import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:get/get.dart';
import 'package:parkit_app/screens/home_screen/home_screen.dart';
import 'package:parkit_app/screens/login_screen/login_screen.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  TextEditingController userName = new TextEditingController();
  TextEditingController fullName = new TextEditingController();
  TextEditingController phoneNumber = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  void registerPressed() async {
    if (userName.text.isEmpty)
      Constants.showDialog("Please enter user name");
    else if (fullName.text.isEmpty)
      Constants.showDialog("Please enter full name");
    else if (phoneNumber.text.isEmpty)
      Constants.showDialog("Please enter phone number");
    else if (email.text.isEmpty)
      Constants.showDialog("Please enter email address");
    else if (!GetUtils.isEmail(email.text))
      Constants.showDialog("Please enter valid email address");
    else if (password.text.isEmpty)
      Constants.showDialog("Please enter password");
    else if (password.text.length < 8)
      Constants.showDialog("Please enter password with minimum 8 charcaters");
    else
    { 
      setState(() => isLoading = true);  
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().signUpUser(userName.text, fullName.text, phoneNumber.text, email.text, password.text, Constants.encryptionKey);
      EasyLoading.dismiss();
      setState(() => isLoading = false); 
      if (result['Status'] == "Success") 
      {
        Constants.appUser = result["User"];
        Get.offAll(HomeScreen(0));
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
      
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        centerTitle: true,
        title: Text(
          'Sign Up',
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
          margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8, top: SizeConfig.blockSizeHorizontal * 5,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0),                   
                alignment: Alignment.center,
                child: Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize : SizeConfig.fontSize * 3.5,
                    color: Constants.appThemeColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),                   
                alignment: Alignment.center,
                child: Text(
                  'create your JustParkIt account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize : SizeConfig.fontSize * 2,
                    color: Constants.appThemeColor,
                    //fontWeight: FontWeight.bold
                  ),
                ),
              ),
              
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                child: Text(
                  'Username',
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
                    controller: userName,
                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z 0-9\u00c0-\u017e]"))],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter username',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                child: Text(
                  'Full Name',
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
                    controller: fullName,
                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z \u00c0-\u017e]"))],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter full name',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                child: Text(
                  'Mobile Number',
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
                    controller: phoneNumber,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(15)],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter mobile number',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
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

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                child: Text(
                  'Password',
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
                    controller: password,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter password',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, bottom: SizeConfig.blockSizeVertical * 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Checkbox(
                        activeColor: Constants.appThemeColor,
                        value: showPassword, 
                        onChanged: (val){
                          setState(() {
                            showPassword = val;
                          });
                        }
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      child: Text(
                        'Show password',
                        style: TextStyle(
                          color: Constants.appThemeColor,
                          fontSize: SizeConfig.fontSize * 1.6
                        ),
                      ),
                    ),
                  ],
                ),
               ),

            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: SizeConfig.safeBlockVertical * 12,
        margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8, bottom: SizeConfig.blockSizeVertical * 2),
        //color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                registerPressed();
              },
              child: Container(
                height: SizeConfig.blockSizeVertical * 7,
                decoration: BoxDecoration(
                  color: Constants.appThemeColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: Text(
                    'SIGNUP',
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

            GestureDetector(
              onTap: (){
                Get.to(LoginScreen());
              },
              child: Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                child: Text(
                  'ALREADY HAVE AN ACCOUNT ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize : SizeConfig.fontSize * 1.8,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}