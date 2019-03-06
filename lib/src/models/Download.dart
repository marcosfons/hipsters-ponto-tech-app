

import 'package:dio/dio.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:rxdart/rxdart.dart';

class Download {
  Podcast podcast;
  var _controllerProgress = BehaviorSubject<double>();
  Stream get outProgress => _controllerProgress.stream;

  Download(Podcast podcast) {
    this.podcast = podcast;
  }



}