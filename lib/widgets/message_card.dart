import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/helper/dialogs.dart';
import 'package:we_talk/helper/my_data_util.dart';

import '../main.dart';
import '../model/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _whiteMessage() : _blueMessage());
  }

  //senders message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * 0.04),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * .04),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white60),
                color: Color.fromARGB(153, 189, 92, 255),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? _showEditedorNot(widget.message)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        //
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.white54),
          ),
        ),
      ],
    );
  }

  //user's message
  Widget _whiteMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * 0.03),

            //double tick icon for message read
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            SizedBox(
              width: 2.5,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),
        //double tick blue icon for message read
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * 0.04),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * .04),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 2),
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? _showEditedorNot(widget.message)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * 0.4),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(9)),
            ),
            widget.message.type == Type.text
                ? //copy option
                _OptionItem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.of(context).pop();
                        Dialogs.showSnackbar(context, "Text Copied");
                      });
                    })
                : _OptionItem(
                    icon: Icon(
                      Icons.download,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "We Chat")
                            .then((success) {
                          Navigator.of(context).pop();
                          if (success != null && success) {
                            Dialogs.showSnackbar(
                                context, "Image Saved Successfully");
                          }
                        });
                      } catch (e) {
                        log("error in saving image $e");
                      }
                    }),
            //separator or divider
            if (isMe)
              Divider(
                color: Colors.white60,
                endIndent: mq.width * 0.04,
                indent: mq.width * 0.04,
              ),

            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.yellow,
                    size: 26,
                  ),
                  name: "Edit",
                  onTap: () {
                    Navigator.of(context).pop();
                    _showMessageUpdateDialog();
                    //hiding bottom sheet
                  }),

            if (isMe)
              _OptionItem(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: "Delete Message",
                  onTap: () {
                    APIs.deleteMessage(widget.message).then((value) {
                      Navigator.of(context).pop();
                    });
                  }),
            Divider(
              color: Colors.white60,
              endIndent: mq.width * 0.04,
              indent: mq.width * 0.04,
            ),
            _OptionItem(
                icon: Icon(
                  Icons.fact_check_outlined,
                  color: Colors.purpleAccent,
                ),
                name:
                    "Send At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                onTap: () {}),
            _OptionItem(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                ),
                name: widget.message.read.isEmpty
                    ? "Read At: Not Seen Yet"
                    : "Read at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
                onTap: () {}),
          ]);
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.black,
              //title
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                  Text(
                    "   Update Message",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              //content
              content: TextFormField(
                style: TextStyle(color: Colors.white),
                initialValue: updatedMsg,
                maxLines: null, //update acc to content size
                onChanged: (value)=>updatedMsg=value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    APIs.updateMessage(widget.message, updatedMsg);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(color: Colors.lightGreen, fontSize: 16),
                  ),
                ),
              ],
            ));
  }

  
  Widget _showEditedorNot(Message message)
  {
    if(widget.message.updated)
      {
        return
        Text(
          widget.message.msg+" (edited)",
          style: TextStyle(color: Colors.black, fontSize: 15),
        );
      }
    else
      {
        return
        Text(
          widget.message.msg,
          style: TextStyle(color: Colors.black, fontSize: 15),
        );
      }
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * 0.015,
            bottom: mq.height * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "    $name",
              style: TextStyle(
                  fontSize: 16, color: Colors.white, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
