
import 'package:flutter/material.dart';
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
  @override

  HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bloc = HomeBloc();
    bloc.loadPodcasts();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    bloc.save();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(237, 237, 237, 1),
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
            child: StreamBuilder<List<Podcast>>(
              stream: bloc.outPodcasts,
              builder: (BuildContext context, AsyncSnapshot<List<Podcast>> snapshot) {
                if(snapshot.hasData) 
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10, left: 6, right:6),
                          child: Card(
                            child: Container(
                              height: MediaQuery.of(context).size.width / 3,
                              child: Row(
                                children: <Widget>[
                                  PhotoHero(
                                    tag: snapshot.data[index].image,
                                    child: Image.network(snapshot.data[index].image,
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
                                            '${snapshot.data[index].pubDate} - ${snapshot.data[index].duration}',
                                            style: TextStyle(color: Color.fromRGBO(180, 180, 180, 1), fontSize: 12),
                                          ),
                                          Container(height: 2.5),
                                          Text(
                                            snapshot.data[index].title,
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
                          ),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext) => PodcastPage(podcast: snapshot.data[index],))),
                      );
                    },
                  );
                else if(snapshot.hasError)
                  return Center(child: Text(snapshot.error.toString()),);
                else
                  return Center(child: CircularProgressIndicator(),);
              },
            ),
          ),
          PlayerWidget()
        ],
      )
    );
  }
}