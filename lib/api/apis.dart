import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:we_talk/model/chat_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_talk/model/message.dart';
import 'package:http/http.dart' as http;

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  //check if user exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static late ChatUser me;

  //check if user exists or not
  static Future getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting uuser status to active

        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: 'Hey there!!',
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: user.uid,
        email: user.email.toString(),
        pushToken: '');
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds) //because empty list throws an error
    // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for getting id's of known users from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users').doc(user.uid).collection('my_users').snapshots();
  }

  //for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser,String msg,Type type) async{
    await firestore.collection('users').doc(chatUser.id).collection('my_users').doc(user.uid).set({}).then((value) {
      sendMessage(chatUser, msg, type);
    });
  }


  //to save user data that is modified using save button
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //update profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile/pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'images/$ext'))
        .then((p0) => null);
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  //useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  //for getting all messages of a specific conversation from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
      msg: msg,
      read: '',
      toId: chatUser.id,
      type: type,
      fromId: user.uid,
      sent: time,
      updated: false,
    );
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "image"));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //to check if the message was updated before or not just change the chat_card using the updated field in each message, i
  // if true then add one edited symbol at bottom of msg card

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'images/$ext'))
        .then((p0) => null);

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }

  //for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase message token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('push token: ,$t');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  //send push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken.toString(),
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {"some_data": "User ID: ${me.id}"}
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          "Content-Type": 'application/json',
          "Authorization":
              "Bearer AAAALYpOFJk:APA91bHBl8utIcrgIIoiGU2bF_LiQkS40877uWgFwHbK1rEoUqn3xoRaC2U-6fXMYFY2GOaArzk_ayVcvxIRkX8jx_tRWu-0gkSNEecRLZzWFURXz0mfBPz8QR5yXbXjsxMz05WDH_rH"
        },
        body: jsonEncode(body),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    //for deleting image from fire storage
    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({"msg": updatedMsg, "updated": true});
  }

  //to check if user exists or not
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id).set({});
      return true;
    } else {
      return false;
    }
  }
}
