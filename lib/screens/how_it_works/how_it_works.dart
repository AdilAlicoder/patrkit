import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:native_video_view/native_video_view.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class HowItWorks extends StatefulWidget {

  @override
  _HowItWorksState createState() => _HowItWorksState();
}

class _HowItWorksState extends State<HowItWorks> {

  @override
  void initState() {
    super.initState();
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Constants.appThemeColor,
      elevation: 0,
      centerTitle: true,
      title:  Text(
        'How it works',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize : SizeConfig.fontSize * 2.7,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      ),
    ),
    body: Container(
      color: Colors.black,
      alignment: Alignment.center,
        child: NativeVideoView(
          keepAspectRatio: true,
          showMediaController: false,
          onCreated: (controller) {
            controller.setVideoSource(
              'assets/info.mp4',
              sourceType: VideoSourceType.asset,
            );
          },
          onPrepared: (controller, info) {
            controller.play();
          },
          onError: (controller, what, extra, message) {
            print('Player Error ($what | $extra | $message)');
          },
          onCompletion: (controller) {
            print('Video completed');
            Get.back();
          },
          onProgress: (progress, duration) {
            print('$progress | $duration');
          },
        ),
      ),
    );
  }
}
