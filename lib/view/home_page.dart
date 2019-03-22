import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/di/dartin.dart';
import 'package:mvvm_flutter/helper/dialog.dart';
import 'package:mvvm_flutter/helper/toast.dart';
import 'package:mvvm_flutter/helper/widgetutils.dart';
import 'package:mvvm_flutter/view/base.dart';
import 'package:mvvm_flutter/viewmodel/home_provide.dart';
import 'package:provide/provide.dart';

class HomePage extends PageProvideNode {
  final String title;

  HomePage(this.title) {
    mProviders.provideValue(inject<HomeProvide>(params: [title]));
  }

  @override
  Widget buildContent(BuildContext context) {
    return _HomeContentPage();
  }
}

class _HomeContentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeContentState();
  }
}

/**
 * View
 */
class _HomeContentState extends State<_HomeContentPage> with SingleTickerProviderStateMixin<_HomeContentPage> implements Presenter {
  HomeProvide _viewModel;

  AnimationController _controller;
  Animation<double> _animation;
  final _ACTION_LOGIN = "login";

  final LoadingDialog loadingDialog = LoadingDialog();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 295.0, end: 48.0).animate(_controller)
      ..addListener(() {
        _viewModel.btnWidth = _animation.value;
      });
  }

  @override
  void dispose() {
    print('-------dispose-------');
    _controller.dispose();
    _viewModel.disposeBag();
    super.dispose();
  }

  @override
  void onClick(String action) {
    if (action == _ACTION_LOGIN) {
      _login();
    }
  }

  _login() {
    final s = _viewModel.login().doOnListen(() {
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
    _viewModel.plus(s);
  }

  @override
  Widget build(BuildContext context) {
    _viewModel = Provide.value<HomeProvide>(context);
    print("--------build--------");
    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.title),
      ),
      body: DefaultTextStyle(
        style: TextStyle(),
        child: Material(
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
              Provide<HomeProvide>(
                builder: (BuildContext context, Widget child, HomeProvide value) => CupertinoButton(
                      onPressed: value.loading ? null : () => onClick(_ACTION_LOGIN),
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
                            boxShadow: [BoxShadow(color: Color(0x4D5E56FF), offset: Offset(0.0, 4.0), blurRadius: 13.0)]),
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

  Widget _buildChild(HomeProvide value) {
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
        ),
      );
    }
  }
}
