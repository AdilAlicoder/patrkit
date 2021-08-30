import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/screens/admin_screens/admin_home.dart';
import 'package:parkit_app/screens/home_screen/home_screen.dart';
import 'package:parkit_app/screens/onboarding/onboarding.dart';
import 'package:parkit_app/screens/start_up/start_up.dart';
import 'package:parkit_app/screens/Call_Ui/incomingcall.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState(); 
    Wakelock.enable();
    Future.delayed(Duration(seconds: 2), () {
      checkIfUserLoggedIn();
    });
  }

  void checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Constants.appUser = await AppUser.getUserDetail();
    if (Constants.appUser.email.isNotEmpty)
    { 
      Constants.appUser = await AppUser.getLoggedInUserDetail(Constants.appUser);
      if(Constants.appUser == null)
      {
        Get.offAll(StartUp());
        return;
      }
      if(Constants.appUser.isBlocked)
      {
        AppUser.deleteUserAndOtherPreferences();
        Get.offAll(StartUp());
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
      bool isFirstTime = prefs.getBool("IsFirstTimeLaunched") ?? true;
      if(isFirstTime)
      {
        Get.offAll(OnboardingScreen());
        prefs.setBool("IsFirstTimeLaunched", false);
      }
      else
      {
        prefs.setBool("IsFirstTimeLaunched", false);
        Get.offAll(StartUp());
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {Wakelock.enable();
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Image.asset(
            "assets/logo2.png",
            width: SizeConfig.blockSizeHorizontal * 80,
            fit: BoxFit.contain,
          ),
        ),
      )
    );
  }
}
