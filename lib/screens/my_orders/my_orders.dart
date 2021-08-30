import 'dart:io';
import 'dart:typed_data';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:get/get.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrders extends StatefulWidget {

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  ScreenshotController screenshotController = ScreenshotController(); 
  bool isLoading = false;
  List<Map> ordersList = new List<Map>();
  List<Map> filteredList = new List<Map>();
  int _currentSelection = 0;
  Map<int, Widget> _children = {
    0:  Container(padding: EdgeInsets.symmetric(vertical: 5, horizontal: SizeConfig.safeBlockHorizontal *5),child:Text('Pending')),
    1:  Container(padding: EdgeInsets.symmetric(vertical: 5, horizontal: SizeConfig.blockSizeHorizontal *5),child:Text('Completed')),
  };

  @override
  void initState() {
    super.initState();
    getAllOrders();
  }

  void getAllOrders() async {
    ordersList.clear();
    setState(() => isLoading = true);  
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getOrdersList(ordersList);
    EasyLoading.dismiss();
    setState(() => isLoading = false); 
    if (result['Status'] == "Success") 
    {
      print(ordersList.length);
      onSegmentSelected(_currentSelection);
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
    setState(() {});
  }

  void onSegmentSelected(int index){
    if(index ==0)
    {
      filteredList = ordersList.where((i) => i['orderStatus'] == "Pending").toList();
    }
    else
    {
      filteredList = ordersList.where((i) => i['orderStatus'] != "Pending").toList();
    }
    setState(() {});
  }


  void updateOrderStatus(Map order) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        title: Text('Update Order Status'),
        content: Text((order['orderStatus']=="Pending") ? "Set order status to delivered ?" : "Set order status to pending ?"),
        actions: [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          FlatButton(
            onPressed: () {
              String orderNewStatus = (order['orderStatus'] == "Pending") ? "Delivered" : "Pending";
              updateOrderState(order, orderNewStatus);
              Get.back();
            },
            child: Text('Yes')
          )
        ],
      )
    );
  }  

  void updateOrderState(Map order, String orderStatus,) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().updateOrderState(order , orderStatus);
    EasyLoading.dismiss();
    setState(() => isLoading = false); 
    if (result['Status'] == "Success") 
    {
      Constants.showDialog('Order status updated successfully');
      getAllOrders();
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
    setState(() {});
  }


  void showQRCode(AppUser user, Map order) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        title: Text('Download Code'),
        content: Container(
          width: 350,
          height: 310,
          child: Screenshot(
            controller: screenshotController,
            child: BarcodeWidget(
              backgroundColor: Colors.white,
              barcode: Barcode.qrCode(), // Barcode type and settings
              data: '${user.uniquePhoneQrCode}', // Content
              width: 300,
              height: 300,
            ),
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          FlatButton(
            onPressed: () async{
              final directory = (await getExternalStorageDirectory()).path; //from path_provide package
              String fileName = user.userId;
              screenshotController.capture().then((Uint8List image) {
                File file = new File('$directory/$fileName.png');
                file.writeAsBytes(image);
                sendEmail(file, order);
              }).catchError((onError) {
                  print(onError);
              });
              Get.back();
            },
            child: Text('Download')
          )
        ],
      )
    );
  } 

  Future<void> sendEmail(File imageFile, Map order) async {
    String platformResponse ='';
    final MailOptions mailOptions = MailOptions(
      subject: 'QR Code for ${order['fullName']}',
      body: 'Here are user detail\n\nPhone Number : ${order['phoneNumber']}\nStreet Address : ${order['streetAddress']}\nCity : ${order['city']}\nPostal Code : ${order['postCode']}\n\nThanks',
      recipients: ['jpipayments@gmail.com'],
      isHTML: false,
      attachments: [ '${imageFile.path}'],
    );

    final MailerResponse response = await FlutterMailer.send(mailOptions);
    switch (response) {
      case MailerResponse.saved: /// ios only
        platformResponse = 'Mail was saved to draft';
        break;
      case MailerResponse.sent: /// ios only
        platformResponse = 'Mail was sent';
        break;
      case MailerResponse.cancelled: /// ios only
        platformResponse = 'Mail was cancelled';
        break;
      case MailerResponse.android:
        platformResponse = 'Mail not sent';
        break;
      default:
        platformResponse = 'Mail not sent';
        break;
    }

    print(platformResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /*
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          'My Orders',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize : SizeConfig.fontSize * 2.7,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      */
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'All Orders',
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 3,
                    fontWeight: FontWeight.bold,
                    color: Constants.appThemeColor
                  ),
                ),
              ),
            ),

            Container(
              width: SizeConfig.blockSizeHorizontal * 90,
              margin: EdgeInsets.only(bottom: 10),
              child: MaterialSegmentedControl(
                children: _children,
                selectionIndex: _currentSelection,
                borderColor: Constants.appThemeColor,
                selectedColor: Constants.appThemeColor,
                unselectedColor: Colors.white,
                borderRadius: 8.0,
                onSegmentChosen: (index) {
                  setState(() {
                    _currentSelection = index;
                    onSegmentSelected(index);
                  });
                },
              ),
            ),

            (filteredList.length == 0) ? Expanded(
              child: Container(
                height: SizeConfig.blockSizeVertical* 60,
                //color: Colors.red,
                child: Center(
                  child: Text(
                    'No Orders',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: SizeConfig.fontSize * 2.5, color: Colors.grey[600]),
                  ),
                ),
              ),
            ) :
            Expanded(
              child: Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredList.length,
                  itemBuilder: (context, i){
                    return orderCell(filteredList[i], i);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget orderCell(Map order, int index){
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        //height: SizeConfig.safeBlockVertical * 18,
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding:  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
                    AppUser user = await AppUser.getUserDetailByUserId(order['userId']);
                    EasyLoading.dismiss();
                    showQRCode(user, order);
                  },
                  child: Container(
                    width: 60,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(
                      child: Text(
                        'Qr Code',
                          style: TextStyle(
                          fontSize : SizeConfig.fontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    launch('tel://${order['phoneNumber']}');
                  },
                  child: Container(
                    width: 60,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(
                      child: Text(
                        'Call',
                          style: TextStyle(
                          fontSize : SizeConfig.fontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
                 GestureDetector(
                   onTap: (){
                     updateOrderStatus(order);
                   },
                    child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      '${order['orderStatus']}',
                        style: TextStyle(
                        fontSize : SizeConfig.fontSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                ),
                 ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 5, right: 5, top: 2),
              child: Text(
                '${order['fullName']}',
                  style: TextStyle(
                  fontSize : SizeConfig.fontSize * 2.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Text(
                  'Address : ${order['streetAddress']}',
                    style: TextStyle(
                    fontSize : SizeConfig.fontSize * 1.8,
                    //fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Text(
                  'City : ${order['city']}',
                    style: TextStyle(
                    fontSize : SizeConfig.fontSize * 1.8,
                    //fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
             Container(
                margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Text(
                  'Postal Code : ${order['postCode']}',
                    style: TextStyle(
                    fontSize : SizeConfig.fontSize * 1.8,
                    //fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Text(
                  'Qr Sticker : ${order['qrStickerColor']}',
                    style: TextStyle(
                    fontSize : SizeConfig.fontSize * 1.8,
                    //fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),

              
          ]          
        ),
      ),
    );
  }
}