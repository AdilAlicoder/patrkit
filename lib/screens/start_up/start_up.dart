import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parkit_app/screens/login_screen/login_screen.dart';
import 'package:parkit_app/screens/register_screen/register_screen.dart';
//import 'package:parkit_app/screens/login_screen/login_screen.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class StartUp extends StatefulWidget {
  @override
  _StartUpState createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {

  @override
  void initState() {
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/start_bg.png',
            ),
            fit: BoxFit.cover
          )
        ),
        child: Container(
          margin: EdgeInsets.only( left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8, bottom:  SizeConfig.blockSizeHorizontal * 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                  
              InkWell(
                onTap: (){
                  Get.to(RegisterScreen());
                },
                child: Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  width: SizeConfig.blockSizeHorizontal * 80,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Text(
                        'SIGNUP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize : SizeConfig.fontSize * 1.8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: (){
                  Get.to(LoginScreen());
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                  height: SizeConfig.blockSizeVertical * 7,
                  width: SizeConfig.blockSizeHorizontal * 80,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Text(
                        'ALREADY HAVE AN ACCOUNT?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize : SizeConfig.fontSize * 1.8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               
            ],
          ),
        ),
      ),
    );
  }
}