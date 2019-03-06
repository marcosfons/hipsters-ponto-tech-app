

import 'package:flutter/material.dart';

class PhotoHero extends StatelessWidget {
  final String tag;
  final String link;
  final Widget child;
  const PhotoHero({Key key, this.tag, this.link, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: child
    );
  }
}