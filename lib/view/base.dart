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
class BaseProvide with ChangeNotifier {
  CompositeSubscription compositeSubscription = CompositeSubscription();

  /// add [StreamSubscription] to [compositeSubscription]
  ///
  /// 在 [dispose]的时候能进行取消
  addSubscription(StreamSubscription subscription) {
    compositeSubscription.add(subscription);
  }

  @override
  void dispose() {
    if (!compositeSubscription.isDisposed) {
      compositeSubscription.dispose();
    }
    super.dispose();
  }
}

/// page的基类 [PageProvideNode]
///
/// 隐藏了 [Provider] 的调用
abstract class PageProvideNode<T extends ChangeNotifier> extends StatelessWidget implements Presenter {
  final T mProvider;

  /// 构造函数
  ///
  /// [params] 代表注入ViewModel[mProvider]时所需的参数，需按照[mProvider]的构造方法顺序赋值
  PageProvideNode({List<dynamic> params}) : mProvider = inject<T>(params: params);

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: mProvider,
      child: buildContent(context),
    );
  }

  ///点击事件处理
  ///
  /// 可通过[action]进行分发
  @override
  void onClick(String action) {}
}
