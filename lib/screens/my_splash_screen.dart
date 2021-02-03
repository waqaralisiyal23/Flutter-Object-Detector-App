import 'package:flutter/material.dart';
import 'package:objectdetectorapp/screens/home_screen.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplashscreen extends StatefulWidget {
  @override
  _MySplashscreenState createState() => _MySplashscreenState();
}

class _MySplashscreenState extends State<MySplashscreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: HomeScreen(),
      imageBackground: Image.asset('assets/images/back.jpg').image,
      // useLoader: false,      // if you don't want to use loading bar
      loaderColor: Colors.pink,
      loadingText: Text(
        'Loading...',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
