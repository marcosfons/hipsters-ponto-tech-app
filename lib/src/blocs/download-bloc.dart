

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

  var _controllerDownloading = BehaviorSubject<Map<Podcast, Download>>.seeded({});
  Stream<Map<Podcast, Download>> get outDownloading => _controllerDownloading.stream;

  DownloadsBloc() {
    getApplicationDocumentsDirectory().then((val) {
      downloads = Directory('${val.path}/podcasts/');
      if(!downloads.existsSync())
        downloads.createSync();
    });
  }

  void remove(Podcast podcast) {
    _controllerDownloading.value.remove(podcast);
    _controllerDownloading.add(_controllerDownloading.value);
    podcast.downloaded = false;
    File file = File('${downloads.path}${podcast.title}.mp3');
    if(file.existsSync()) {
      file.deleteSync();
    }
  }

  void cancel(Podcast podcast) {
    _controllerDownloading.value[podcast].cancelar();
    _controllerDownloading.value.remove(podcast);
    _controllerDownloading.add(_controllerDownloading.value);
  }

  void download(Podcast podcast) {
    Download download = Download();
    _controllerDownloading.value[podcast] = download;
    _controllerDownloading.add(_controllerDownloading.value);
    dio.download(
      podcast.url, 
      '${downloads.path}${podcast.title}.mp3',
      onReceiveProgress: (int received, int total) {
        _controllerDownloading.value[podcast]?.progress = received / total * 100;
        _controllerDownloading.add(_controllerDownloading.value);
      },
      cancelToken: download.cancelToken
    ).then((Response val) {
      _controllerDownloading.value.remove(podcast);
      _controllerDownloading.add(_controllerDownloading.value);
      podcast.downloaded = true;
    }).catchError((error) {
      if(!download.cancelToken.isCancelled)
        remove(podcast);
    });
  }

  @override
  void dispose() {
    _controllerDownloading.close();
  }
}