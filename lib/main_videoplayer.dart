import 'dart:math';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_sub/translation.dart';
import 'package:window_manager/window_manager.dart';

import 'controller/video_controller.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showPlaylist = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _showSubtitle = false;
  bool _isFullScreen = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isSeeking = false;

  MediaType mediaType = MediaType.file;
  CurrentState current = CurrentState();
  PositionState position = PositionState();
  PlaybackState playback = PlaybackState();
  GeneralState general = GeneralState();
  VideoDimensions videoDimensions = VideoDimensions(0, 0);
  List<Media> medias = <Media>[];
  List<Device> devices = <Device>[];
  TextEditingController controller = TextEditingController();
  TextEditingController metasController = TextEditingController();
  double bufferingProgress = 0.0;
  Media? metadataCurrentMedia;
  Player player = Player(
    id: 1,
    commandlineArguments: [
      '--no-sub-autodetect-file',
      '--sub-track=-1',
    ],
    // videoDimensions: const VideoDimensions(640, 360),
  );
  MyVideoController vc = Get.find();

  @override
  void initState() {
    super.initState();
    player.positionStream.listen((event) async {
      if (event.position != null) {
        vc.currentPosition = event.position!;
      }
    });
    if (mounted) {
      player.currentStream.listen((value) {
        setState(() => current = value);
      });
      player.positionStream.listen((value) {
        setState(() => position = value);
      });
      player.playbackStream.listen((value) {
        setState(() => playback = value);
      });
      player.generalStream.listen((value) {
        setState(() => general = value);
      });
      player.videoDimensionsStream.listen((value) {
        setState(() => videoDimensions = value);
      });
      player.bufferingProgressStream.listen(
        (value) {
          setState(() => bufferingProgress = value);
        },
      );
      player.errorStream.listen((event) {
        debugPrint('libVLC error.');
      });
      devices = Devices.all;
      Equalizer equalizer = Equalizer.createMode(EqualizerMode.live);
      equalizer.setPreAmp(10.0);
      equalizer.setBandAmp(31.25, 10.0);
      player.setEqualizer(equalizer);
    }
  }

  TapGestureRecognizer _createRecognizer(String word, int index) {
    TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () async {
        player.pause();
        await translationDialog(word);
        player.play();
      };

    return recognizer;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          player.playOrPause();
        });
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(child: _playlist(context)),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Video(
              player: player,
              width: double.infinity,
              height: double.infinity,
              // width: isPhone ? 320 : 640,
              // height: isPhone ? 180 : 360,
              volumeThumbColor: Colors.blue,
              volumeActiveColor: Colors.blue,
              showControls: false,
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: !_isPlaying ? 1.0 : 0.0,
              child: const Icon(Icons.play_arrow, size: 60),
            ),
            Container(
              height: 50,
              child: Row(
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: Icon(player.playback.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        player.playOrPause();
                      });
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(!_isMuted ? Icons.volume_up : Icons.volume_off),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      player.setVolume(_isMuted ? 0 : 1);
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.folder_open_rounded),
                    onPressed: () {
                      Get.defaultDialog(content: mp4subWidget());
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(vc.showSubtitles
                        ? Icons.closed_caption
                        : Icons.closed_caption_off),
                    onPressed: () {
                      setState(() {
                        vc.showSubtitles = !vc.showSubtitles;
                      });
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.replay_10),
                    onPressed: () {
                      setState(() {
                        Duration currentPosition = vc.currentPosition;
                        Duration newPosition =
                            currentPosition - Duration(seconds: 15);
                        _position = newPosition <= Duration.zero
                            ? Duration.zero
                            : newPosition;
                        player.seek(_position);
                        _isPlaying = true;
                      });
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.forward_10),
                    onPressed: () {
                      setState(() {
                        Duration currentPosition = vc.currentPosition;
                        Duration newPosition =
                            currentPosition + Duration(seconds: 15);
                        _position =
                            newPosition >= _duration ? _duration : newPosition;
                        player.seek(_position);

                        _isPlaying = true;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Slider(
                        min: 0,
                        max: player.position.duration?.inMilliseconds
                                .toDouble() ??
                            1.0,
                        value: player.position.position?.inMilliseconds
                                .toDouble() ??
                            0.0,
                        onChanged: (double position) {
                          setState(() {});
                          player.seek(
                            Duration(
                              milliseconds: position.toInt(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.playlist_play_rounded),
                    // icon: _showPlaylist
                    //     ? const Icon(Icons.playlist_play_rounded)
                    //     : Stack(children: [
                    //         Icon(Icons.playlist_play_rounded),
                    //         Positioned(
                    //           top: Get.theme.iconTheme.size ?? 12,
                    //           left: 0,
                    //           right: 0,
                    //           child: Transform.rotate(
                    //             angle: -45 *
                    //                 pi /
                    //                 180, // Rotate the line by 45 degrees
                    //             child: Container(
                    //               height: 3,
                    //               color: Color.fromARGB(255, 255, 0, 0),
                    //             ),
                    //           ),
                    //         )
                    //       ]),
                    onPressed: () {
                      setState(() {
                        _scaffoldKey.currentState?.openEndDrawer();
                        // _showPlaylist = !_showPlaylist;
                        // if (_showPlaylist) {
                        // }
                      });
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(_isFullScreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen),
                    onPressed: () {
                      setState(() {
                        _isFullScreen = !_isFullScreen;
                        if (_isFullScreen) {
                          _enterFullScreen();
                        } else {
                          _exitFullScreen();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              child: Obx(() {
                if (vc.isInitialized && vc.showSubtitles) {
                  return RichText(
                    text: TextSpan(
                        children: vc.subcontroller
                            .durationSearch(vc.currentPosition)
                            ?.data
                            .split(' ')
                            .asMap()
                            .entries
                            .map((entry) {
                      int index = entry.key;
                      String word = entry.value;
                      return TextSpan(
                          text: '$word ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            backgroundColor: Colors.black54,
                          ),
                          recognizer: _createRecognizer(word, index));
                    }).toList()),
                  );
                }
                // return Text(
                //   vc.subcontroller
                //           .durationSearch(vc.duration)
                //           ?.data ??
                //       '',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 24.0,
                //     backgroundColor: Colors.black54,
                //   ),
                // );
                return Container();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget mp4subWidget() {
    return Container(
      width: 600,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintStyle: const TextStyle(
                      fontSize: 14.0,
                    ),
                    hintText: 'Enter Media path.',
                  ),
                ),
              ),
              Container(
                width: 152.0,
                child: DropdownButton<MediaType>(
                  value: mediaType,
                  onChanged: (value) => setState(() => mediaType = value!),
                  items: [
                    DropdownMenuItem<MediaType>(
                      value: MediaType.file,
                      child: Text(
                        MediaType.file.toString(),
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DropdownMenuItem<MediaType>(
                      value: MediaType.network,
                      child: Text(
                        MediaType.network.toString(),
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DropdownMenuItem<MediaType>(
                      value: MediaType.asset,
                      child: Text(
                        MediaType.asset.toString(),
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (mediaType == MediaType.file) {
                      medias.add(
                        Media.file(
                          File(
                            controller.text.replaceAll('"', ''),
                          ),
                        ),
                      );
                    } else if (mediaType == MediaType.network) {
                      medias.add(
                        Media.network(
                          controller.text,
                        ),
                      );
                    }
                    setState(() {});
                  },
                  child: Text(
                    'Add to Playlist',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: ElevatedButton(
                  onPressed: () async {
                    const XTypeGroup typeGroup = XTypeGroup(
                      label: 'video',
                      // extensions: <String>['srt', 'vtt'],
                    );
                    final XFile? file = await openFile(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                    controller.text = file?.path ?? '';
                    setState(() {});
                  },
                  child: Text(
                    'Open Video File',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await vc.subInit();
                    setState(() {});
                  },
                  child: Text(
                    'Subtitle',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 8.0,
            color: Colors.transparent,
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => setState(
                  () {
                    player.open(
                      Playlist(medias: medias),
                    );
                    if (player.position.duration != null)
                      _duration = player.position.duration!;
                  },
                ),
                child: Text(
                  'Open into Player',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                onPressed: () {
                  setState(() => medias.clear());
                },
                child: Text(
                  'Clear the list',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _enterFullScreen() async {
    WindowManager.instance.setFullScreen(true);
    // await _controller.pause();
    // await _controller.setVolume(0);
    // await _controller.play();
    // await _controller.setLooping(true);
    // await _controller.play();
    // await _controller.setFullscreen(true);
    setState(() {});
  }

  void _exitFullScreen() async {
    WindowManager.instance.setFullScreen(false);
    setState(() {});
    // await _controller.setFullscreen(false);
  }

  Widget _playlist(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(4.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16.0, top: 16.0),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Playlist manipulation.'),
                  Divider(
                    height: 12.0,
                    color: Colors.transparent,
                  ),
                  Divider(
                    height: 12.0,
                  ),
                ],
              ),
            ),
            Container(
              height: 456.0,
              child: ReorderableListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                onReorder: (int before, int after) async {
                  // [ReorderableListView] in Flutter is buggy.
                  // The [onReorder] callback receives incorrect indices when the [children] are re-ordered.
                  // Workaround : https://stackoverflow.com/a/54164333/12825435
                  // Issue      : https://github.com/flutter/flutter/issues/24786
                  if (after > current.medias.length) {
                    after = current.medias.length;
                  }
                  if (before < after) after--;
                  player.move(
                    before,
                    after,
                  );
                  setState(() {});
                },
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: List.generate(
                  current.medias.length,
                  (int index) => ListTile(
                    key: Key(index.toString()),
                    leading: Text(
                      index.toString(),
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    title: Container(
                      padding: const EdgeInsets.only(right: 56.0),
                      child: Text(
                        current.medias[index].resource,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ),
                    subtitle: Text(
                      current.medias[index].mediaType.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                  growable: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
