import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/di/dartin.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:rxdart/rxdart.dart';

/**
 * ViewModel
 */
class HomeProvide extends ChangeNotifier {
  final CompositeSubscription _subscriptions = CompositeSubscription();
  final GithubRepo _repo; //数据仓库
  String username = ""; //账号
  String password = ""; //密码
  bool _loading = false; // 加载中
  String _response = ""; //响应数据

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

  /**
   * 调用model层的方法进行登录
   * doOnData : 请求成功时，处理响应数据
   * doOnError : 请求失败时，处理错误
   * doOnListen ： 开始时loading为true,通知ui更新
   * doOnDone ： 结束时loading为false,通知ui更新
   */
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

  @override
  void dispose() {
    super.dispose();
  }

  void disposeBag(){
    _subscriptions.dispose();

  }

  void plus(StreamSubscription s) {
    _subscriptions.add(s);
  }

}
