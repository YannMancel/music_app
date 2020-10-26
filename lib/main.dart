import 'package:flutter/material.dart';

import 'music/MusicScaffold.dart';

void main() => runApp(MyApp());

/// Root Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Music App',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: MusicScaffold(title: 'Music'));
  }
}
