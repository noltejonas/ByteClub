import 'package:byteclub/appbar.dart/appbar.dart';
import 'package:byteclub/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}
