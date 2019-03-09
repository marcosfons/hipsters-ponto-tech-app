

import 'dart:convert';
import 'dart:io';

import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_feed.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Data {

  static const String URL = 'https://hipsters.tech/feed/podcast/';


  Future<List<Podcast>> getPodcasts() async {
    var response = await http.get(URL);
    if(response.statusCode == 200)
      return RssFeed.parse(response.body).items.map((item) => Podcast.fromRSS(item)).toList().cast<Podcast>();
    else
      throw('Erro ao fazer o request\nCódigo do erro: ${response.statusCode}');
  }

  void salvarPodcasts(List<Podcast> podcasts) {
    getApplicationDocumentsDirectory().then((path) {
      File file = File(path.path + 'podcasts.json');
      if(!file.existsSync())
        file.createSync();
      file.writeAsStringSync(json.encode(podcasts.map((podcast) => podcast.toJson()).toList()));
    });
  }

  Future<List<Podcast>> lerPodcasts() async {
    Directory path = await getApplicationDocumentsDirectory();
    File file = File(path.path + 'podcasts.json');
    if(file.existsSync())
      return json.decode(file.readAsStringSync()).map((podcast) => Podcast.fromJson(podcast)).toList().cast<Podcast>();
    else
      return [];
  }

}