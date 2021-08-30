import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkit_app/screens/chatlist_screen/chatlist_screen.dart';
import 'package:parkit_app/screens/home_screen/home_screen.dart';
import 'package:parkit_app/screens/wrapper/wrapper.dart';
import 'package:parkit_app/src/pages/call.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MHomePage extends StatefulWidget {
  @override
  _MHomePageState createState() => _MHomePageState();
}

class _MHomePageState extends State<MHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  String username;
  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String channelname;
  String number;
  Timer timer;
  ClientRole _role = ClientRole.Broadcaster;
   Future<void> onJoin() async {
    // update input validation
    audioPlayer.stop();
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
           channelname,
          _role,
          username,
          uid,
        ),
      ),
    );

  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
  Future<void> currentuser() async {
    final User user = await auth.currentUser;
     Firestore.instance
        .collection('call')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot snap) {
      setState(() {
        username = snap['Name'];
        number = snap['Number'];
        uid = user.uid;
        channelname = snap['channelname'];
      });
    });
  }
  @override
  void initState() {
    currentuser();
    final play = AudioCache(fixedPlayer: audioPlayer);
    play.play('iphone.mp3');
    // TODO: implement initState
    super.initState();
   
  }

  Future<void> endcall() async {
     Firestore.instance.collection("call").document(uid).delete();
    audioPlayer.stop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>Wrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      //color: Colors.red,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.black54, Colors.red],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 60, 0, 50),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Incoming Call',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Text(
                username,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CircleAvatar(
                radius: 70,
                child: ClipOval(
                  child: Image.asset(
                    'assets/q1.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: InkWell(
                    onTap: () {
                      onJoin();
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      child: Icon(
                        Icons.phone,
                        color: Colors.red,
                        size: 40,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(35))),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: InkWell(
                    onTap: () {
                  
                      endcall();
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 40,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(35))),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: Container())
          ],
        ),
      ),
    ));
  }
}
