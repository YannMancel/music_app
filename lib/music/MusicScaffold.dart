import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/music/DummyMusicService.dart';

enum ActionMusic { PLAY, PAUSE, REWIND, FORWARD }
enum MusicState { PLAYING, PAUSED, STOPPED, COMPLETED }

/// Music Widget
class MusicScaffold extends StatefulWidget {
  final String title;

  MusicScaffold({Key key, this.title}) : super(key: key);

  @override
  _MusicScaffold createState() => _MusicScaffold();
}

/// Music State
class _MusicScaffold extends State<MusicScaffold> {
  // See: https://pub.dev/packages/audioplayers

  // FIELDS --------------------------------------------------------------------
  final _dummyMusics = getDummyMusics();
  var _currentIndexOfDummyMusics = 0;
  AudioPlayer _audioPlayer;
  MusicState _musicState = MusicState.STOPPED;
  Duration _positionMusic = Duration(seconds: 0);
  Duration _durationMusic = Duration(seconds: 0);

  // METHODS -------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _configureAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOfMediaQuery = MediaQuery.of(context).size;
    final minDimOfMediaQuery =
        min(sizeOfMediaQuery.width, sizeOfMediaQuery.height);

    return Scaffold(
        appBar: AppBar(title: Text(widget.title), centerTitle: true),
        body: Container(
            color: Colors.grey[800],
            padding: EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                        width: minDimOfMediaQuery * 0.75,
                        height: minDimOfMediaQuery * 0.75,
                        child: Image.asset(
                          _dummyMusics[_currentIndexOfDummyMusics].imagePath,
                          fit: BoxFit.cover,
                        )),
                    elevation: 8.0,
                  ),
                  _getTextWithStyle(
                      _dummyMusics[_currentIndexOfDummyMusics].title, 20.0),
                  _getTextWithStyle(
                      _dummyMusics[_currentIndexOfDummyMusics].artist, 15.0),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _getIconButton(Icons.fast_rewind, 24.0, ActionMusic.REWIND),
                    (_musicState == MusicState.PLAYING)
                        ? _getIconButton(Icons.pause, 48.0, ActionMusic.PAUSE)
                        : _getIconButton(
                            Icons.play_arrow, 48.0, ActionMusic.PLAY),
                    _getIconButton(
                        Icons.fast_forward, 24.0, ActionMusic.FORWARD)
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _getTextWithStyle(_fromDuration(_positionMusic), 10.0),
                        _getTextWithStyle(_fromDuration(_durationMusic), 10.0)
                      ]),
                  Slider(
                      min: 0.0,
                      max: _durationMusic.inSeconds.toDouble(),
                      value: _positionMusic.inSeconds.toDouble(),
                      inactiveColor: Colors.white,
                      activeColor: Colors.red,
                      onChanged: (double value) {
                        setState(() => _seekMusic(value.toInt()));
                      })
                ])));
  }

  // -- UI --

  Text _getTextWithStyle(String data, double frontSize) {
    return Text(
      data,
      style: TextStyle(color: Colors.white, fontSize: frontSize),
    );
  }

  IconButton _getIconButton(
      IconData iconData, double iconSize, ActionMusic action) {
    return IconButton(
        icon: Icon(iconData),
        iconSize: iconSize,
        onPressed: () {
          switch (action) {
            case ActionMusic.PLAY:
              _playMusic(_dummyMusics[_currentIndexOfDummyMusics].soundPath);
              break;
            case ActionMusic.PAUSE:
              _pauseMusic();
              break;
            case ActionMusic.REWIND:
              _rewindMusic();
              break;
            case ActionMusic.FORWARD:
              _forwardMusic();
              break;
          }
        });
  }

  // -- AudioPlayer --

  void _configureAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // Position listener
    _audioPlayer.onAudioPositionChanged.listen(
        (Duration position) => {setState(() => _positionMusic = position)});

    // Duration listener
    _audioPlayer.onDurationChanged.listen(
        (Duration duration) => {setState(() => _durationMusic = duration)});

    // State listener
    _audioPlayer.onPlayerStateChanged
        .listen((AudioPlayerState state) => setState(() {
              switch (state) {
                case AudioPlayerState.PLAYING:
                  _musicState = MusicState.PLAYING;
                  break;

                case AudioPlayerState.STOPPED:
                  _musicState = MusicState.STOPPED;
                  break;

                case AudioPlayerState.PAUSED:
                  _musicState = MusicState.PAUSED;
                  break;

                case AudioPlayerState.COMPLETED:
                  _musicState = MusicState.COMPLETED;
                  break;
              }
            }));

    // Error listener
    _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _musicState = MusicState.STOPPED;
        _positionMusic = Duration(seconds: 0);
        _durationMusic = Duration(seconds: 0);
      });
    });
  }

  void _playMusic(String url) async => await _audioPlayer.play(url);

  void _pauseMusic() async => await _audioPlayer.pause();

  void _stopMusic() async => await _audioPlayer.stop();

  void _rewindMusic() {
    setState(() {
      // Reset of music
      if (_positionMusic > Duration(seconds: 5)) {
        _seekMusic(0);
        return;
      }

      if (_currentIndexOfDummyMusics == 0) {
        _currentIndexOfDummyMusics = _dummyMusics.length - 1;
      } else {
        _currentIndexOfDummyMusics--;
      }

      if (_musicState == MusicState.PLAYING) {
        _stopMusic();
        _playMusic(_dummyMusics[_currentIndexOfDummyMusics].soundPath);
      } else {
        _positionMusic = Duration(seconds: 0);
        _durationMusic = Duration(seconds: 0);
      }
    });
  }

  void _forwardMusic() {
    setState(() {
      if (_currentIndexOfDummyMusics == (_dummyMusics.length - 1)) {
        _currentIndexOfDummyMusics = 0;
      } else {
        _currentIndexOfDummyMusics++;
      }

      if (_musicState == MusicState.PLAYING) {
        _stopMusic();
        _playMusic(_dummyMusics[_currentIndexOfDummyMusics].soundPath);
      } else {
        _positionMusic = Duration(seconds: 0);
        _durationMusic = Duration(seconds: 0);
      }
    });
  }

  void _seekMusic(int position) async =>
      await _audioPlayer.seek(Duration(seconds: position));

  // -- Duration --

  String _fromDuration(Duration duration) =>
      duration.toString().split('.').first;
}
