
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:hipsters_ponto_tech/src/blocs/download-bloc.dart';
import 'package:hipsters_ponto_tech/src/models/Download.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:hipsters_ponto_tech/src/pages/Podcast/podcast-page.dart';
import 'package:hipsters_ponto_tech/src/pages/home/home-bloc.dart';
import 'package:hipsters_ponto_tech/src/widgets/hero.dart';
import 'package:hipsters_ponto_tech/src/widgets/player-widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  int selectedPage = 0;
  // HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // bloc.save();
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    // bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeBloc bloc =BlocProviderList.of<HomeBloc>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(237, 237, 237, 1),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            title: Text('Podcasts')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download),
            title: Text('Downloads')
          )
        ],
        currentIndex: selectedPage,
        onTap: (index) => setState(() => selectedPage = index),
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Image.asset('assets/images/logo.png', height: AppBar().preferredSize.height - 10,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: bloc.loadPodcasts,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: bloc.save,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: selectedPage == 0 ? StreamBuilder<List<Podcast>>(
              stream: bloc.outPodcasts,
              builder: (BuildContext context, AsyncSnapshot<List<Podcast>> snapshot) {
                if(snapshot.hasData) 
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.only(top: 10, left: 6, right:6),
                        child: Card(
                          child: PodcastCard(podcast: snapshot.data[index],)
                        )
                      );
                    },
                  );
                else if(snapshot.hasError)
                  return Center(child: Text(snapshot.error.toString()),);
                else
                  return Center(child: CircularProgressIndicator(),);
              },
            )
            : DownloadsWidget()
          ),
          PlayerWidget()
        ],
      )
    );
  }
}

class PodcastCard extends StatelessWidget {

  final Podcast podcast;

  const PodcastCard({
    Key key, this.podcast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: MediaQuery.of(context).size.width / 3,
        child: Row(
          children: <Widget>[
            PhotoHero(
              tag: podcast.image,
              child: Image.network(podcast.image,
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 3,
                fit: BoxFit.fitWidth,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${podcast.pubDate} - ${podcast.duration}',
                      style: TextStyle(color: Color.fromRGBO(180, 180, 180, 1), fontSize: 12),
                    ),
                    Container(height: 2.5),
                    Text(
                      podcast.title,
                      softWrap: true,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color.fromRGBO(85, 98, 112, 1)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PodcastPage(podcast: podcast,))),
    );
  }
}


class DownloadsWidget extends StatefulWidget {
  @override
  _DownloadsWidgetState createState() => _DownloadsWidgetState();
}

class _DownloadsWidgetState extends State<DownloadsWidget> {
  @override
  Widget build(BuildContext context) {
    final DownloadsBloc downloadsBloc = BlocProviderList.of<DownloadsBloc>(context);
    final HomeBloc homeBloc = BlocProviderList.of<HomeBloc>(context);
    return StreamBuilder<List<Podcast>>(
      stream: homeBloc.outPodcasts,
      builder: (BuildContext context, AsyncSnapshot<List<Podcast>> snapshotPodcasts) {
        return StreamBuilder<Map<Podcast, Download>>(
          stream: downloadsBloc.outDownloading,
          builder: (BuildContext context, AsyncSnapshot<Map<Podcast, Download>> snapshotDownloads) {
            if(snapshotDownloads.hasData && snapshotPodcasts.hasData) {
              return ListView.builder(
                itemCount: snapshotDownloads.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(top: 10, left: 6, right:6),
                        child: Card(
                          child: PodcastCard(podcast: snapshotDownloads.data.keys.toList()[index],)
                        )
                      ),
                    ],
                  );
                },
              );
            }
            return Center(child: Text('Não tem nenhum download'),);
          },
        );
      }
    );
  }
}