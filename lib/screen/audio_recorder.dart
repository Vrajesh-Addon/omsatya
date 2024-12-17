import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> with TickerProviderStateMixin {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isRecording = false, isPlaying = false;
  String? recordingPath;
  int currentDuration = 0;
  int recordingDuration = 4;
  int _seconds = 0;
  int _minutes = 0;
  Timer? _timer;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: recordingDuration),
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    _controller.forward(from: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (currentDuration > 0) {
          currentDuration--;
        } else {
          timer.cancel();
          isRecording = false;
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _controller.stop();
    audioRecorder.dispose();
    setState(() {
      currentDuration = recordingDuration;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                text: isRecording ? "Stop" : "Start",
                onPressed: () async {
                  if (isRecording) {
                    String? filePath = await audioRecorder.stop();
                    if (filePath != null) {
                      setState(() {
                        isRecording = false;
                        recordingPath = filePath;
                      });
                    }
                  } else {
                    if (await audioRecorder.hasPermission()) {
                      final Directory appDocumentDir = await getApplicationCacheDirectory();
                      final String filePath = p.join(appDocumentDir.path, "recording.m4a");
                      await audioRecorder.start(const RecordConfig(), path: filePath);
                      setState(() {
                        isRecording = true;
                        recordingPath = null;
                      });
                    }
                  }
                },
              ),
              const FieldSpace(),
              if (recordingPath != null)
                PrimaryButton(
                  text: isPlaying ? "Stop Playing" : "Start Play",
                  onPressed: () async {
                    if(audioPlayer.playing){
                      audioPlayer.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else{
                      await audioPlayer.setFilePath(recordingPath!);
                      audioPlayer.play();
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                ),
              if (recordingPath == null)
                const Text("No Recording Found. :("),
              const FieldSpace(),
              if (recordingPath != null)
              PrimaryButton(text: "Done", onPressed: () async {
                if(recordingPath != null) {
                  final bool? result = await _showBackDialog();
                  if(result!){
                    showMessage("Result 1 ==> $result");
                    if(mounted) {
                      Navigator.of(context).pop(recordingPath);
                    }
                  } else {
                    showMessage("Result 2 ==> $result");
                  }
                }else {
                  AppGlobals.showMessage("Please record the audio", MessageType.error);
                }
              },)
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showBackDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
          const Text("Do you want to use this recording?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(AppString.no),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(AppString.yes),
            ),
          ],
        );
      },
    );
  }
}
