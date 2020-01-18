import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/app_module.dart';
import 'view/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // wait init
  await init();
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MVVM-Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage('MVVM-Flutter'));
  }
}
