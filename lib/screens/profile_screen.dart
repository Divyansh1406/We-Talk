import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_talk/helper/dialogs.dart';
import 'package:we_talk/model/chat_user.dart';
import 'package:we_talk/screens/auth/login_screen.dart';
import '../api/apis.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut();
              await GoogleSignIn().signOut().then((value) {
                //for hiding progress dialog
                Navigator.pop(context);
                //for moving to home screen
                Navigator.pop(context);

                APIs.auth=FirebaseAuth.instance;
                //for replacing home screen with login screen
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              });
            },
            label: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(Icons.logout_outlined),
            backgroundColor: Colors.deepPurpleAccent,
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                Stack(
                  //profile picture
                  children: [
                    _image != null ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .2),
                      child: Image.file(
                        File(_image!),
                        width: mq.height*.2,
                        height: mq.height*.2,
                        fit: BoxFit.cover,
                      )
                    ) :
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .2),
                      child: CachedNetworkImage(
                        imageUrl: widget.user.image,
                        height: mq.height * .2,
                        width: mq.width * .45,
                        fit: BoxFit.fill,
                        // placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        elevation: 1,
                        onPressed: () {
                          _showBottomSheet();
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                        shape: CircleBorder(),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                SizedBox(height: mq.height * 0.02),
                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: mq.height * 0.045),
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val) => APIs.me.name = val ?? '',
                  validator: (val) =>
                  val != null && val.isNotEmpty ? null : 'Required Field',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                    prefixIcon: Icon(Icons.person),
                    hintText: "Enter Name",
                    label: Text("Name"),
                  ),
                ),
                SizedBox(height: mq.height * 0.025),
                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (val) => APIs.me.about = val ?? '',
                  validator: (val) =>
                  val != null && val.isNotEmpty ? null : 'Required Field',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                    prefixIcon: Icon(Icons.feed),
                    hintText: "eg. Feeling Happy",
                    label: Text("About"),
                  ),
                ),
                SizedBox(height: mq.height * 0.03),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then((value) =>
                          Dialogs.showSnackbar(
                              context, "Profile Updated SuccessFully"));
                    }
                  },
                  icon: Icon(Icons.edit_note),
                  label: Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.02, bottom: mq.height * 0.05),
            children: [
              Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: mq.height * 0.02,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      //pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image=image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        //for hiding bottomsheet
                        Navigator.of(context).pop();
                      }
                    },
                    child: Image.asset('images/gallery.png'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.white)),
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        //pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,imageQuality: 80);
                        if (image != null) {
                          setState(() {
                            _image=image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          //for hiding bottomsheet
                          Navigator.of(context).pop();
                        }
                      },
                      child: Image.asset('images/camera.png'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.white)),
                          fixedSize: Size(mq.width * .3, mq.height * .15)))
                ],
              )
            ],
          );
        });
  }
}
