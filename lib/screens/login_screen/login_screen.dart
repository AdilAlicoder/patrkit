import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:parkit_app/screens/admin_screens/admin_home.dart';
import 'package:parkit_app/screens/forgot_password/forgot_password.dart';
import 'package:parkit_app/screens/home_screen/home_screen.dart';
import 'package:parkit_app/screens/register_screen/register_screen.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool showPassword = false;
  bool isLoading = false;
  bool stayLogin = true;

  @override
  void initState() {
    super.initState();
  }

  void loginPressed() async {
    if (email.text.isEmpty)
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
      dynamic result = await AppController().signInUser(email.text, password.text);
      EasyLoading.dismiss();
      setState(() => isLoading = false); 
      if (result['Status'] == "Success") 
      {
        Constants.appUser = result["User"];
        if(Constants.appUser.isBlocked)
        {
          Constants.showDialog('Your account have been blocked by admin for chat violation. Thanks');
        }
        else
        {
          if(!Constants.appUser.isAdmin)
            Get.offAll(HomeScreen(0));
          else
            Get.offAll(AdminHomeScreen(0));
        }
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
          'Sign in',
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
                  'Sign in',
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
                  'with your JustParkIt account',
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
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
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

              GestureDetector(
                onTap: (){
                  loginPressed();
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
                  height: SizeConfig.blockSizeVertical * 7,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'SIGN IN',
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
                  Get.to(ForgotPassword());         
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                  child: Text(
                    'FORGOT PASSWORD?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize : SizeConfig.fontSize * 1.8,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  Get.to(RegisterScreen());
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                  child: Text(
                    'SIGN UP',
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
      ),
    );
  }
}