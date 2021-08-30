import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:parkit_app/screens/wrapper/wrapper.dart';

import 'incomingcall.dart';
class Wapper extends StatefulWidget {
  @override
  _WapperState createState() => _WapperState();
}
class _WapperState extends State<Wapper> {
   final FirebaseAuth auth = FirebaseAuth.instance;
  String username;
  String number;
  String channelname;
  String uid;
  var check='null';
  int i=0;
  var data;
  @override
  void initState() {
    super.initState(); 
    Wakelock.enable();
    currentuser();
    check_incomingcall();
  }
   Future<void> currentuser() async {
    final User user = await auth.currentUser;
    print(user.uid);
    Firestore.instance
        .collection('call')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot snap) {
      setState(() {
        data=snap.data();
        username = snap['Name'];
        number = snap['Number'];
        channelname = snap['channelname'];
        uid=user.uid;
        print(username);
        print(number);
        print('yar ha e masla a yar');
      });
    });
     
  }
  void check_incomingcall()  {
    print(data);
    print('gagshydsyudhdhuydhdh');
    if(data==null){
      print('andar a');
      setState(() {
        i=1;
      });
    }
  }
  @override
  Widget build(BuildContext context) {Wakelock.enable();
    // TODO: implement build
    return Scaffold(
      body:Container(
        child:i == 0 ? Container(child:MHomePage()) : Container(child:Wrapper())
      ),
    );
    
  }

}
