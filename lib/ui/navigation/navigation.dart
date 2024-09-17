import 'package:computer_system_software/ui/widgets/lab1/lab1.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2.dart';
import 'package:computer_system_software/ui/widgets/main_screen/main_screen.dart';
import 'package:provider/provider.dart';

class MainNavigationMainRoute {
  static const main = '/';
  static const lab1 = '/lab1';
  static const lab2 = '/lab2';
}

class MainNavigation {
  final routes = {
    MainNavigationMainRoute.main: (context) => const MainScreen(),
    MainNavigationMainRoute.lab1: (context) => ChangeNotifierProvider(
          create: (_) => Lab1Model(),
          lazy: false,
          child: const Lab1Page(),
        ),
    MainNavigationMainRoute.lab2: (context) => ChangeNotifierProvider(
          create: (_) => Lab2Model(),
          lazy: false,
          child: const Lab2Page(),
        ),
  };
  final initialRote = MainNavigationMainRoute.main;
}
