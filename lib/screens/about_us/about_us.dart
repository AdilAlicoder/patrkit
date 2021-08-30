import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkit_app/screens/Call_Ui/incomingcall.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class AboutUs extends StatefulWidget {

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
   
   @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        centerTitle: true,
        title: Text(
          'About Us',
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
          margin: EdgeInsets.only(left: 20, right:20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: SizeConfig.blockSizeVertical * 25,
                child: Image.asset('assets/logo2.png',)
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  'Hello, we’re JustParkIt\nWe exist to bridge the communication gap between drivers on the road.\n\nYou can now contact any driver who blocks your car in. I mean who’s got time to search for the owner of that car, right? We all know how frustrating that can be.\n\nDownload our app to order your unique Qr code and join a network of drivers Already communicating through our platform! We\'ll have your QR code printed and posted to your front door, ready for use',
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 2.2
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}