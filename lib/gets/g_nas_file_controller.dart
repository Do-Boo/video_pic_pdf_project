import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:mom_project/api/api_data.dart';

class AuthController extends GetxController {
  final RxString _sid = ''.obs;

  String get sid => _sid.value;
  RxString get rxSid => _sid;

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

class SynologyFileListController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxString currentPath = '/'.obs;
  final RxString error = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(authController.rxSid, (_) => fetchFileList());
    fetchFileList();
  }

  Future<void> fetchFileList({String? path}) async {
    isLoading.value = true;
    error.value = '';

    final String targetPath = path ?? currentPath.value;
    final String method = targetPath == '/' ? 'list_share' : 'list';

    var url = 'http://$nasUrl:$nasPort/webapi/entry.cgi';
    try {
      var response = await http.post(Uri.parse(url), body: {
        'api': 'SYNO.FileStation.List',
        'version': '2',
        'method': method,
        'folder_path': targetPath,
        '_sid': authController.sid,
        'additional': '["size","time","perm","type","owner","real_path"]',
      });

      debugPrint('File List API Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        debugPrint('Decoded file list data: $data');

        if (data != null && data['success'] == true) {
          if (data['data'] != null) {
            List<Map<String, dynamic>> processedItems = [];
            if (method == 'list_share') {
              for (var share in data['data']['shares']) {
                int count = await getSubItemCount(share['path']);
                bool hasSubfolders = await checkForSubfolders(share['path']);
                processedItems.add({
                  ...share,
                  'subItemCount': count,
                  'hasSubfolders': hasSubfolders,
                  'fileSize': formatFileSize(share['additional']['size'] as int?),
                  'isdir': true,
                });
              }
            } else {
              for (var file in data['data']['files']) {
                if (file['isdir']) {
                  int count = await getSubItemCount(file['path']);
                  bool hasSubfolders = await checkForSubfolders(file['path']);
                  processedItems.add({
                    ...file,
                    'subItemCount': count,
                    'hasSubfolders': hasSubfolders,
                    'fileSize': formatFileSize(file['additional']['size'] as int?),
                  });
                } else {
                  processedItems.add({
                    ...file,
                    'fileSize': formatFileSize(file['additional']['size'] as int?),
                    'fileExtension': getFileExtension(file['name']),
                  });
                }
              }
            }
            items.value = processedItems;
            debugPrint(items.toString());
            currentPath.value = targetPath;
          } else {
            error.value = '파일이나 폴더를 찾을 수 없습니다.';
            items.clear();
          }
        } else {
          if (data['error']?['code'] == 119 || data['error']?['code'] == 408) {
            debugPrint('세션 만료. 재로그인 시도...');
            bool loginSuccess = await authController.login();
            if (loginSuccess) {
              debugPrint('재로그인 성공. 파일 목록 다시 가져오기 시도...');
              await fetchFileList(path: targetPath);
              return;
            } else {
              error.value = '세션이 만료되었습니다. 다시 로그인해 주세요.';
            }
          } else {
            error.value = 'API 오류: ${data['error']?['code'] ?? '알 수 없는 오류'}';
          }
        }
      } else {
        error.value = 'HTTP 오류: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('File list fetch exception: $e');
      error.value = '예외 발생: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> getSubItemCount(String folderPath) async {
    var url = 'http://$nasUrl:$nasPort/webapi/entry.cgi';
    try {
      var response = await http.post(Uri.parse(url), body: {
        'api': 'SYNO.FileStation.List',
        'version': '2',
        'method': 'list',
        'folder_path': folderPath,
        '_sid': authController.sid,
        'limit': '0',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null && data['success'] == true) {
          return data['data']['total'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error getting sub-item count: $e');
    }
    return 0;
  }

  Future<bool> checkForSubfolders(String folderPath) async {
    var url = 'http://$nasUrl:$nasPort/webapi/entry.cgi';
    try {
      var response = await http.post(Uri.parse(url), body: {
        'api': 'SYNO.FileStation.List',
        'version': '2',
        'method': 'list',
        'folder_path': folderPath,
        '_sid': authController.sid,
        'limit': '1',
        'type': 'dir',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null && data['success'] == true) {
          return (data['data']['files'] as List).isNotEmpty;
        }
      }
    } catch (e) {
      debugPrint('Error checking for subfolders: $e');
    }
    return false;
  }

  String formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String getFileExtension(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    return (dotIndex != -1) ? fileName.substring(dotIndex + 1) : '';
  }

  void navigateToFolder(String path) {
    fetchFileList(path: path);
  }

  void goToParentFolder() {
    if (currentPath.value != '/') {
      String parentPath = currentPath.value.substring(0, currentPath.value.lastIndexOf('/'));
      if (parentPath.isEmpty) parentPath = '/';
      fetchFileList(path: parentPath);
    }
  }

  void refreshCurrentFolder() {
    fetchFileList(path: currentPath.value);
  }
}
