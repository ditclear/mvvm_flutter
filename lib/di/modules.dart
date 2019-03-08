import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_flutter/model/remote.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:mvvm_flutter/view/home.dart';
import 'package:provide/provide.dart';


final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

String token="";

final Dio dio=Dio()
  ..options = BaseOptions(
      baseUrl: 'https://api.github.com/',
      connectTimeout: 30,
      receiveTimeout: 30)
  ..interceptors.add(AuthInterceptor())
  ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

GithubService _provideGithubService()=>GithubService();
GithubRepo _provideGithubRepo()=>GithubRepo(_provideGithubService());
HomeViewModel provideHomeViewModel() => HomeViewModel(_provideGithubRepo());


final providers = Providers();

class AuthInterceptor extends Interceptor{

  @override
  onRequest(RequestOptions options) {
    options.headers.update("Authorization",(_)=>token,ifAbsent: ()=>token);
    return super.onRequest(options);
  }
}