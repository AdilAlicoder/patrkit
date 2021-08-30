
import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:get/get.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/screens/chat_screen/chat_screen.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String qrText = '';
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final cryptor = new PlatformStringCryptor();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: Constants.appThemeColor,
        content: new Text(value, style: TextStyle(color: Colors.white),),
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: SizeConfig.blockSizeHorizontal *100,
        height: SizeConfig.blockSizeVertical *100,
        child: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ],
        ),
      )
    );
  }

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        this.controller.pauseCamera();
        qrText = scanData.code;
        if(qrText.contains('JustParkit*')){
          _scaffoldKey.currentState.hideCurrentSnackBar();
          String code = qrText.replaceFirst('JustParkit*', '');
          //this.controller.resumeCamera();
          openCallOption(code);
        }
        else{
          this.controller.resumeCamera();
          showInSnackBar('This qr code is not linked to JustParkIt app');
        }
        print(qrText);
      });
    });
  }

  Future<void> openCallOption(String code) async {
    String decryptedUserId = await cryptor.decrypt(code, Constants.encryptionKey);
    AppUser qrUser = await AppUser.getUserDetailByUserId(decryptedUserId);
    //await launch('tel:$decryptedNumber');
    if(qrUser != null)
    {
      Get.to(ChatScreen(chatUser: qrUser,));
    }
    else
    { 
      Constants.showDialog('User not found');
    }
    setState(() {
      controller.resumeCamera();
    });
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }
}