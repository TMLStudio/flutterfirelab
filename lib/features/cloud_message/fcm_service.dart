import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterfirelab/firebase_options.dart';

class FCMService {
  String? token;
  String msgFromCloud = 'No message';
  Future initAsync() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    token = await FirebaseMessaging.instance.getToken();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((msg) {
      msgFromCloud = "Sender=${msg.from} messageId=${msg.messageId} data=${jsonEncode(msg.data)} receiveAt=${DateTime.now().toIso8601String()}";
      debugPrint(msgFromCloud);
    });

    ///Configure notification permissions
    //IOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    //Android
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

  }

}

final fcm = FCMService();