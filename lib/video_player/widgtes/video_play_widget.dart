import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final ValueNotifier<bool> isPlaying;

  VideoPlayWidget({
    super.key,
    required this.controller,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: GestureDetector(
            onTap: () {
              Duration currentPosition = controller.value.position;
              Duration targetPosition =
                  currentPosition - const Duration(seconds: 30);
              controller.seekTo(targetPosition);
            },
            child: const Icon(
              Icons.replay_30,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (isPlaying.value) {
              controller.pause();
            } else {
              controller.play();
            }
            isPlaying.value = !isPlaying.value;
          },
          child: Icon(
            isPlaying.value ? Icons.pause : Icons.play_arrow_sharp,
            color: Colors.white,
            size: 30,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: GestureDetector(
            onTap: () {
              Duration currentPosition = controller.value.position;
              Duration targetPosition =
                  currentPosition + const Duration(seconds: 30);
              controller.seekTo(targetPosition);
            },
            child: const Icon(
              Icons.forward_30,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
