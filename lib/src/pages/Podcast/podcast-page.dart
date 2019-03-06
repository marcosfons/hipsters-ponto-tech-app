

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:hipsters_ponto_tech/blocs/audio-bloc.dart';
import 'package:hipsters_ponto_tech/blocs/download-bloc.dart';
import 'package:hipsters_ponto_tech/src/models/Podcast.dart';
import 'package:hipsters_ponto_tech/src/widgets/hero.dart';
import 'package:hipsters_ponto_tech/src/widgets/player-widget.dart';

class PodcastPage extends StatefulWidget {
  final Podcast podcast;
  const PodcastPage({Key key, this.podcast}) : super(key: key);
  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  @override
  Widget build(BuildContext context) {
    final AudioBloc audioBloc = BlocProviderList.of<AudioBloc>(context);
    final DownloadsBloc downloadsBloc = BlocProviderList.of<DownloadsBloc>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(237, 237, 237, 1),
      appBar: AppBar(
        title: Text('teste'),
        backgroundColor: Colors.grey[800],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  height: MediaQuery.of(context).size.width / 2.6,
                  child: Row(
                    children: <Widget>[
                      Image.network(widget.podcast.image,fit: BoxFit.fitHeight,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(height: 2.5,),
                              Text('Duração:   ${widget.podcast.pubDate}', style: TextStyle(fontSize: 16, color: Color.fromRGBO(70, 83, 97, 1)),),
                              Text('Tamanho: ${widget.podcast.length.toString()}', style: TextStyle(fontSize: 16, color: Color.fromRGBO(70, 83, 97, 1)),),
                              Text('Duração:   ${widget.podcast.duration}', style: TextStyle(fontSize: 16, color: Color.fromRGBO(70, 83, 97, 1)),),
                              Container(height: 2.5,)
                            ],
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 14, top: 8, bottom: 4),
                  child: Text(
                    widget.podcast.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 83, 97, 1)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left:20, right: 20),
                  width: double.infinity,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder<AudioPlayerState>(
                          stream: audioBloc.outState,
                          builder: (context, snapshot) {
                            if(snapshot.data == AudioPlayerState.PLAYING && audioBloc.podcastTocando == widget.podcast) {
                              return FlatButton.icon(
                                icon: Icon(Icons.pause,size: 14,),
                                label: Text('Pausar', style: TextStyle(fontSize: 10),),
                                color: Colors.blue,
                                onPressed: audioBloc.pausar,
                              );
                            }
                            return FlatButton.icon(
                              icon: Icon(Icons.play_arrow,size: 14,),
                              label: Text('Reproduzir', style: TextStyle(fontSize: 10),),
                              color: Colors.blue,
                              onPressed: () => audioBloc.tocar(widget.podcast)
                            );
                          }
                        ),
                      ),
                      Container(width: 5,),
                      Expanded(
                        child: FlatButton.icon(
                          icon: Icon(Icons.file_download, size: 14,),
                          label: Text('Download', style: TextStyle(fontSize: 10),),
                          color: Colors.white,
                          onPressed: () => downloadsBloc.download(widget.podcast)
                        ),
                      )
                    ],
                  ),
                ),
                /*
                StreamBuilder<Duration>(
                  stream: audioBloc.outDuration,
                  builder: (BuildContext context, AsyncSnapshot<Duration> snapshotDuration) {
                    if(snapshotDuration.hasData)
                      return StreamBuilder<Duration>(
                        stream: audioBloc.outPosition,
                        builder: (BuildContext context, AsyncSnapshot<Duration> snapshotPosition) {
                          if(snapshotPosition.hasData)
                            return Slider(
                              value: snapshotPosition.data.inSeconds.toDouble(),
                              max: snapshotDuration.data.inSeconds.toDouble(),
                              onChangeEnd: audioBloc.seek,
                            );
                          return Container();
                        },
                      );
                    return Container();
                  }
                ),
                */
                Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 14, top: 16, bottom: 16),
                  child: Text(widget.podcast.descricao, style: TextStyle(fontSize: 14),),
                )
              ],
            ),
          ),
          PlayerWidget()
        ],
      ),
    );

    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.grey[800],
            expandedHeight: MediaQuery.of(context).size.width - 24,
            flexibleSpace: FlexibleSpaceBar(
              background: PhotoHero(
                tag: widget.podcast.image,
                child: Image.network(widget.podcast.image, fit:BoxFit.contain),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () => audioBloc.tocar(widget.podcast),
                    ),
                    IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () => audioBloc.pausar(),
                    ),
                  ],
                ),
              ),
              StreamBuilder<Duration>(
                stream: audioBloc.outDuration,
                builder: (BuildContext context, AsyncSnapshot<Duration> snapshotDuration) {
                  if(snapshotDuration.hasData)
                    return StreamBuilder<Duration>(
                      stream: audioBloc.outPosition,
                      builder: (BuildContext context, AsyncSnapshot<Duration> snapshotPosition) {
                        if(snapshotPosition.hasData)
                          return Slider(
                            value: snapshotPosition.data.inSeconds.toDouble(),
                            max: snapshotDuration.data.inSeconds.toDouble(),
                            onChangeEnd: audioBloc.seek,
                            onChanged: (value) {},
                          );
                        return Container();
                      },
                    );
                  return Container();
                }
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 14, top: 16, bottom: 16),
                child: Text(widget.podcast.descricao, style: TextStyle(fontSize: 14),),
              )
            ]),
          )
        ],
      ),
    );
  }
}