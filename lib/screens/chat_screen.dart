import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/model/chat_user.dart';

import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessages(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      // return const Center(
                      //   child: CircularProgressIndicator(),
                      // );

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      log('Data: ${jsonEncode(data![0].data())}');
                      // _list = data
                      //         ?.map((e) => ChatUser.fromJson(e.data()))
                      //         .toList() ??
                      //     [];

                      final _list=[];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount:_list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Text('Message: ${_list[index]}');
                            });
                      } else {
                        return Center(
                          child: Text(
                            "Say Hii! 👋",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            _chatInput()
          ],
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white30,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                        size: 26,
                      )),
                  Expanded(
                      child: TextField(
                    style: TextStyle(color: Colors.white),
                    //to expand keyboard till the paragraph we use these two lines below
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type Something',
                        hintStyle: TextStyle(fontWeight: FontWeight.w500)),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera,
                        color: Colors.white,
                        size: 26,
                      )),
                ],
              ),
            ),
          ),
          //send message button
          MaterialButton(
            onPressed: () {},
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            child: Icon(
              Icons.send,
              size: 26,
            ),
            color: Colors.deepPurpleAccent,
            shape: CircleBorder(),
          )
        ],
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height),
            child: CachedNetworkImage(
              imageUrl: widget.user.image,
              height: mq.height * 0.05,
              width: mq.height * 0.05,
              fit: BoxFit.fill,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.2,
              ),
              Text(
                "Last Seen Not Available",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              )
            ],
          )
        ],
      ),
    );
  }
}
