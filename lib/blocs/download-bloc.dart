

import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:hipsters_ponto_tech/src/models/Download.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsBloc extends BlocBase {
  
  Directory downloads;
  Dio dio = Dio();

  var _controllerDownloading = BehaviorSubject<Map<Podcast, double>>();
  Stream<Map<Podcast, double>> get outDownloading => _controllerDownloading.stream;

  DownloadsBloc() {
    getApplicationDocumentsDirectory().then((val) {
      downloads = Directory('${val.path}/podcasts/');
      if(!downloads.existsSync())
        downloads.createSync();
    });
  }

  void download(Podcast podcast) {
    _controllerDownloading.value[podcast] = 0;
    _controllerDownloading.add(_controllerDownloading.value);
    dio.download(
      podcast.url, 
      '${downloads.path}${podcast.title}',
      onReceiveProgress: (int received, int total) {
        _controllerDownloading.value[podcast] = received / total * 100;
        _controllerDownloading.add(_controllerDownloading.value);
      }
    );
  }

  @override
  void dispose() {
    _controllerDownloading.close();
  }
}