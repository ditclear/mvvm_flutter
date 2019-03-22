import 'package:flutter/material.dart';
import 'package:provide/provide.dart';

/**
 * 普通widget点击事件处理
 */
abstract class Presenter {
  void onClick(String action);
}

/**
 * 列表Item点击事件处理
 */
abstract class ItemPresenter<T> {
  void onItemClick(String action, T item);
}

class BaseViewModel with ChangeNotifier {}

abstract class PageProvideNode extends StatelessWidget {
  /// The values made available to the [child].
  final Providers mProviders = Providers();

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ProviderNode(
      providers: mProviders,
      child: buildContent(context),
    );
  }

}
