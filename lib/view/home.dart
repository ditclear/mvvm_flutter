import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/di/modules.dart';
import 'package:mvvm_flutter/helper/toast.dart';
import 'package:mvvm_flutter/helper/widgetutils.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:provide/provide.dart';
import 'package:rxdart/rxdart.dart';

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState(provideHomeViewModel());
  }
}

/**
 * View
 */
class _HomeState extends State<HomeWidget>
    with SingleTickerProviderStateMixin<HomeWidget> {
  final HomeViewModel _viewModel;
  final CompositeSubscription _subscriptions = CompositeSubscription();

  AnimationController _controller;
  Animation<double> _animation;

  _HomeState(this._viewModel) {
    providers.provideValue(_viewModel);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: _viewModel.btnWidth, end: 48.0).animate(_controller)
      ..addListener(() {
        _viewModel.btnWidth = _animation.value;
      });
  }

  _login() {
    final s = _viewModel.login().doOnListen(() {
      _controller.forward();
    }).doOnDone(() {
      _controller.reverse();
    }).listen((_) {
      //success
      Toast.show("login success",context,type: Toast.SUCCESS);
    }, onError: (e) {
      //error
      dispatchFailure(context, e);
    });
    _subscriptions.add(s);
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MVVM-Flutter"),
      ),
      body: Material(
        child: Column(
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                icon: Icon(Icons.person),
                labelText: '账号',
              ),
              autofocus: false,
              onChanged: (str) => _viewModel.username = str,
            ),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                icon: Icon(Icons.lock),
                labelText: '密码',
              ),
              autofocus: false,
              onChanged: (str) => _viewModel.password = str,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
            ),
            Provide<HomeViewModel>(
              builder: (BuildContext context, Widget child,
                      HomeViewModel value) =>
                  CupertinoButton(
                    onPressed: value.loading?null:_login,
                    pressedOpacity: 0.8,
                    child: Container(
                      alignment: Alignment.center,
                      width: value.btnWidth,
                      height: 48,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          gradient: LinearGradient(colors: [
                            Color(0xFF686CF2),
                            Color(0xFF0E5CFF),
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x4D5E56FF),
                                offset: Offset(0.0, 4.0),
                                blurRadius: 13.0)
                          ]),
                      child: _buildChild(value),
                    ),
                  ),
            ),
            const Text(
              "Response:",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.start,
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints(minWidth: double.infinity),
                margin: EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: EdgeInsets.all(5.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blue)),
                child: Provide<HomeViewModel>(
                  builder: (BuildContext context, Widget child,
                          HomeViewModel value) =>
                      Text(value.response),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChild(HomeViewModel value) {
    if (value.loading) {
      return const CircularProgressIndicator();
    } else {
      return const FittedBox(
        fit: BoxFit.scaleDown,
        child: const Text(
          '使用GitHub账号登录',
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
        ),
      );
    }
  }
}

/**
 * ViewModel
 */
class HomeViewModel extends ChangeNotifier {
  final GithubRepo _repo; //数据仓库
  String username = ""; //账号
  String password = ""; //密码
  bool _loading = false; // 加载中
  String _response = ""; //响应数据

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

  HomeViewModel(this._repo);

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
}
