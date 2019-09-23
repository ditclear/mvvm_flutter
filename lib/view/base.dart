import 'dart:async';

import 'package:dartin/dartin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

/// normal click event
abstract class Presenter {
  /// 处理点击事件
  ///
  /// 可根据 [action] 进行区分 ,[action] 应是不可变的量
  void onClick(String action);
}

/// ListView Item Click
abstract class ItemPresenter<T> {
  /// 处理列表点击事件
  ///
  /// 可根据 [action] 进行区分 ,[action] 应是不可变的量
  void onItemClick(String action, T item);
}

/// BaseProvide
class BaseProvide extends ChangeNotifier {
  CompositeSubscription compositeSubscription = CompositeSubscription();

  /// add [StreamSubscription] to [compositeSubscription]
  ///
  /// 在 [dispose]的时候能进行取消
  addSubscription(StreamSubscription subscription) {
    compositeSubscription.add(subscription);
  }
}

/// page的基类 [PageProvideNode]
///
/// 隐藏了 [ProviderNode] 的调用
abstract class PageProvideNode<T extends ChangeNotifier> extends StatelessWidget {
  /// The values made available to the [child].

  final List<dynamic> params;
  final T mProvider;

  PageProvideNode(this.params) : mProvider = inject<T>(params: params);

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: mProvider,
      child: buildContent(context),
    );
  }
}
