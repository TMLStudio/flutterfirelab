import 'package:flutter/material.dart';
import 'package:flutterfirelab/features/push_notification/push_service.dart';

class PushNotificationDemoScreen extends StatefulWidget {
  const PushNotificationDemoScreen({super.key});

  @override
  State<PushNotificationDemoScreen> createState() => _PushNotificationDemoScreenState();
}

class _PushNotificationDemoScreenState extends State<PushNotificationDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Push Notification Demos")),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          ElevatedButton(onPressed: sendLocalPushNotification, child: Text("Local Push Notification")),
          ElevatedButton(onPressed: () {}, child: Text("Cloud Push Notification (+ Firebase)")),
        ],
      ),
    );
  }

  void sendLocalPushNotification() {
    pushService.showPushNotification('Local Notification', 'This message was send from this device', 'local');
  }
}
