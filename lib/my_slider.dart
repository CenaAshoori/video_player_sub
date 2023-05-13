import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_sub/controller/video_controller.dart';

class DurationSlider extends StatefulWidget {
  final Duration initialDuration;
  final void Function(Duration)? onDurationChanged;

  const DurationSlider(
      {Key? key, this.initialDuration = Duration.zero, this.onDurationChanged})
      : super(key: key);

  @override
  _DurationSliderState createState() => _DurationSliderState();
}

class _DurationSliderState extends State<DurationSlider> {
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialDuration.inSeconds.toDouble();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    MyVideoController vc = Get.find();
    return Scaffold(
      body: Column(
        children: [
          Text(_formatDuration(Duration(seconds: _value.toInt()))),
          Slider(
            min: 0,
            max: 3600,
            value: _value,
            label: _formatDuration(Duration(seconds: _value.toInt())),
            onChanged: (double newValue) {
              if (vc.initialized) {
                setState(() {
                  _value = newValue;
                });

                if (widget.onDurationChanged != null) {
                  widget.onDurationChanged ??
                      (Duration(seconds: newValue.toInt()));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
