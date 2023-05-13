import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:subtitle/subtitle.dart';
import 'package:video_player/video_player.dart';

class MyVideoController extends GetxController {
  late SubtitleController subcontroller;
  final controller = VideoPlayerController.network(
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    // closedCaptionFile: SubtitleData('https://example.com/subtitles.vtt'),
  );

  var url = Uri.parse(
      'https://brenopolanski.github.io/html5-video-webvtt-example/MIB2-subtitles-pt-BR.vtt');

  MyVideoController() {
    subInit();
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
  Duration get duration => _duration.value;
  set duration(Duration dur) {
    _duration(dur);
  }

  Future<void> subInit() async {
    isInitialized = false;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
    );
    if (result != null) {
      final myFile = result.files.single.bytes;

      String decodedData =
          LineSplitter().convert(utf8.decode(myFile!)).join('\n');

      print(decodedData);
      subcontroller = SubtitleController(
          provider: SubtitleProvider.fromString(
              data: decodedData,
              type: subtitleTypeSelector(result.files.single.extension)));

      await subcontroller.initial();
      isInitialized = true;
    }
  }

  SubtitleType subtitleTypeSelector(String? type) {
    print(type);
    switch (type) {
      case 'srt':
        return SubtitleType.srt;
      case 'vtt':
        return SubtitleType.vtt;
      default:
        return SubtitleType.srt;
    }
  }

  Future<void> init() async {
    subInit();
  }
}
