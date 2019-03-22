import 'package:mvvm_flutter/model/remote.dart';
import 'package:mvvm_flutter/model/repository.dart';
import 'package:mvvm_flutter/viewmodel/home_provide.dart';
import 'package:dartin/dartin.dart';

const testScope = DartInScope('test');

final viewModelModule = Module([
  factory<HomeProvide>(({params}) => HomeProvide(params.get(0), get<GithubRepo>())),
])
  ..addOthers(testScope, [
    ///other scope
//  factory<HomeProvide>(({params}) => HomeProvide(params.get(0), get<GithubRepo>())),
  ]);

final repoModule = Module([
  lazy<GithubRepo>(({params}) => GithubRepo(get<GithubService>())),
]);

final remoteModule = Module([
  single<GithubService>(GithubService()),
]);

final appModule = [viewModelModule, repoModule, remoteModule];
