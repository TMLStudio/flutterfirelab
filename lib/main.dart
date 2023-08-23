import 'package:flutter/material.dart';
import 'package:flutterfirelab/features/cloud_message/cloud_message_demo_screen.dart';
import 'package:flutterfirelab/features/cloud_message/fcm_service.dart';
import 'package:flutterfirelab/features/push_notification/push_notification_demo_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await fcm.initAsync();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Lab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DemoListScreen(),
    );
  }
}

class DemoListScreen extends StatefulWidget {
  const DemoListScreen({super.key});

  @override
  State<DemoListScreen> createState() => _DemoListScreenState();
}

class _DemoListScreenState extends State<DemoListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo List"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => CloudMessageDemoScreen())); }, child: Text("Firebase Message")),
            ElevatedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => PushNotificationDemoScreen())); }, child: Text("Push Notification"))
          ],
        ),
      ),
    );
  }
}
