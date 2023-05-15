import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_sub/controller/translation_controller.dart';
import 'package:video_player_sub/controller/video_controller.dart';
import 'package:video_player_sub/main_videoplayer.dart';
import 'package:video_player_sub/my_slider.dart';
import 'package:video_player_sub/video_player.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  DartVLC.initialize();

  Get.put(MyVideoController());
  Get.put(TranslationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Player',
      // home: FilePickerDemo(),
      // home: DartVLCExample(),
      home: VideoPlayerWidget(),
      // home: DurationSlider(),
    );
  }
}
