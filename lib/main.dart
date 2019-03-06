import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:hipsters_ponto_tech/blocs/audio-bloc.dart';
import 'package:hipsters_ponto_tech/blocs/download-bloc.dart';
import 'package:hipsters_ponto_tech/src/pages/home/home-bloc.dart';
import 'package:hipsters_ponto_tech/src/pages/home/home-page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProviderList(
      child: MaterialApp(
        title: 'Hipsters Ponto Tech',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
      listBloc: [
        Bloc(AudioBloc()),
        Bloc(DownloadsBloc()),
        Bloc(HomeBloc())
      ],
    );
  }
}
