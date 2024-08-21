import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeSliderWidget extends StatelessWidget {
  final ValueNotifier<bool> isMuted;
  final ValueNotifier<double> currentVolume;
  final VideoPlayerController controller;
  final double topPosition;
  final double volumeHeight;

  const VolumeSliderWidget({
    super.key,
    required this.isMuted,
    required this.currentVolume,
    required this.controller,
    required this.topPosition,
    required this.volumeHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: topPosition,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: volumeHeight,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: ValueListenableBuilder<double>(
                      valueListenable: currentVolume,
                      builder: (context, vol, child) {
                        return Slider(
                          inactiveColor: Colors.grey,
                          value: vol,
                          min: 0,
                          max: 1,
                          onChanged: (value) {
                            controller.setVolume(value);
                            VolumeController().setVolume(value);
                            value == 0 ? isMuted.value = true : null;
                          },
                        );
                      }),
                ),
              ),
              IconButton(
                icon: ValueListenableBuilder<bool>(
                  valueListenable: isMuted,
                  builder: (context, isMuted, child) {
                    return Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    );
                  },
                ),
                onPressed: () {
                  if (isMuted.value) {
                    controller.setVolume(1.0);
                    VolumeController().setVolume(1.0);
                  } else {
                    currentVolume.value = 0.0;
                    VolumeController().setVolume(0.0);
                  }
                  isMuted.value = !isMuted.value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
