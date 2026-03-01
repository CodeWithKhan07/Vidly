import 'package:get/get.dart';
import 'package:vidly/controller/download_controller.dart';
import 'package:vidly/controller/home_controller.dart';
import 'package:vidly/core/services/notification_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => DownloadController(), fenix: true);
    Get.lazyPut(() => NotificationService(), fenix: true);
  }
}
