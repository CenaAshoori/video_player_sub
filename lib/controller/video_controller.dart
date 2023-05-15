import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:subtitle/subtitle.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

class MyVideoController extends GetxController {
  late SubtitleController subcontroller;
  // final controller = VideoPlayerController.network(
  //   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  //   // closedCaptionFile: SubtitleData('https://example.com/subtitles.vtt'),
  // );

  var url = Uri.parse(
      'https://brenopolanski.github.io/html5-video-webvtt-example/MIB2-subtitles-pt-BR.vtt');

  MyVideoController() {
    // subInit();
  }

  var _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;
  set isInitialized(bool isInit) {
    _isInitialized(isInit);
  }

  var _showSubtitles = true.obs;
  bool get showSubtitles => _showSubtitles.value;
  set showSubtitles(bool show) {
    print(show);
    _showSubtitles(show);
  }

  var _duration = Duration(seconds: 0).obs;
  Duration get currentPosition => _duration.value;
  set currentPosition(Duration dur) {
    _duration(dur);
  }

  Future<void> subInit() async {
    isInitialized = false;
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'subtitle',
      extensions: <String>['srt', 'vtt'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file != null) {
      final myFile = File(file.path);
      String decodedData =
          LineSplitter().convert(await myFile.readAsString()).join('\n');

      subcontroller = SubtitleController(
          provider: SubtitleProvider.fromString(
              data: decodedData,
              type: subtitleTypeSelector(path.extension(myFile.uri.path))));

      await subcontroller.initial();
      isInitialized = true;
    }
  }

  SubtitleType subtitleTypeSelector(String? type) {
    print(type);
    switch (type) {
      case '.srt':
        return SubtitleType.srt;
      case '.vtt':
        return SubtitleType.vtt;
      default:
        return SubtitleType.srt;
    }
  }

  Future<void> init() async {
    subInit();
  }
}
