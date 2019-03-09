

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:media_notification/media_notification.dart';
import 'package:flutter/services.dart';

class AudioBloc extends BlocBase {
  
  AudioPlayer audioPlayer;

  Podcast podcastTocando;

  var _controllerDuration = BehaviorSubject<Duration>();
  Stream get outDuration => _controllerDuration.stream;

  var _controllerPosition = BehaviorSubject<Duration>();
  Stream get outPosition => _controllerPosition.stream;

  var _controllerState = BehaviorSubject<AudioPlayerState>();
  Stream get outState => _controllerState.stream;

  var _controllerSeek =BehaviorSubject<double>();
  Stream get outSeek => _controllerSeek.stream;


  AudioBloc() {
    AudioPlayer.logEnabled = false;
    audioPlayer =AudioPlayer();
    
    _controllerPosition.listen((val) => podcastTocando.position = val);
    _controllerPosition.addStream(audioPlayer.onAudioPositionChanged);
    _controllerDuration.addStream(audioPlayer.onDurationChanged);
    _controllerState.addStream(audioPlayer.onPlayerStateChanged);
    audioPlayer.completionHandler = () => hide();

    MediaNotification.setListener('pause', () {
      pausar();
    });

    MediaNotification.setListener('play', () {
      tocar();
    });
    
    MediaNotification.setListener('next', () {
      forward(10);
    });
    
    MediaNotification.setListener('prev', () {
      back(10);
    });

    MediaNotification.setListener('select', () {
      print('select');
    });
    
  }

  Future<void> hide() async {
    try {
      await MediaNotification.hide();
    } on PlatformException {

    }
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author);
    } on PlatformException {

    }
  }

  void changeState() {
    if(audioPlayer.state ==AudioPlayerState.PLAYING) {
      audioPlayer.pause();
    } else if(audioPlayer.state ==AudioPlayerState.PAUSED) {
      audioPlayer.resume();
    }
  }

  void tocar([Podcast podcast]) {
    if(podcast == null) {
      audioPlayer.resume();
    }
    else if(podcastTocando == null || podcastTocando != podcast) {
      audioPlayer.stop();
      podcastTocando = podcast;
      audioPlayer.play(podcast.url, position: podcastTocando.position);
      _controllerDuration.add(null);
      _controllerPosition.add(null);
      _controllerSeek.add(null);
      show(podcastTocando.title, 'Hipsters Ponto Tech');
    } else if(podcastTocando == podcast) {
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
    _controllerPosition.add(Duration(seconds: _controllerPosition.value.inSeconds - seconds));
    audioPlayer.seek(_controllerPosition.value);
  }

  void forward(int seconds) {
    _controllerPosition.add(Duration(seconds: _controllerPosition.value.inSeconds + seconds));
    audioPlayer.seek(_controllerPosition.value);
  }

  @override
  void dispose() {
    _controllerPosition.close();
    _controllerDuration.close();
    _controllerState.close();
    _controllerSeek.close();
    hide();
  }
}