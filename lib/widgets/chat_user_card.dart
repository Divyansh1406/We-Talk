import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/model/chat_user.dart';
import 'package:we_talk/screens/chat_screen.dart';
import '../main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 0.5,
      color: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(
                    user: widget.user,
                  )));
        },
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height),
            child: CachedNetworkImage(
              imageUrl: widget.user.image,
              height: mq.height * 0.06,
              width: mq.height * 0.06,
              fit: BoxFit.fill,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
          // leading: CircleAvatar(
          //   child: Icon(Icons.person),
          // ),
          title: Text(
            widget.user.name,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            widget.user.about,
            style: TextStyle(color: Colors.white),
            maxLines: 1,
          ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
                color: CupertinoColors.activeGreen,
                borderRadius: BorderRadius.circular(10)),
          ),
          // Text("12:00pm", style: TextStyle(color: Colors.white)
          // ),
        ),
      ),
    );
  }
}
