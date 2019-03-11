import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';

MediaControl playControl = MediaControl(
    androidIcon: 'drawable/ic_action_play_arrow',
    label: 'Play',
    action: MediaAction.play,
  );
  MediaControl pauseControl = MediaControl(
    androidIcon: 'drawable/ic_action_pause',
    label: 'Pause',
    action: MediaAction.pause,
  );
  MediaControl stopControl = MediaControl(
    androidIcon: 'drawable/ic_action_stop',
    label: 'Stop',
    action: MediaAction.stop,
  );

  Podcast podcastTocando;

class AudioBloc extends BlocBase { 

  var _controllerDuration = BehaviorSubject<Duration>();
  Stream get outDuration => _controllerDuration.stream;

  var _controllerPosition = BehaviorSubject<Duration>();
  Stream get outPosition => _controllerPosition.stream;

  var _controllerState = BehaviorSubject<AudioPlayerState>();
  Stream get outState => _controllerState.stream;

  var _controllerSeek = BehaviorSubject<double>();
  Stream get outSeek => _controllerSeek.stream;

  AudioBloc() {
    AudioPlayer.logEnabled = false;

    _controllerPosition.listen((val) => podcastTocando.position = val);
    _controllerPosition.addStream(audioPlayer.onAudioPositionChanged);
    _controllerDuration.addStream(audioPlayer.onDurationChanged);
    _controllerState.addStream(audioPlayer.onPlayerStateChanged);
    //audioPlayer.completionHandler = () => hide();
  }

 /* Future<void> hide() async {
    try {
      await MediaNotification.hide();
    } on PlatformException {}
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author);
    } on PlatformException {}
  }*/

  void changeState() {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.pause();
    } else if (audioPlayer.state == AudioPlayerState.PAUSED) {
      audioPlayer.resume();
    }
  }

  void tocar([Podcast podcast]) {
    if (podcast == null) {
      audioPlayer.resume();
    } else if (podcastTocando == null || podcastTocando != podcast) {
      audioPlayer.stop();
      podcastTocando = podcast;
      audioPlayer.play(podcast.url, position: podcastTocando.position);
      _controllerDuration.add(null);
      _controllerPosition.add(null);
      _controllerSeek.add(null);
      //show(podcastTocando.title, 'Hipsters Ponto Tech');
    } else if (podcastTocando == podcast) {
      audioPlayer.resume();
    }
  }

  void pausar() {
    audioPlayer.pause();
  }

  void stop() {
    audioPlayer.stop();
    podcastTocando = null;
  }

  void changeSeek(double position) {
    //_controllerSeek.add(position);
    print(position);
  }

  void seek(double position) {
    _controllerSeek.add(null);
    audioPlayer.seek(Duration(seconds: position.toInt()));
  }

  void back(int seconds) {
    _controllerPosition
        .add(Duration(seconds: _controllerPosition.value.inSeconds - seconds));
    audioPlayer.seek(_controllerPosition.value);
  }

  void forward(int seconds) {
    _controllerPosition
        .add(Duration(seconds: _controllerPosition.value.inSeconds + seconds));
    audioPlayer.seek(_controllerPosition.value);
  }

  @override
  void dispose() {
    _controllerPosition.close();
    _controllerDuration.close();
    _controllerState.close();
    _controllerSeek.close();
   // hide();
  }
}

void _backgroundAudioPlayerTask() async {
  CustomAudioPlayer player = CustomAudioPlayer();
  AudioServiceBackground.run(
    onStart: player.run,
    onPlay: player.play,
    onPause: player.pause,
    onStop: player.stop,
    onClick: (MediaButton button) => player.playPause(),
  );
}

class CustomAudioPlayer {
  Completer _completer = Completer();
  AudioPlayer audioPlayer = new AudioPlayer();
  Future<void> run() async {
    MediaItem mediaItem = MediaItem(
        id: 'audio_1',
        album: 'Sample Album',
        title: 'Sample Title',
        artist: 'Sample Artist');

    AudioServiceBackground.setMediaItem(mediaItem);

    var playerStateSubscription = audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      stop();
    });
    play();
    await _completer.future;
    playerStateSubscription.cancel();
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      pause();
    else
      play();
  }

  void play() {
    audioPlayer.play(podcast.url, position: podcastTocando.position);
    AudioServiceBackground.setState(
      controls: [pauseControl, stopControl],
      basicState: BasicPlaybackState.playing,
    );
  }

  void pause() {
    audioPlayer.pause();
    AudioServiceBackground.setState(
      controls: [playControl, stopControl],
      basicState: BasicPlaybackState.paused,
    );
  }

  void stop() {
    audioPlayer.stop();
    AudioServiceBackground.setState(
      controls: [],
      basicState: BasicPlaybackState.stopped,
    );
    _completer.complete();
  }
}
