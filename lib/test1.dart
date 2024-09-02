import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mom_project/api/api_data.dart';
import 'dart:convert';
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

  runApp(GetMaterialApp(
    title: 'Synology Folder Explorer',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const LoginPage(),
  ));
}

class AuthController extends GetxController {
  final _sid = ''.obs;

  String get sid => _sid.value;

  Future<bool> login() async {
    const String baseUrl = 'http://$nasUrl:$nasPort/webapi/auth.cgi';
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?api=SYNO.API.Auth&version=3&method=login&account=$nasUsername&passwd=$nasPassword&session=FileStation&format=cookie'),
      );

      debugPrint('Login API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _sid.value = data['data']['sid'];
          return true;
        }
      }
    } catch (e) {
      debugPrint('Login exception: $e');
    }
    return false;
  }

  Future<bool> refreshSession() async {
    return await login();
  }
}

class FolderController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final _items = <Map<String, dynamic>>[].obs;
  final _currentPath = '/'.obs;
  final _error = ''.obs;
  final _isLoading = false.obs;

  List<Map<String, dynamic>> get items => _items;
  String get currentPath => _currentPath.value;
  String get error => _error.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchSharedFolders();
  }

  Future<void> fetchSharedFolders() async {
    _isLoading.value = true;
    _error.value = '';

    var url = 'http://doboo.tplinkdns.com:5000/webapi/entry.cgi';
    try {
      var response = await http.post(Uri.parse(url), body: {
        'api': 'SYNO.FileStation.List',
        'version': '2',
        'method': 'list_share',
        '_sid': authController.sid,
      });

      debugPrint('Shared Folders API Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        debugPrint('Decoded shared folders data: $data');

        if (data != null && data['success'] == true) {
          if (data['data'] != null && data['data']['shares'] != null) {
            _items.value = List<Map<String, dynamic>>.from(data['data']['shares']);
            _currentPath.value = '/';
          } else {
            _error.value = '공유 폴더를 찾을 수 없습니다.';
          }
        } else {
          if (data['error']?['code'] == 408) {
            bool refreshed = await authController.refreshSession();
            if (refreshed) {
              fetchSharedFolders();
              return;
            }
          }
          _error.value = 'API 오류: ${data['error']?['code'] ?? '알 수 없는 오류'}';
        }
      } else {
        _error.value = 'HTTP 오류: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Shared folders fetch exception: $e');
      _error.value = '예외 발생: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchFolderContents(String path) async {
    _isLoading.value = true;
    _error.value = '';

    var url = 'http://$nasUrl:$nasPort/webapi/entry.cgi';
    try {
      var response = await http.post(Uri.parse(url), body: {
        'api': 'SYNO.FileStation.List',
        'version': '2',
        'method': 'list',
        'folder_path': path,
        '_sid': authController.sid,
      });

      debugPrint('Folder Contents API Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        debugPrint('Decoded folder contents data: $data');

        if (data != null && data['success'] == true) {
          if (data['data'] != null && data['data']['files'] != null) {
            _items.value = List<Map<String, dynamic>>.from(data['data']['files']);
            _currentPath.value = path;
          } else {
            _error.value = '이 폴더에 파일이나 하위 폴더가 없습니다.';
            _items.clear();
          }
        } else {
          if (data['error']?['code'] == 408) {
            bool refreshed = await authController.refreshSession();
            if (refreshed) {
              fetchFolderContents(path);
              return;
            }
          }
          _error.value = 'API 오류: ${data['error']?['code'] ?? '알 수 없는 오류'}';
        }
      } else {
        _error.value = 'HTTP 오류: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Folder contents fetch exception: $e');
      _error.value = '예외 발생: $e';
    } finally {
      _isLoading.value = false;
    }
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(title: const Text('Synology NAS 로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: TextEditingController(text: nasUsername),
              decoration: const InputDecoration(labelText: '사용자 이름'),
            ),
            TextField(
              controller: TextEditingController(text: nasPassword),
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (await authController.login()) {
                  Get.off(() => const FolderExplorerPage());
                } else {
                  Get.snackbar('로그인 실패', '사용자 이름이나 비밀번호를 확인해주세요.');
                }
              },
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

class FolderExplorerPage extends StatelessWidget {
  const FolderExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FolderController folderController = Get.put(FolderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synology 폴더 탐색기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => folderController.currentPath == '/'
                ? folderController.fetchSharedFolders()
                : folderController.fetchFolderContents(folderController.currentPath),
          ),
        ],
      ),
      body: Obx(() => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('현재 경로: ${folderController.currentPath}'),
              ),
              if (folderController.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(folderController.error, style: const TextStyle(color: Colors.red)),
                ),
              if (folderController.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: folderController.items.isEmpty
                      ? Center(child: Text(folderController.error.isEmpty ? '항목이 없습니다' : folderController.error))
                      : ListView.builder(
                          itemCount: folderController.items.length,
                          itemBuilder: (context, index) {
                            var item = folderController.items[index];
                            bool isFolder = item['isdir'] == true;
                            return ListTile(
                              leading: Icon(isFolder ? Icons.folder : Icons.insert_drive_file),
                              title: Text(item['name'] ?? '이름 없음'),
                              onTap: isFolder ? () => folderController.fetchFolderContents(item['path'] ?? folderController.currentPath) : null,
                            );
                          },
                        ),
                ),
            ],
          )),
      floatingActionButton: Obx(() => folderController.currentPath != '/'
          ? FloatingActionButton(
              onPressed: folderController.fetchSharedFolders,
              tooltip: '공유 폴더로 돌아가기',
              child: const Icon(Icons.home),
            )
          : const SizedBox.shrink()),
    );
  }
}
