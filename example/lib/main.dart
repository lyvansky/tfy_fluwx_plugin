import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tfy_fluwx_plugin/tfy_fluwx_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _register();
  }

  _register() async {
    bool result = await TfyFluwxPlugin.register('wxf9909bde17439ac2');
    print(result);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await TfyFluwxPlugin.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: <Widget>[
              Center(
                child: Text('Running on: $_platformVersion\n'),
              ),RaisedButton(
                child: Text('支付'),
                onPressed: () async {
                  String payInfo =
                      '{"appid":"wxf9909bde17439ac2","partnerid":"1518469211","prepayid":"wx120649521695951d501636f91748325073","package":"Sign=WXPay","noncestr":"1541976592","timestamp":"1541976592","sign":"E760C99A1A981B9A7D8F17B08EF60FCC"}';
                  PayResult payResult = await TfyFluwxPlugin.pay(
                      PayInfo.fromJson(json.decode(payInfo)));
                  print(payResult);
                },
              )
            ],
          )
      ),
    );
  }
}
