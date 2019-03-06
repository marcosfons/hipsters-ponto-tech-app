

import 'package:dio/dio.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:rxdart/rxdart.dart';

class Download {
  CancelToken cancelToken;
  double progress = 0;
  
  Download() {
    cancelToken = CancelToken();
  }

  void cancelar() {
    cancelToken.cancel();
  }

}