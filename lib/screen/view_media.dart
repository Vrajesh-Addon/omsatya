import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:video_player/video_player.dart';
import 'package:rxdart/rxdart.dart';

import '../widgets/general_widgets.dart';

class ViewMedia extends StatefulWidget {
  final String? audioUrl;
  final String? imageUrl;
  final String? videoUrl;

  const ViewMedia({
    super.key,
    this.audioUrl,
    this.videoUrl,
    this.imageUrl,
  });

  @override
  State<ViewMedia> createState() => _ViewMediaState();
}

class _ViewMediaState extends State<ViewMedia> {
  late VideoPlayerController _controller;

  late AudioPlayer _audioPlayer;
  late Stream<DurationState> _durationStateStream;

  bool _isPlaying = false;
  bool _isCompleted = false;

  @override
  void initState() {
    if(widget.videoUrl != null) {
      initVideoPlayer();
    }
    if(widget.audioUrl != null){
      initAudioPlayer();
    }
    super.initState();
  }

  @override
  void dispose() {
    if(widget.videoUrl != null){
     _controller.dispose();
    }
    if(widget.audioUrl != null){
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  initAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    _audioPlayer.setLoopMode(LoopMode.off);

    // _audioPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
    _audioPlayer.setUrl(widget.audioUrl!);

    // Combine streams to monitor progress
    _durationStateStream = Rx.combineLatest2<Duration, Duration?, DurationState>(
      _audioPlayer.positionStream,
      _audioPlayer.durationStream,
          (position, duration) => DurationState(position: position, total: duration ?? Duration.zero),
    );

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        setState(() {
          _isPlaying = false; // Reset play button when audio completes
          _audioPlayer.seek(Duration.zero); // Optionally seek back to the beginning
          _audioPlayer.stop();
        });
      }
    });
  }

  void _togglePlayPauseAudio() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  initVideoPlayer() {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
        // Uri.parse("https://indiazonaportal.addonwebtech.com/public/uploads/all/OS55zVXYvepVGKnzhFrDxceyBPEDZCg8qf9of1dZ.mp4"),
      )..initialize().then((_) {
        _controller.play();
        setState(() {});
      });

      _controller.addListener(() {
        setState(() {
          _isPlaying = _controller.value.isPlaying;

          if (_controller.value.position >= _controller.value.duration &&
              !_controller.value.isPlaying) {
            _isCompleted = true;
          }
        });
      });
  }

  void _togglePlayPauseVideo() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
    } else {
      _controller.play();
      _isPlaying = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.videoUrl == null ? CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ) : null,
      body: SafeArea(
        child: widget.imageUrl != null
            ? buildImageSection()
            : widget.videoUrl != null
                ? Stack(
         children: [
           buildVideoSection(),
           Positioned(
             top: 10,
             left: 10,
             child: Card(
               margin: EdgeInsets.zero,
               color: Colors.white,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(50),
               ),
               child: GestureDetector(
                 onTap: () => Navigator.of(context).pop(),
                 child: const Padding(
                   padding: EdgeInsets.all(AppDimen.paddingSmall),
                   child: Icon(Icons.arrow_back_rounded),
                 ),
               ),
             ),
           ),
         ],
        )
                : buildAudioSection(),
      ),
    );
  }

  buildVideoSection() {
    return _controller.value.isInitialized
        ? Stack(
          alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              Positioned.fill(
                child: IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause
                        : _isCompleted
                            ? Icons.play_arrow
                            : Icons.play_arrow,
                  ),
                  onPressed: _togglePlayPauseVideo,
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 20,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 10,
              //   child: Container(
              //     color: Colors.red,
              //     width: MediaQuery.of(context).size.width,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         IconButton(
              //           icon: const Icon(Icons.replay_10),
              //           onPressed: () {
              //             _controller.seekTo(
              //               _controller.value.position - const Duration(seconds: 10),
              //             );
              //           },
              //         ),
              //         IconButton(
              //           icon: const Icon(Icons.forward_10),
              //           onPressed: () {
              //             _controller.seekTo(
              //               _controller.value.position + const Duration(seconds: 10),
              //             );
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  buildAudioSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<bool>(
            stream: _audioPlayer.playingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return IconButton(
                iconSize: 64,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPauseAudio,
              );
            },
          ),
          // Progress Bar
          StreamBuilder<DurationState>(
            stream: _durationStateStream,
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final progress = durationState?.position ?? Duration.zero;
              final total = durationState?.total ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    min: 0.0,
                    max: total.inMilliseconds.toDouble(),
                    value: progress.inMilliseconds.toDouble().clamp(0.0, total.inMilliseconds.toDouble()),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(milliseconds: value.round()));
                    },
                  ),
                  Text(
                    '${_formatDuration(progress)} / ${_formatDuration(total)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  buildImageSection() {
    return Center(
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: widget.imageUrl!,
        progressIndicatorBuilder: (context, string, progress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorWidget: (context, url, error) => Image.asset(
          AppImages.placeholder,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState({required this.position, required this.total});
}
