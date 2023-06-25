import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/screens/auth/login_screen.dart';
import 'package:we_talk/screens/home_screen.dart';
import '../../components/gradient_text.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));

      if(APIs.auth.currentUser!=null)
        {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      else
        {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginScreen()));
        }

    });
  }

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .05,
              left: mq.width * .05,
              width: mq.width * .7,
              height: mq.width * .9,
              child: GradientText('Welcome to We Talk',
                  style: const TextStyle(
                      fontSize: 52, fontWeight: FontWeight.bold),
                  gradient: LinearGradient(colors: [
                    Colors.purpleAccent,
                    Colors.deepPurple,
                  ]))),
          Positioned(
              top: mq.height * .20,
              left: mq.width * .15,
              width: mq.width * .7,
              height: mq.height * .48,
              child: Image.asset(
                'images/login.png',
              )),
          Positioned(
              bottom: mq.height * .11,
              left: mq.width * .15,
              child: GradientText('Made with Love by Divyansh Vashist ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  gradient: LinearGradient(colors: [
                    Colors.purpleAccent,
                    Colors.lightBlue,
                  ]))),
        ],
      ),
    );
  }
}
