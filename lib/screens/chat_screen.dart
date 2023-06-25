import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/helper/my_data_util.dart';
import 'package:we_talk/model/chat_user.dart';
import 'package:we_talk/screens/view_profile_screen.dart';
import 'package:we_talk/widgets/message_card.dart';

import '../main.dart';
import '../model/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //for storing value of showing or hiding emoji
  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: SizedBox(),
                          );

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return Center(
                              child: Text(
                                "Say Hii! 👋",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: Colors.black,
                        columns: 8,
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
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
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                        size: 26,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    style: TextStyle(color: Colors.white),
                    //to expand keyboard till the paragraph we use these two lines below
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      setState(() {
                        if (_showEmoji) _showEmoji = !_showEmoji;
                      });
                    },
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type Something',
                        hintStyle: TextStyle(fontWeight: FontWeight.w500)),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
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
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if(_list.isEmpty)
                  {
                    //on first message add user to my_user collection of chat user
                    APIs.sendFirstMessage(widget.user, _textController.text, Type.text);

                  }
                else
                  {
                    //simply send message
                    APIs.sendMessage(widget.user, _textController.text, Type.text);

                  }
                _textController.text = '';
              }
            },
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
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              return Row(
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
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
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
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 0.2,
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    ],
                  )
                ],
              );
            }));
  }
}
