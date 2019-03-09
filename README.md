# MVVM-Flutter

Build MVVM App for Android and IOS with Flutter。

项目结构类似于[MVVM-Android](https://github.com/ditclear/MVVM-Android)。

```bash
.
├── di
│   └── modules.dart
├── helper
│   ├── netutils.dart
│   ├── toast.dart
│   └── widgetutils.dart
├── main.dart
├── model
│   ├── remote.dart
│   └── repository.dart
└── view
    └── home.dart

```
##### 下载体验

![](android.png)

#### dependencies

- [dio](https://github.com/flutterchina/dio) : 网络请求
- [rxdart](https://github.com/ReactiveX/rxdart)：响应式编程
- [flutter-provide](https://github.com/google/flutter-provide)：通知ui更新数据

> 思想：M-V-VM各层直接通过rx衔接，配合响应式的思想和rxdart的操作符进行逻辑处理，最后通过provide来更新视图。

### 截图

![](screenshot.png)

#### Code

```dart
//remote
class GithubService{
  Observable<dynamic> login()=> get("user");
}
//repo
class GithubRepo {
  final GithubService _remote;

  GithubRepo(this._remote);

  Observable login(String username, String password) {
    token = "basic " + base64Encode(utf8.encode('$username:$password'));
    return _remote.login();
  }
}
//viewmodel
class HomeViewModel extends ChangeNotifier {
  final GithubRepo _repo; //数据仓库
  String username = ""; //账号
  String password = ""; //密码
  bool _loading = false; // 加载中
  String _response = ""; //响应数据
  //...
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

//view
class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState(provideHomeViewModel());
  }
}
class _HomeState extends State<HomeWidget>{
   //...
  _HomeState(this._viewModel) {
    providers.provideValue(_viewModel);
  }
	
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appbar://...,
        body://...
       
        CupertinoButton(
            onPressed: _login,
            //...
         ),
         Container(
                //...
                child: Provide<HomeViewModel>(
                  builder: (BuildContext context, Widget child,
                          HomeViewModel value) =>
                      Text(value.response),
                ),
              ),
        //...
        
        );
  }
  
    
  _login()=>_viewModel.login().doOnListen(() {
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
 
}

```

#### LICENSE

the Apache License

