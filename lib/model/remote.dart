
import 'package:rxdart/rxdart.dart';
import 'package:mvvm_flutter/helper/netutils.dart';
class GithubService{

  Observable<dynamic> login()=> get("user");

}