import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:parkit_app/screens/login_screen/login_screen.dart';
import 'package:parkit_app/screens/start_up/start_up.dart';
import 'package:parkit_app/utils/constants.dart';

class OnboardingScreen extends StatefulWidget {

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final onboardingPagesList = [
    PageModel(
      image: Image.asset('assets/logo2.png',),
      info:Text(
        'To contact anyone who has blocked your car',
        style: TextStyle(
          color: Constants.appThemeColor,
          fontSize: 16.0,
          wordSpacing: 1,
          letterSpacing: 1.2,
        )
      ),
      title: Text(
        'Scan QR Code', 
        style: TextStyle(
          color: Constants.appThemeColor,
          fontSize: 23.0,
          wordSpacing: 1,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        )
      ),
    ),
    PageModel(
      image: Image.asset('assets/logo2.png',),
      info:Text(
        'By placing an order and sticking it on your car',
        style: TextStyle(
          color: Constants.appThemeColor,
          fontSize: 16.0,
          wordSpacing: 1,
          letterSpacing: 1.2,
        )
      ),
      title: Text(
        'Generate QR Code', 
        style: TextStyle(
          color: Constants.appThemeColor,
          fontSize: 23.0,
          wordSpacing: 1,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        )
      ),
    ),
    PageModel(
      image: Image.asset('assets/logo2.png',),
      info:Text(
        'No more worrying about parking issue',
        style: TextStyle(
          color: Constants.appThemeColor,
          fontSize: 16.0,
          wordSpacing: 1,
          letterSpacing: 1.2,
        )
      ),
      title: Text(
        'MOVE FREELY',
        style: TextStyle(
          color: Constants.appThemeColor,
          fontSize: 23.0,
          wordSpacing: 1,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        )
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/start_bg.png"),
          fit: BoxFit.cover,
        )
        ),
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Onboarding(

          background: Colors.white,
          proceedButtonStyle: ProceedButtonStyle(
            proceedButtonRoute: (context) {
              return Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => StartUp(),
                ),
                (route) => false,
              );
            },
          ),
          pages: onboardingPagesList,
          indicator: Indicator(
            indicatorDesign: IndicatorDesign.polygon(
              polygonDesign: PolygonDesign(
                polygon: DesignType.polygon_circle,
              )
            ),
            activeIndicator: ActiveIndicator(color: Colors.grey, borderWidth: 1),
            closedIndicator: ClosedIndicator(color: Constants.appThemeColor, borderWidth: 1),
            
            /*
            indicatorDesign: IndicatorDesign.line(
              lineDesign: LineDesign(
                lineType: DesignType.line_uniform,
                lineWidth: 30,
                lineSpacer: 100
              ),
            )
            */
          ),
        ),
      ),
    );
  }
}