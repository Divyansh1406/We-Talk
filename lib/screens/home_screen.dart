import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_talk/helper/dialogs.dart';
import 'package:we_talk/screens/profile_screen.dart';
import 'package:we_talk/widgets/chat_user_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../model/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    APIs.getSelfInfo();

    //to check if the app is in background or current screen of the device
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on and back button is pressed then close search
        // else simply close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(hintText: 'Name,Email,....'),
                    autofocus: true,
                    style: TextStyle(
                        fontSize: 16, letterSpacing: 0.5, color: Colors.white),
                    //when search text changes then updated search list
                    onChanged: (val)
                        //search logic
                        {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text('We Talk'),
            leading: Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                              user: APIs.me,
                            )));
                  },
                  icon: Icon(CupertinoIcons.ellipsis_vertical))
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: Icon(Icons.add_comment_rounded),
              backgroundColor: Colors.blueAccent,
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              //get id of only known users
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
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those users,who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index],
                                  );
                                });
                          } else {
                            return Center(
                              child: Text(
                                "No Connection Found",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            );
                          }
                      }
                    },
                  );
                }
              }),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
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
                    Icons.person_add,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                  Text(
                    "   Add User",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              //content
              content: TextFormField(
                style: TextStyle(color: Colors.white),
                maxLines: null, //update acc to content size
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: "Email Id",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.blueAccent,
                    ),
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
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, "User does not Exists");
                        }
                      });
                    }
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.lightGreen, fontSize: 16),
                  ),
                ),
              ],
            ));
  }
}
