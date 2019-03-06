

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:hipsters_ponto_tech/src/services/Data.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BlocBase {

  Data data = Data();

  var _controllerPodcasts = BehaviorSubject<List<Podcast>>();
  Stream<List<Podcast>> get outPodcasts => _controllerPodcasts.stream;

  HomeBloc() {
    loadPodcasts();
  }

  Future loadPodcasts() async {
    data.lerPodcasts()
      .then((result) => _controllerPodcasts.add(result))
      .catchError((error) => _controllerPodcasts.addError(error))
      .whenComplete(() async {
        data.getPodcasts().then((podcastsWeb) {
          podcastsWeb.asMap().forEach((index, podcast) {
            if (_controllerPodcasts.value.contains(podcast) == false){
              _controllerPodcasts.value.insert(index, podcast);
            }
          });
          _controllerPodcasts.add(_controllerPodcasts.value);
        });
      });
  }

  Future save() async {
    data.salvarPodcasts(_controllerPodcasts.value);
  }

  @override
  void dispose() {
    data.salvarPodcasts(_controllerPodcasts.value);
    _controllerPodcasts.close();
  }
}