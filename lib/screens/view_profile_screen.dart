import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/helper/my_data_util.dart';
import 'package:we_talk/model/chat_user.dart';
import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Joined On: ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context, time: widget.user.createdAt,showYear: true),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            children: [
              SizedBox(
                width: mq.width,
                height: mq.height * .03,
              ),
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .2),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    height: mq.height * .2,
                    width: mq.width * .45,
                    fit: BoxFit.cover,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mq.height * 0.02),
              Text(
                widget.user.email,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: mq.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "About: ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(mq.width)),
                    margin: EdgeInsets.all(3),
                    padding: EdgeInsets.all(mq.width * .05),
                    width: mq.width * 0.7,
                    child: Text(
                      widget.user.about,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
