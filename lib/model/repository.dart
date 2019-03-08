import 'dart:convert';

import 'package:mvvm_flutter/di/modules.dart';
import 'package:mvvm_flutter/model/remote.dart';
import 'package:rxdart/rxdart.dart';

class GithubRepo {
  final GithubService _remote;

  GithubRepo(this._remote);

  Observable login(String username, String password) {
    token = "basic " + base64Encode(utf8.encode('$username:$password'));
    return _remote.login();
  }
}
