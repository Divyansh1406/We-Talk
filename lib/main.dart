import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_talk/screens/splash_screen.dart';
import 'firebase_options.dart';

//media query object for optimisation according to screen
late Size mq;

final theme = ThemeData(
  useMaterial3: true,
    textTheme: GoogleFonts.latoTextTheme(),
    colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark, seedColor: Colors.blue),
    appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.deepPurple,
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.normal, fontSize: 19)));

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //enter full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //for setting orientation to potrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Talk',
      theme: theme,
      home: SplashScreen(),
    );
  }
}

_initializeFirebase() async
{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}