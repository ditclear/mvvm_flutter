import 'dart:convert';

import 'package:rxdart/rxdart.dart';

import '../helper/constants.dart';
import '../helper/net_utils.dart';
import '../helper/shared_preferences.dart';

/// 网络层
///
/// 提供网络层接口
class GithubService {
  /// 登录
  Observable login() => get("user");
}

/// 仓库层
///
/// 当请求开始时：处理ViewModel层传递过来的参数
/// 当返回数据时：将网络和本地的数据组装成ViewModel层需要的数据类型
class GithubRepo {
  final GithubService _remote;

  /// sharedPreference
  ///
  /// 也应该算在Model层，在这里面处理数据的读取
  final SpUtil _sp;

  GithubRepo(this._remote, this._sp);

  /// 登录
  ///
  /// - 将ViewModel层 传递过来的[username] 和 [password] 处理为 token 并用[SharedPreferences]进行缓存
  /// - 调用 [_remote] 的 [login] 方法进行网络访问
  /// - 返回 [Observable] 给ViewModel层
  Observable login(String username, String password) {
    _sp.putString(KEY_TOKEN, "basic " + base64Encode(utf8.encode('$username:$password')));
    return _remote.login();
  }
}
