import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:mvvm_flutter/view/base.dart';
import 'package:rxdart/rxdart.dart';

/// ViewModel 层
///
/// 将 Model层 [GithubRepo] 返回的数据转换成 View 层 [HomePage] 需要展示的数据
/// 通过 [notifyListeners] 通知UI层更新
class HomeProvide extends BaseProvide {
  final GithubRepo _repo;
  String username = "";
  String password = "";
  bool _loading = false;
  /// 结果
  String _response = "";

  final String title;

  String get response => _response;

  set response(String response) {
    _response = response;
    notifyListeners();
  }

  bool get loading => _loading;

  double _btnWidth = 295.0;

  double get btnWidth => _btnWidth;

  set btnWidth(double btnWidth) {
    _btnWidth = btnWidth;
    notifyListeners();
  }

  set loading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  HomeProvide(this.title,this._repo);

  /// 登录
  ///
  /// 调用 [_repo] 的 [login] 方法进行登录
  /// doOnData : handle response when success
  /// doOnError : handle error when failure
  /// doOnListen ： show loading when listen start
  /// doOnDone ： hide loading when complete
  /// return [Observable] 给 View 层
  Observable login() => _repo
      .login(username, password)
      .doOnData((r) => response = r.toString())
      .doOnError((e, stacktrace) {
        if (e is DioError) {
          response = e.response.data.toString();
        }
      })
      .doOnListen(() => loading = true)
      .doOnDone(() => loading = false);

}
