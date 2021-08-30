import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parkit_app/model/app_user.dart';

class Constants {
  static final Constants _singleton = new Constants._internal();
  static String appName = "Just Park It";
  static AppUser appUser;
  static bool isUserSignedIn = false;
  static bool isFirstTimeAppLaunched = true;
  static bool isEnglishLanguage = true;
  static Color appThemeColor = Colors.lightBlue;
  static String oneSignalId = "f829acce-24da-424d-bbb4-ac4079d75e9e";
  static String encryptionKey = "hNdQLRnSYhf2gA8sPKOKCg==:cGyVoNxGf0c1xarY7lPFkT8hCDQqOf1kBT/YUCMLhdw=";
  static Function callBackFunction;

  factory Constants() {
    return _singleton;
  }

  Constants._internal();

  static void showDialog(String message) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        title: Text(appName),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }  

  static bool isLink(String url){
    bool validURL = Uri.parse(url).isAbsolute;
    return validURL;
  }
}
