import 'dart:async';

import 'package:flutter/services.dart';


/// pay result
enum PayResult {
  /// success
  success,

  /// fail
  fail,

  /// cancel
  cancel,
}

class TfyFluwxPlugin {
  static const MethodChannel _channel = const MethodChannel('com.tfy/fluwx');

  static Future<String> getPlatformVersion() async{
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// register app id
  static Future<bool> register(String appId) async {
    return await _channel
        .invokeMethod('register', <String, dynamic>{'appId': appId});
  }

  /// pay
  static Future<PayResult> pay(PayInfo payInfo) async {
    int payResult = await _channel.invokeMethod('pay', <String, dynamic>{
      'appid': payInfo.appid,
      'partnerid': payInfo.partnerid,
      'prepayid': payInfo.prepayid,
      'package': payInfo.package,
      'noncestr': payInfo.noncestr,
      'timestamp': payInfo.timestamp,
      'sign': payInfo.sign,
    });
    return _convertPayResult(payResult);
  }

  static PayResult _convertPayResult(int payResult) {
    switch (payResult) {
      case 0:
        return PayResult.success;
      case -1:
        return PayResult.fail;
      case -2:
        return PayResult.cancel;
      default:
        return null;
    }
  }
}

class PayInfo {
  /// appid
  String appid;

  /// partnerid
  String partnerid;

  /// prepayid
  String prepayid;

  /// package
  String package;

  /// noncestr
  String noncestr;

  /// timestamp
  String timestamp;

  /// sign
  String sign;

  PayInfo({
    this.appid,
    this.partnerid,
    this.prepayid,
    this.package,
    this.noncestr,
    this.timestamp,
    this.sign,
  });

  /// from json
  factory PayInfo.fromJson(Map<String, dynamic> json) {
    return PayInfo(
      appid: json['appid'],
      partnerid: json['partnerid'],
      prepayid: json['prepayid'],
      package: json['package'],
      noncestr: json['noncestr'],
      timestamp: json['timestamp'],
      sign: json['sign'],
    );
  }
}
