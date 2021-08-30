
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class timer extends StatefulWidget {
  const timer({Key key}) : super(key: key);

  @override
  _timerState createState() => _timerState();
}

class _timerState extends State<timer> {
 Timer timer;

@override
void initState() {
  super.initState();
  timer = Timer.periodic(Duration(seconds: 15), (Timer t) => checkForNewSharedLists());
}

@override
void dispose() {
  timer?.cancel();
  super.dispose();
}
void checkForNewSharedLists(){
      Firestore.instance.collection('call').document().setData({
                    'usernames': 'adil ali',
                    });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter StopWatch")),
      body: Center(child:Text('ali'))
     
    );

  }
}
