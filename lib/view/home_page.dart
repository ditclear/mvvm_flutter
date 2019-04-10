import 'package:dartin/dartin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/helper/dialog.dart';
import 'package:mvvm_flutter/helper/toast.dart';
import 'package:mvvm_flutter/helper/widget_utils.dart';
import 'package:mvvm_flutter/view/base.dart';
import 'package:mvvm_flutter/viewmodel/home_provide.dart';
import 'package:provide/provide.dart';

/// Page ：HomePage
///
/// 获取其它页面传递来的参数
/// 构造出各个 Provide 对象，放入到 [mProviders]里
class HomePage extends PageProvideNode {
  /// 页面标题
  final String title;

  /// 提供
  ///
  /// 获取参数 [title] 并生成一个[HomeProvide]对象
  /// 然后放入 [mProviders]中
  HomePage(this.title) {
    final provide = inject<HomeProvide>(params: [title]);
    mProviders.provideValue(provide);
  }

  @override
  Widget buildContent(BuildContext context) {
    return _HomeContentPage();
  }
}

/// View : 登录页面
///
/// 展示UI (ps:如果有UI地址，最好附上相应的链接)
/// 与用户进行交互
class _HomeContentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeContentState();
  }
}

class _HomeContentState extends State<_HomeContentPage> with SingleTickerProviderStateMixin<_HomeContentPage>
    implements Presenter {

  HomeProvide mProvide;

  /// 处理动画
  AnimationController _controller;
  Animation<double> _animation;

  static const ACTION_LOGIN = "login";

  final LoadingDialog loadingDialog = LoadingDialog();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 295.0, end: 48.0).animate(_controller)
      ..addListener(() {
        mProvide.btnWidth = _animation.value;
      });
  }

  @override
  void dispose() {
    print('-------dispose-------');
    _controller.dispose();
    super.dispose();
  }

  @override
  void onClick(String action) {
    if (action == ACTION_LOGIN) {
      login();
    }
  }

  /// 登录
  ///
  /// 调用 [mProvide] 的 login 方法并进行订阅
  /// 请求开始时：启动动画 [AnimationStatus.forward]
  /// 请求结束时：反转动画 [AnimationStatus.reverse]
  /// 成功 ：弹出 'login success'
  /// 失败 ：[dispatchFailure] 显示错误原因
  void login() {
    final s = mProvide.login().doOnListen(() {
      _controller.forward();
    }).doOnDone(() {
      _controller.reverse();
    }).doOnCancel(() {
      print("======cancel======");
    }).listen((_) {
      //success
      Toast.show("login success", context, type: Toast.SUCCESS);
    }, onError: (e) {
      //error
      dispatchFailure(context, e);
    });
    mProvide.addSubscription(s);
  }

  @override
  Widget build(BuildContext context) {
    mProvide = Provide.value<HomeProvide>(context);
    print("--------build--------");
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(mProvide.title),
        ),
        body: DefaultTextStyle(
          style: TextStyle(color: Colors.black),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  icon: Icon(Icons.person),
                  labelText: 'Account',
                ),
                autofocus: false,
                onChanged: (str) => mProvide.username = str,
              ),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  icon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
                autofocus: false,
                onChanged: (str) => mProvide.password = str,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
              ),
              buildLoginBtnProvide(),
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
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                  child: Provide<HomeProvide>(
                    builder: (BuildContext context, Widget child, HomeProvide value) => Text(value.response),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 登录按钮
  ///
  /// 按钮宽度根据是否进行请求由[_controller]控制
  /// 当 [mProvide.loading] 为true 时 ，点击事件不生效
  Provide<HomeProvide> buildLoginBtnProvide() {
    return Provide<HomeProvide>(
              builder: (BuildContext context, Widget child, HomeProvide value) {
                return CupertinoButton(
                    onPressed: value.loading ? null : () => onClick(ACTION_LOGIN),
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
                            BoxShadow(color: Color(0x4D5E56FF), offset: Offset(0.0, 4.0), blurRadius: 13.0)
                          ]),
                      child: buildLoginChild(value),
                    ),
                  );
              },
            );
  }

  /// 登录按钮内部的 child
  ///
  /// 当请求进行时 [value.loading] 为 true 时,显示 [CircularProgressIndicator]
  /// 否则显示普通文本
  Widget buildLoginChild(HomeProvide value) {
    if (value.loading) {
      return const CircularProgressIndicator();
    } else {
      return const FittedBox(
        fit: BoxFit.scaleDown,
        child: const Text(
          'Login With Github Account',
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
        ),
      );
    }
  }
}
