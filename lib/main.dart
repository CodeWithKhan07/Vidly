import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:vidly/core/routes/app_routes.dart';

import 'core/bindings/app_bindings.dart';
import 'core/services/permission_service.dart';
import 'data/models/download_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await PermissionService.requestAllPermissions();
  await Hive.initFlutter();
  Hive.registerAdapter(DownloadTaskModelAdapter());
  Hive.registerAdapter(DownloadStatusAdapter());
  await Hive.openBox<DownloadTaskModel>('downloads');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blueAccent,
          selectionColor: Color(0xFF263238),
          selectionHandleColor: Colors.blueAccent,
        ),
      ),
      getPages: AppRoutes.appRoutes,
      initialRoute: RouteNames.splash,
    );
  }
}
