import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/helper/dialogs.dart';
import 'package:we_talk/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/apis.dart';
import '../../components/gradient_text.dart';
import '../../main.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async{
      Navigator.of(context).pop();
      if(user!=null){

        if(await(APIs.userExists()))
          {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          }
        else
          {
            await APIs.createUser().then((value) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomeScreen()));

            });
          }
        }

    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch(e){
      print('_signInWithGoogle" $e');
      Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet)');
      return null;
    }
  }

  // _signOut() async
  // {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
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
              left: mq.width * .20,
              child: SizedBox(
                height: mq.height * .07,
                width: mq.width * 0.6,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, double.infinity),
                    ),
                    onPressed: () {
                      _handleGoogleBtnClick();
                    },
                    icon: Image.asset(
                      'images/google-2.png',
                      width: mq.width * 0.1,
                    ),
                    label: Text("Log In With Google",
                        style: TextStyle(
                          fontSize: 18,
                        ))),
              )),
        ],
      ),
    );
  }
}
