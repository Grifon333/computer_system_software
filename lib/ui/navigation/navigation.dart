import 'package:computer_system_software/ui/widgets/lab1/lab1_model.dart';
import 'package:computer_system_software/ui/widgets/lab1/view/lab1_page.dart';
import 'package:computer_system_software/ui/widgets/main_screen/main_screen.dart';
import 'package:provider/provider.dart';

class MainNavigationMainRoute {
  static const main = '/';
  static const lab1 = '/lab1';
}

class MainNavigation {
  final routes = {
    MainNavigationMainRoute.main: (context) => const MainScreen(),
    MainNavigationMainRoute.lab1: (context) => ChangeNotifierProvider(
          create: (_) => Lab1Model(),
          lazy: false,
          child: const Lab1Page(),
        ),
  };
  final initialRote = MainNavigationMainRoute.main;
}
