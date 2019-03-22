import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/helper/toast.dart';

dispatchFailure(BuildContext context, dynamic e) {
  var message = e.toString();
  if (e is DioError) {
    final response = e.response;

    if (response?.statusCode == 401) {
      message = "account or password error ";
    } else if (403 == response?.statusCode) {
      message = "forbidden";
    } else if (404 == response?.statusCode) {
      message = "page not found";
    } else if (500 == response?.statusCode) {
      message = "Server internal error";
    } else if (503 == response?.statusCode) {
      message = "Server Updating";
    } else if (e.error is SocketException) {
      message = "network cannot use";
    } else {
      message = "Oops!!";
    }
  }
  print("error ：" + message);
  if (context != null) {
    Toast.show(message, context, type: Toast.ERROR);
  }
}
