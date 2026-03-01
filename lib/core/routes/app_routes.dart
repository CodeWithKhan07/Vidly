import 'package:get/get.dart';
import 'package:vidly/views/downloads/downloads_screen.dart';
import 'package:vidly/views/main/main_screen.dart';
import 'package:vidly/views/preview/preview_screen.dart';
import 'package:vidly/views/splash/splash_screen.dart';

import '../../views/home/home_screen.dart';

class RouteNames {
  static const String home = '/home';
  static const String splash = '/splash';
  static const String downloads = '/downloads';
  static const String preview = '/preview';
  static const String main = '/main';
}

class AppRoutes {
  static final transition = Transition.rightToLeft;
  static final duration = Duration(milliseconds: 600);
  static final appRoutes = [
    GetPage(
      name: RouteNames.home,
      page: () => HomeScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
    GetPage(
      name: RouteNames.splash,
      page: () => SplashScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
    GetPage(
      name: RouteNames.downloads,
      page: () => DownloadsScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
    GetPage(
      name: RouteNames.main,
      page: () => MainScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
    GetPage(
      name: RouteNames.preview,
      page: () => PreviewScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
  ];
}
