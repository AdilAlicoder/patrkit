import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportedUsers extends StatefulWidget {

  @override
  _ReportedUsersState createState() => _ReportedUsersState();
}

class _ReportedUsersState extends State<ReportedUsers> {
  bool isLoading = false;
  List<Map> reportedUsersList = new List<Map>();

  @override
  void initState() {
    super.initState();
    getAllReportedUsers();
  }

  void getAllReportedUsers() async {
    reportedUsersList.clear();
    setState(() => isLoading = true);  
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAllReportedUsersList(reportedUsersList);
    EasyLoading.dismiss();
    setState(() => isLoading = false); 
    if (result['Status'] == "Success") 
    {
      print(reportedUsersList.length);
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
    setState(() {});
  }

  

  void blockConfirmationDialog(String userID, int index) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        title: Text('Block user'),
        content: Text("Are you sure you want to block user ?"),
        actions: [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          FlatButton(
            onPressed: () {
              blockUser(userID, index);
              Get.back();
            },
            child: Text('Yes')
          )
        ],
      )
    );
  }  

  void blockUser(String userID, int index) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().blockUser(userID);
    EasyLoading.dismiss();
    setState(() => isLoading = false); 
    if (result['Status'] == "Success") 
    {
      Constants.showDialog('User has been successfully blocked');
      reportedUsersList.removeAt(index);
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          'Reported Users',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize : SizeConfig.fontSize * 2.7,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: (reportedUsersList.length == 0) ? Container(
        height: SizeConfig.blockSizeVertical* 80,
        //color: Colors.red,
        child: Center(
          child: Text(
            'No Reported Users',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: SizeConfig.fontSize * 2.5, color: Colors.grey[600]),
          ),
        ),
      ): Container(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: reportedUsersList.length,
          itemBuilder: (context, i){
            return reportedUserCell(reportedUsersList[i], i);
          },
        ),
      ),
    );
  }

  Widget reportedUserCell(Map reportedData, int index){

    DateTime rDate = reportedData['reportedTime'].toDate();
    String formattedDate = DateFormat('hh:mm aa dd-MM-yyyy').format(rDate);
    print(formattedDate);

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
                  onTap: (){
                    blockConfirmationDialog(reportedData['reportedUserId'], index);
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(
                      child: Text(
                        'Block User',
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
                  onTap: () async {
                    launch('tel://${reportedData['reportedPhoneNumber']}');
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(
                      child: Text(
                        'Call Reported User',
                          style: TextStyle(
                          fontSize : SizeConfig.fontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 5, right: 5, top: 12),
              child: Text(
                'Name : ${reportedData['reportedFullName']}',
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
                  '${reportedData['reportReason']}',
                    style: TextStyle(
                    fontSize : SizeConfig.fontSize * 2.2,
                    //fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 5, top: 10),
                child: Text(
                  'Reported By : ${reportedData['reportedByFullName']}',
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
                  'Reported By # : ${reportedData['reportedByPhoneNumber']}',
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
                  'Reported On : $formattedDate',
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