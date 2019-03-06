
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:hipsters_ponto_tech/blocs/audio-bloc.dart';

class PlayerWidget extends StatefulWidget {
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> with SingleTickerProviderStateMixin{

  AnimationController controller;
  Cubic cubico = Cubic(0.8, 0, 1, 0.3);
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 120), lowerBound: 0, upperBound: 1);
  }

  String formatPosition(Duration position) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }
    String twoDigitMinutes = twoDigits(position.inMinutes.remainder(Duration.minutesPerHour));
    String twoDigitSeconds = twoDigits(position.inSeconds.remainder(Duration.secondsPerMinute));
    String hours = position.inHours > 0 ? '${position.inHours}:' : '';
    return "$hours$twoDigitMinutes:$twoDigitSeconds";
  }



  @override
  Widget build(BuildContext context) {
    final AudioBloc bloc = BlocProviderList.of<AudioBloc>(context);
    return StreamBuilder<AudioPlayerState>(
      stream: bloc.outState,
      builder: (BuildContext context, AsyncSnapshot<AudioPlayerState> snapshotState) {
        if(snapshotState.hasData) {
          if(snapshotState.data == AudioPlayerState.PLAYING || snapshotState.data ==AudioPlayerState.PAUSED) {
            return AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget child) {
                return GestureDetector(
                  onVerticalDragUpdate: (details) {
                    controller.value -= details.primaryDelta / (MediaQuery.of(context).size.height / 2 * 0.81);
                  },
                  onVerticalDragEnd: (details) {
                    if (controller.value > 0.5) {
                      controller.forward();
                    } else {
                      controller.reverse();
                    }
                  },
                  child: Container(
                    height: controller.value * 180 + 53,
                    color: Colors.grey[800],
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.network(
                              bloc.podcastTocando.image,
                              height: 53,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0, top: 2, bottom: 2),
                                child: Text(bloc.podcastTocando.title, style: TextStyle(color: Colors.grey[100]),),
                              ),
                            ),
                            controller.value < 0.5
                              ? Opacity(
                                  opacity: Curves.easeOutCirc.transform(controller.value * 2) * -1 + 1,
                                  child: IconButton(
                                    icon: Icon(snapshotState.data ==AudioPlayerState.PLAYING
                                      ? Icons.pause_circle_outline
                                      : Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 28
                                    ),
                                    onPressed: bloc.changeState
                                  )
                                )
                              : Opacity(
                                  opacity: Curves.easeInCirc.transform(controller.value * 2 - 1),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 28
                                    ),
                                    onPressed: () {},
                                  )
                                )
                          ],
                        ),
                        Expanded(
                          child: Opacity(
                            opacity: Curves.easeInCirc.transform(controller.value) * 1,
                            child: Column(
                              children: <Widget>[
                                Expanded(child: Container(),),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.replay_10),
                                        onPressed: () => bloc.back(10),
                                        iconSize: 30,
                                        color: Colors.white,
                                      ),
                                      Container(width: 10,),
                                      IconButton(
                                        icon: Icon(
                                          bloc.audioPlayer.state ==AudioPlayerState.PLAYING
                                            ? Icons.pause_circle_outline
                                            : Icons.play_circle_outline,
                                        ),
                                        iconSize: 55,
                                        color: Colors.white,
                                        onPressed: bloc.changeState
                                      ),
                                      Container(width: 10,),
                                      IconButton(
                                        icon: Icon(Icons.forward_10),
                                        onPressed: () => bloc.forward(10),
                                        iconSize: 30,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                                StreamBuilder<Duration>(
                                  stream: bloc.outDuration,
                                  builder: (BuildContext context, AsyncSnapshot<Duration> snapshotDuration) {
                                    if(snapshotDuration.hasData)
                                      return StreamBuilder<Duration>(
                                        stream: bloc.outPosition,
                                        builder: (BuildContext context, AsyncSnapshot<Duration> snapshotPosition) {
                                          if(snapshotPosition.hasData)
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(formatPosition(snapshotPosition.data), style: TextStyle(color: Colors.white70, fontSize: 11),),
                                                  Expanded(
                                                    child: StreamBuilder<double>(
                                                      stream: bloc.outSeek,
                                                      builder: (BuildContext context, AsyncSnapshot<double> snapshotSeek) {
                                                        if(snapshotSeek.hasData)
                                                          return Slider(
                                                            max: snapshotSeek.data,
                                                            min: 0,
                                                            value: snapshotPosition.data.inSeconds.toDouble(),
                                                            onChangeStart: (val) {},
                                                            onChanged: (val) => bloc.changeSeek(val),
                                                            onChangeEnd: (val) => bloc.seek(val),
                                                          );
                                                        return Slider(
                                                          max: snapshotDuration.data.inSeconds.toDouble(),
                                                          min: 0,
                                                          value: snapshotPosition.data.inSeconds.toDouble(),
                                                          onChangeStart: (val) {},
                                                          onChanged: (val) => bloc.changeSeek(val),
                                                          onChangeEnd: (val) => bloc.seek(val),
                                                        );
                                                      }
                                                    ),
                                                  ),
                                                  Text(formatPosition(snapshotDuration.data), style: TextStyle(color: Colors.white70, fontSize: 11),),
                                                ],
                                              ),
                                            );
                                          return Container();
                                        },
                                      );
                                    return Container();
                                  },
                                ),
                                Container(height: controller.value * -20 + 20),
                                Expanded(child: Container(),),  
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
        return Container();
      },
    );
  }
}