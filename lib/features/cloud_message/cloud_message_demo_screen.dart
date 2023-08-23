import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterfirelab/features/cloud_message/fcm_service.dart';

class CloudMessageDemoScreen extends StatefulWidget {
  const CloudMessageDemoScreen({super.key});

  @override
  State<CloudMessageDemoScreen> createState() => _CloudMessageDemoScreenState();
}

class _CloudMessageDemoScreenState extends State<CloudMessageDemoScreen> {
  String msgFromCloud = 'No message received';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        msgFromCloud = fcm.msgFromCloud;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Message Demo")),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Text(msgFromCloud, style: const TextStyle(fontSize: 20),),
    );
  }
}
