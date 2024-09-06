import 'package:computer_system_software/ui/navigation/navigation.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  static final navigation = MainNavigation();
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: navigation.routes,
    );
  }
}