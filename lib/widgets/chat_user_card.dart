import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/helper/my_data_util.dart';
import 'package:we_talk/model/chat_user.dart';
import 'package:we_talk/screens/chat_screen.dart';
import 'package:we_talk/widgets/dialogs.dart';
import '../main.dart';
import '../model/message.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info  (if null -> no message)
  Message? _message;

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
        child: StreamBuilder(
          stream: APIs.getAllMessages(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }
            return ListTile(
              leading: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(
                            user: widget.user,
                          ));
                },
                child: ClipRRect(
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
              ),
              // leading: CircleAvatar(
              //   child: Icon(Icons.person),
              // ),

              //username
              title: Text(
                widget.user.name,
                style: TextStyle(color: Colors.white),
              ),
              //last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
              //last message time
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: CupertinoColors.activeGreen,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                              context: context, time: _message!.sent),
                          style: TextStyle(color: Colors.white)),
            );
          },
        ),
      ),
    );
  }
}
