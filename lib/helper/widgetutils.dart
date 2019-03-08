import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/helper/toast.dart';

dispatchFailure(BuildContext context, dynamic e) {
  var message = e.toString();
  if (e is DioError) {
    final response = e.response;

    if (response?.statusCode == 401) {
      message = "账号或密码错误";
    } else if (403 == response?.statusCode) {
      message = "禁止访问";
    } else if (404 == response?.statusCode) {
      message = "链接错误";
    } else if (500 == response?.statusCode) {
      message = "服务器内部错误";
    } else if (503 == response?.statusCode) {
      message = "服务器升级中";
    } else if (e.error is SocketException) {
      message = "网络未连接";
    } else {
      message = "Oops!!";
    }
  }
  print("出错了："+message);
  Toast.show(message, context, type: Toast.ERROR);
}
