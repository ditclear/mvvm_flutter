# MVVM-Flutter

Build MVVM App for Android and IOS with Flutter。

The Structure seems like [MVVM-Android](https://github.com/ditclear/MVVM-Android)。

![](architecture.png)

##### DownLoad



![](https://user-gold-cdn.xitu.io/2019/4/20/16a3a283fca2f664?w=300&h=300&f=png&s=9313)

#### dependencies

- [dio](https://github.com/flutterchina/dio) : netword 
- [rxdart](https://github.com/ReactiveX/rxdart)：reactive programming
- [flutter-provide](https://github.com/google/flutter-provide)：state managing
- [dartin](https://github.com/ditclear/dartin): dependency injection

> PS：each layer connected by rx, use responsive thinking and rxdart operators for logical processing.Finally, update the view with [flutter-provide](https://github.com/google/flutter-provide).

### ScreenShot

![](screenshot.png)![](ios.png)





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
  final GithubRepo _repo; 
  String username = ""; 
  String password = ""; 
  bool _loading = false; 
  String _response = ""; 
  //...
  HomeViewModel(this._repo);

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

