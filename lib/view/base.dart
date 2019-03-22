import 'package:flutter/material.dart';
import 'package:provide/provide.dart';

/**
 * normal click event
 */
abstract class Presenter {
  void onClick(String action);
}

/**
 * ListView Item Click
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
