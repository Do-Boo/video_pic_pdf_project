import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_nas_file_controller.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final authController = Get.put(AuthController());
  await authController.login(); // 초기 로그인 수행

  runApp(GetMaterialApp(
    title: 'Synology Folder Explorer',
    theme: ThemeData(primarySwatch: Colors.blue),
    initialBinding: BindingsBuilder(() {
      Get.put(SynologyFileListController());
    }),
    home: const SomeView(),
  ));
}

class SomeView extends GetView<SynologyFileListController> {
  const SomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('파일 목록')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else {
          return ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              var item = controller.items[index];
              return ListTile(
                leading: Icon(item['isdir'] == true ? Icons.folder : Icons.insert_drive_file),
                title: Text(item['name'] ?? ''),
                onTap: item['isdir'] == true ? () => controller.navigateToFolder(item['path']) : null,
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToParentFolder,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
