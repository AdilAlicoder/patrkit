import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/services/payment-service.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class OrderScreen extends StatefulWidget {

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  
  TextEditingController fullName = new TextEditingController(text: Constants.appUser.fullName);
  TextEditingController streetAddress = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController postCode = new TextEditingController();
  bool isLoading = false;
  bool blueSelected = true;
  double codeAmount = 3.95;

 //*******ONE SIGNAL*******\\
  String _debugLabelString = "";
  bool _requireConsent = false;// CHANGE THIS parameter to true if you want to test GDPR privacy consent
  String userId = "";

  @override
  void initState() {
    super.initState();
    StripeService.init();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);
    var settings = { OSiOSSettings.autoPrompt: false, OSiOSSettings.promptBeforeOpeningPushUrl: true};
    
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print(changes.to.status);
      //Constants.showErrorAlert(changes.to.status.toString(), changes.to.jsonRepresentation().toString());
    });

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
          "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
          print(_debugLabelString);
      });
    });

     OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
            "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
            print(_debugLabelString);
      });
      if(Constants.callBackFunction != null)
        Constants.callBackFunction();
      //NotificationHandler.checkRecievedNotification(notification);
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
      //NotificationHandler.checkNotificationFromTopBarOrAppClose(result.notification);
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) async {
      //print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
      print("Status Changed to = " + changes.to.subscribed.toString());
      if(changes.to.subscribed) {
        userId = changes.to.userId;
        await AppUser.saveOneSignalUserID(userId);
        EasyLoading.dismiss();
        saveToken();
      }
    });

    print(Constants.oneSignalId);
    await OneSignal.shared.init(Constants.oneSignalId, iOSSettings: settings);
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    //bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    if(status.subscriptionStatus.subscribed)
    {
      EasyLoading.dismiss(); // show hud
      userId = status.subscriptionStatus.userId;
      String isSavedToken = await AppUser.getOneSignalUserId();
      if(isSavedToken.isNotEmpty)
        setState(() => isLoading = false);//print('userid already saved');
      else
        saveToken();
    }
     else{
      print('userid already saved');
    }
  }

  void saveToken() async {
    setState(() => isLoading = true);
    EasyLoading.show(status: 'Please wait',maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().updateOneSignalUserID(userId);
    EasyLoading.dismiss();
    setState(() => isLoading = false);
    if (result['Status'] == "Success") {
      
    } 
    else {
      Constants.showDialog(result['ErrorMessage']);
    }    
  }

  void orderNow() async {
    if (fullName.text.isEmpty)
      Constants.showDialog("Please enter full name");
    else if (streetAddress.text.isEmpty)
      Constants.showDialog("Please enter address");
    else if (city.text.isEmpty)
      Constants.showDialog("Please enter city");
    else if (postCode.text.isEmpty)
      Constants.showDialog("Please enter post code");
    else
    {       
      int orderTotal = (codeAmount * 100).toInt();
      setState(() => isLoading = true);  
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await StripeService.payWithNewCard(amount: orderTotal.toString(), currency: 'GBP', fullName: fullName.text, address : streetAddress.text, city: city.text, postCode: postCode.text, qrStickerColor: (blueSelected) ? "Blue QR Sticker" :  "Black QR Sticker");
      //dynamic result = await AppController().orderQrCodeNow(fullName.text, streetAddress.text, city.text, postCode.text);
      EasyLoading.dismiss();
      setState(() => isLoading = false); 
      if (result['Status'] == "Success") 
      {
        Constants.showDialog('Your order is successfully placed. Your unique QR code will be sent at your mentioned address in a few days. Thank you');
        fullName.text = '';
        streetAddress.text = '';
        city.text = '';
        postCode.text = '';
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
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),                   
                alignment: Alignment.center,
                child: Text(
                  'Order ParkIt Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize : SizeConfig.fontSize * 3.5,
                    color: Constants.appThemeColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2,),                   
                height: SizeConfig.blockSizeVertical * 20,
                //color: Colors.yellow,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        //color: Colors.blue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              //color: Colors.black,
                              child: CircleAvatar(
                                radius: SizeConfig.blockSizeVertical * 6,
                                child: Image.asset('assets/q1.png'),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [       
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical * 3,
                                      width: SizeConfig.blockSizeVertical * 3,
                                      child: Checkbox(
                                        value: blueSelected, 
                                        onChanged: (val){
                                          setState(() {
                                            blueSelected = true;
                                            codeAmount = 3.95;
                                          });
                                        }
                                      )
                                    ),
                                    SizedBox(width: 10,),
                                    Container(
                                      child: Text(
                                        'Blue : £3.95',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: SizeConfig.fontSize * 2,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )                       
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //color: Colors.blue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              //color: Colors.black,
                              child: CircleAvatar(
                                radius: SizeConfig.blockSizeVertical * 6,
                                child: Image.asset('assets/q2.png'),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [       
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical * 3,
                                      width: SizeConfig.blockSizeVertical * 3,
                                      child: Checkbox(
                                        value: !blueSelected, 
                                        onChanged: (val){
                                          setState(() {
                                            blueSelected = false;
                                            codeAmount = 4.95;
                                          });
                                        }
                                      )
                                    ),
                                    SizedBox(width: 10,),
                                    Container(
                                      child: Text(
                                        'Black : £4.95',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: SizeConfig.fontSize * 2,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )   
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1, left: 10),                   
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
                  'Address',
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
                    controller: streetAddress,
                    style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                    //inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z 0-9\u00c0-\u017e]"))],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter address',
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
                  'City',
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
                    controller: city,
                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z \u00c0-\u017e]"))],
                    style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter city',
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
                  'Postcode',
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
                    controller: postCode,
                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z 0-9\u00c0-\u017e]"))],
                    style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      hintText: 'Enter post code',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      fillColor: Colors.grey[100],
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: orderNow,
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
                  height: SizeConfig.blockSizeVertical * 7,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'ORDER NOW',
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
    );
  }
}