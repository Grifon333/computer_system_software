import 'package:computer_system_software/ui/widgets/lab1/lab1.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2.dart';
import 'package:computer_system_software/ui/widgets/lab3/lab3.dart';
import 'package:computer_system_software/ui/widgets/lab4/lab4.dart';
import 'package:computer_system_software/ui/widgets/main_screen/main_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/lab5/lab5.dart';

class MainNavigationMainRoute {
  static const main = '/';
  static const lab1 = '/lab1';
  static const lab2 = '/lab2';
  static const lab3 = '/lab3';
  static const lab4 = '/lab4';
  static const lab5 = '/lab5';
}

class MainNavigation {
  final routes = {
    MainNavigationMainRoute.main: (_) => const MainScreen(),
    MainNavigationMainRoute.lab1: (_) => ChangeNotifierProvider(
          create: (_) => Lab1Model(),
          lazy: false,
          child: const Lab1Page(),
        ),
    MainNavigationMainRoute.lab2: (_) => ChangeNotifierProvider(
          create: (_) => Lab2Model(),
          lazy: false,
          child: const Lab2Page(),
        ),
    MainNavigationMainRoute.lab3: (_) => ChangeNotifierProvider(
          create: (_) => Lab3Model(),
          lazy: false,
          child: const Lab3Page(),
        ),
    MainNavigationMainRoute.lab4: (_) => ChangeNotifierProvider(
          create: (_) => Lab4Model(),
          lazy: false,
          child: const Lab4Page(),
        ),
    MainNavigationMainRoute.lab5: (_) => ChangeNotifierProvider(
      create: (_) => Lab5Model(),
      lazy: false,
      child: const Lab5Page(),
    ),
  };
}
