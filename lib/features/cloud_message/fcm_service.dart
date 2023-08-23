import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterfirelab/features/push_notification/push_service.dart';
import 'package:flutterfirelab/firebase_options.dart';

class FCMService {
  String? token;
  String msgFromCloud = 'No message';
  Future initAsync() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    token = await FirebaseMessaging.instance.getToken();
    debugPrint("Client Token: $token");
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint("msg.data=${jsonEncode(msg.data)}");
      String title = '';
      String body = '';
      if (msg.notification != null) {
        title = "${msg.notification!.title}";
        body = "${msg.notification!.body}";
        debugPrint("msg.notification: title=$title body=$body");
      }


      msgFromCloud =
          "title=${title} body=${body} Sender=${msg.from} messageId=${msg.messageId} data=${jsonEncode(msg.data)} receiveAt=${DateTime.now().toIso8601String()}";
      debugPrint(msgFromCloud);

      pushService.showPushNotification(title, body, 'cloud');
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
