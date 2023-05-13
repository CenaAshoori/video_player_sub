import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_sub/controller/video_controller.dart';
import 'package:video_player_sub/my_slider.dart';
import 'package:video_player_sub/video_player.dart';

import 'file_picker.dart';

void main() {
  Get.put(MyVideoController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video Player',
      // home: FilePickerDemo(),
      home: MyVideoPlayer(),
      // home: DurationSlider(),
    );
  }
}
