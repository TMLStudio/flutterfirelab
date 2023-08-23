import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    debugPrint(
        'notification action tapped with input: ${notificationResponse
            .input}');
  }
}


class PushService {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String? selectedNotificationPayload;
  final MethodChannel platform = const MethodChannel('flutterfirelab/push');

  static const String darwinNotificationCategoryText = 'textCategory';
  static const String darwinNotificationCategoryPlain = 'plainCategory';

  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
  StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

  final BehaviorSubject<String?> selectNotificationSubject =
  BehaviorSubject<String?>();

  DarwinInitializationSettings _createInitializeSettingsForiOS() {
    final List<DarwinNotificationCategory> darwinNotificationCategories =
    <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            'id_3',
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    return  DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );
  }

  InitializationSettings _createInitializationSettingsForSupportedPlatforms() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    return  InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: _createInitializeSettingsForiOS(),
    );
  }

  Future initAsync() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
        Platform.isLinux
        ? null
        : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
    }

    InitializationSettings initializationSettings = _createInitializationSettingsForSupportedPlatforms();


    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // onSelectNotification: (String? payload) async {
        //   if (payload != null) {
        //     debugPrint('notification payload: $payload');
        //   }
        //   selectedNotificationPayload = payload;
        //   selectNotificationSubject.add(payload);
        // }
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          switch (notificationResponse.notificationResponseType) {
            case NotificationResponseType.selectedNotification:
              selectNotificationStream.add(notificationResponse.payload);
              break;
            case NotificationResponseType.selectedNotificationAction:
                selectNotificationStream.add(notificationResponse.payload);
              break;
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground
    );

    await _checkPermissionIsGranted();
    await _requestPermissions();
  }

  bool _notificationsEnabled = false;
  Future<void> _checkPermissionIsGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;
      debugPrint("SET _notificationsEnabled = granted = $granted <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
      _notificationsEnabled = granted;
    } else if (Platform.isIOS) {
      _notificationsEnabled = false;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      var resultCode = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint("IOS permission grant result code: $resultCode");
      _notificationsEnabled= true;
    } else if (Platform.isAndroid) {
      debugPrint("request notification permission <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();

      debugPrint("SET _notificationsEnabled = requestPermission.granted = $granted <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
      _notificationsEnabled = granted ?? false;
    }
  }

  void showPushNotification(String title, String message, String id) async {
    if (Platform.isAndroid) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('push-noti-demo', 'Push Notification Demo',
        icon: '@mipmap/ic_launcher',
        channelDescription: 'Used for Push Notification Demo (Max Importance and High priority)',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        category: AndroidNotificationCategory.alarm,
        color: Colors.red,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
          0, title, message, platformChannelSpecifics,
          payload: id);
    } else if (Platform.isIOS) {
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
          0, title, message, platformChannelSpecifics,
          payload: id);
    }
  }


}

final pushService = PushService();