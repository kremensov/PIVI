import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'HomePage.dart';

class MySplashScreen extends StatefulWidget {

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>  {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: HomePage(),
      title: Text(
        'PIVI',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0, 
          color: Colors.black
        ),
      ),
      image: Image.asset("assets/images/logo.png"),
      photoSize: 130,
      backgroundColor: Colors.lightBlue,
      loaderColor: Colors.black,
      loadingText: Text('UNIVESP: Projeto Interador VI', style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,),
      ),
    );
  }
}
