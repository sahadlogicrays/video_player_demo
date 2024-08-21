import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_demo/constants/App_strings.dart';
import 'package:video_player_demo/video_player/widgtes/lock_button_widget.dart';
import 'package:video_player_demo/video_player/widgtes/video_play_widget.dart';
import 'package:video_player_demo/video_player/widgtes/volume_slider_widget.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  final ValueNotifier<bool> _isLocked = ValueNotifier(false);
  final ValueNotifier<bool> _showControls = ValueNotifier(false);
  final ValueNotifier<double> _currentVolume = ValueNotifier(0.0);
  bool _isInitialized = false;
  Timer? _hideTimer;

  void _onVideoTapped() {
    _showControls.value = !_showControls.value;

    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 7), () {
      _showControls.value = false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(AppStrings.videoUrl),
    )..initialize().then((_) {
        _isInitialized = true;
        _isPlaying.value = true;
        _controller.play();
        setState(() {});
      });

    VolumeController().listener((volume) {
      setState(() => _currentVolume.value = volume);
    });
    _controller.addListener(_listener);
  }

  void _listener() {
    _controller.setVolume(_currentVolume.value);
    _isMuted.value = _currentVolume.value > 0 ? false : true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: true,
      child: Scaffold(
        body: _isInitialized
            ? OrientationBuilder(
                builder: (context, orientation) {
                  double topPosition;
                  double volumeHeight;
                  if (orientation == Orientation.portrait) {
                    topPosition = 0;
                    volumeHeight = 100;
                  } else {
                    topPosition = MediaQuery.of(context).size.height / 4.5;
                    volumeHeight = 150;
                  }

                  final currentPosition = _controller.value.position;
                  final duration = _controller.value.duration;

                  return GestureDetector(
                    onTap: _onVideoTapped,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (orientation == Orientation.portrait) ...[
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(
                              _controller,
                            ),
                          ),
                        ] else ...[
                          VideoPlayer(
                            _controller,
                          )
                        ],
                        if (_showControls.value && _isLocked.value) ...[
                          ValueListenableBuilder<bool>(
                            valueListenable: _isPlaying,
                            builder: (context, isPlaying, child) {
                              return isPlaying
                                  ? const SizedBox.shrink()
                                  : const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 80,
                                    );
                            },
                          ),
                          VolumeSliderWidget(
                              isMuted: _isMuted,
                              currentVolume: _currentVolume,
                              controller: _controller,
                              topPosition: topPosition,
                              volumeHeight: volumeHeight),
                          Positioned(
                            bottom: 25,
                            left: 10,
                            right: 10,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                final box =
                                    context.findRenderObject() as RenderBox;
                                final localPosition =
                                    box.globalToLocal(details.globalPosition);
                                final progress =
                                    localPosition.dx / box.size.width;
                                final position =
                                    _controller.value.duration * progress;
                                _controller.seekTo(position);
                              },
                              child: Container(
                                height: 8,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: Colors.white,
                                    backgroundColor: Colors.grey.shade300,
                                    bufferedColor: Colors.grey.shade500,
                                  ),
                                  padding:
                                      EdgeInsets.zero, // Remove default padding
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 10,
                            child: Text(
                              _formatDuration(currentPosition),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 10,
                            child: Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          VideoPlayWidget(
                              controller: _controller, isPlaying: _isPlaying)
                        ],
                        LockButton(
                            isLocked: _isLocked, showControls: _showControls)
                      ],
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    VolumeController().removeListener();
    _controller.removeListener(_listener);
    _controller.dispose();
    _isPlaying.dispose();
    _isMuted.dispose();
    super.dispose();
  }
}
