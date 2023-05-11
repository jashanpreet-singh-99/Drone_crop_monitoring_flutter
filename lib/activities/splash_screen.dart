import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_farm/activities/add_farm_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(milliseconds: 1000),
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFarmScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Image.asset('assets/farm.png')],
        ),
      ),
    );
  }
}
