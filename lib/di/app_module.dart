import 'package:mvvm_flutter/model/remote.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:mvvm_flutter/viewmodel/home_provide.dart';

import 'dartin.dart';

final viewModelModule = Module([
  factory<HomeProvide>(({params}) => HomeProvide(params.get(0), get<GithubRepo>())),
]);

final repoModule = Module([
  lazy<GithubRepo>(({params}) => GithubRepo(get<GithubService>())),
]);

final remoteModule = Module([
  lazy<GithubService>(({params}) => GithubService()),
]);

final appModule = [viewModelModule, repoModule, remoteModule];
