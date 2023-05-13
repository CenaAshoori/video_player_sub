import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_sub/controller/video_controller.dart';

class MyVideoPlayer extends StatelessWidget {
  const MyVideoPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    MyVideoController vc = Get.find();
    final chewieController = ChewieController(
      overlay: Obx(() {
        if (vc.isInitialized)
          return Text(
            vc.subcontroller.durationSearch(vc.duration)?.data ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              backgroundColor: Colors.black54,
            ),
          );
        return Container();
      }),
      videoPlayerController: vc.controller,
      autoPlay: false,
      looping: false,
    );

    vc.controller.addListener(() async {
      vc.duration = (await vc.controller.position)!;
      print(vc.subcontroller.durationSearch(vc.duration));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This method will be called once the whole widget tree has been built.
      // You can put your code here to perform an action after the widget tree is built.
      vc.init();
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          vc.subInit();
        },
      ),
      appBar: AppBar(
        title: Text("Video"),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: vc.controller.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: vc.controller.value.aspectRatio,
                  // child: SubtitleWrapper(
                  //   videoPlayerController: vc.controller,
                  //   subtitleController: vc.subcontroller!,
                  //   subtitleStyle: SubtitleStyle(
                  //     textColor: Colors.white,
                  //     hasBorder: true,
                  //   ),
                  //   videoChild: Chewie(
                  //     controller: chewieController,
                  //   ),
                  // ),
                  child: Chewie(
                    controller: chewieController,
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
