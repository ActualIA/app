import 'dart:developer';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatefulWidget {
  final int transcriptId;
  final double size;
  final Future<void> Function()? onPressed;

  const PlayButton(
      {super.key,
      required this.transcriptId,
      this.size = 40.0,
      this.onPressed});

  @override
  State<PlayButton> createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> {
  final AudioPlayer audioPlayer = AudioPlayer();

  late PlayerState _playerState;
  @override
  void initState() {
    super.initState();
    _playerState = PlayerState.stopped;
  }

  @override
  void deactivate() {
    audioPlayer.pause();
    super.deactivate();
  }

  PlayerState get playerState {
    return _playerState;
  }

  @override
  Widget build(BuildContext context) {
    final newsViewModel = Provider.of<NewsViewModel>(context);
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.onPlayerComplete.listen((s) async {
      setState(() {
        _playerState = PlayerState.completed;
      });
      await audioPlayer.release();
    });
    audioPlayer.onPlayerStateChanged
        .listen((s) => log("$s", level: Level.INFO.value));

    return IconButton(
        icon: _playerState == PlayerState.playing
            ? Icon(
                Icons.pause_circle_outline,
                size: widget.size,
                color: THEME_BUTTON,
              )
            : Icon(
                Icons.play_circle_outline,
                size: widget.size,
                color: THEME_BUTTON,
              ),
        onPressed: () async {
          if (widget.onPressed != null) {
            await widget.onPressed!();
          }
          switch (_playerState) {
            case PlayerState.playing:
              await audioPlayer.pause();
              setState(() => _playerState = PlayerState.paused);
              break;
            case PlayerState.paused:
              await audioPlayer.resume();
              setState(() => _playerState = PlayerState.playing);
              break;
            case PlayerState.completed:
            case PlayerState.stopped:
            case PlayerState.disposed:
              Source? source =
                  await newsViewModel.getAudioSource(widget.transcriptId);
              if (source != null) {
                await playAudio(audioPlayer, source);
                setState(() => _playerState = PlayerState.playing);
                break;
              }
          }
        });
  }

  Future<void> playAudio(AudioPlayer audioPlayer, Source source) async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await audioPlayer.play(source);
      });
    } catch (e) {
      log("Error playing audio: $e", level: Level.WARNING.value);
    }
  }
}
