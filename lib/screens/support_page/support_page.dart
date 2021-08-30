import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:parkit_app/screens/support_page/support_detail.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class SupportMessages extends StatefulWidget {

  @override
  _SupportMessagesState createState() => _SupportMessagesState();
}

class _SupportMessagesState extends State<SupportMessages> {

  bool isLoading = false;
  List<Map> supportTickets = new List<Map>();

  @override
  void initState() {
    super.initState();
    getMySupportTickets();
  }

  void getMySupportTickets() async {
    supportTickets.clear();
    setState(() => isLoading = true);  
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getMySupportTickets(supportTickets);
    EasyLoading.dismiss();
    setState(() => isLoading = false); 
    if (result['Status'] == "Success") 
    {
      print(supportTickets.length);
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: (!Constants.appUser.isAdmin) ? AppBar(
        backgroundColor: Constants.appThemeColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Support Tickets',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize : SizeConfig.fontSize * 2.7,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ) : AppBar(
        toolbarHeight: 0,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Support Tickets',
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 3,
                    fontWeight: FontWeight.bold,
                    color: Constants.appThemeColor
                  ),
                ),
              ),
            ),

            (supportTickets.length == 0) ? Expanded(
              child: Container(
                height: SizeConfig.blockSizeVertical* 60,
                //color: Colors.red,
                child: Center(
                  child: Text(
                    'No Messages Yet',
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
                  itemCount: supportTickets.length,
                  itemBuilder: (context, i){
                    return supportCell(supportTickets[i]);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget supportCell(Map supportInformation){
    return GestureDetector(
      onTap: (){
        Get.to(SupportDetail(supportTicket: supportInformation,));
      },
      child: Container(
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
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Icon(Icons.support_agent, size: 30,),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              '${supportInformation['subject']}',
              style: TextStyle(fontSize: SizeConfig.fontSize * 1.9, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            '${supportInformation['message']}',
            maxLines: 2,
            style: TextStyle(fontSize: SizeConfig.fontSize * 1.7, color: Colors.black),
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(top: 10,),
            child: Icon(Icons.arrow_forward_ios, size: 20, color : Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}