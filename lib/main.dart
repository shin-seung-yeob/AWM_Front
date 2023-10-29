import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/Screen/home_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() => runApp(
     MyApp()
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginModule(),
      debugShowCheckedModeBanner: false,
    );
  }
}
