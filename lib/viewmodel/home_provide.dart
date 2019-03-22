import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:rxdart/rxdart.dart';

/**
 * ViewModel
 */
class HomeProvide extends ChangeNotifier {
  final CompositeSubscription _subscriptions = CompositeSubscription();
  final GithubRepo _repo;
  String username = "";
  String password = "";
  bool _loading = false;
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

  /**
   * call the model layer 's method to login
   * doOnData : handle response when success
   * doOnError : handle error when failure
   * doOnListen ： show loading when listen start
   * doOnDone ： hide loading when complete
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

  /// add [StreamSubscription] to [_subscriptions]
  void plus(StreamSubscription s) {
    _subscriptions.add(s);
  }

}
