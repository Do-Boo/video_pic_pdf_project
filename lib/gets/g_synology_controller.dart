import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mom_project/service/api_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class FileItem {
  final String name;
  final bool isDirectory;
  final String? extension;
  final String path;

  FileItem({required this.name, required this.isDirectory, this.extension, required this.path});

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'],
      isDirectory: json['isDirectory'],
      extension: json['extension'],
      path: json['path'],
    );
  }
}

class SynologyFileManagerController extends GetxController {
  final RxString currentPath = '/'.obs;
  final RxList<FileItem> items = <FileItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isUploading = false.obs;

  Future<void> loadItems({String? path}) async {
    isLoading.value = true;
    error.value = '';
    if (path != null) {
      currentPath.value = path;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$synologyApi/synology_api.php'),
        body: json.encode({
          'action': 'list',
          'path': currentPath.value,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        items.value = (json.decode(response.body) as List).map((item) => FileItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      error.value = 'Failed to load items: $e';
      Get.snackbar('Error', error.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> getSubfolderCount(String folder) async {
    try {
      final response = await http.post(
        Uri.parse('http://$synologyApi/synology_api.php'),
        body: json.encode({
          'action': 'subfolder_count',
          'path': path.join(currentPath.value, folder),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get subfolder count');
      }
    } catch (e) {
      error.value = 'Failed to get subfolder count: $e';
      Get.snackbar('Error', error.value);
      return 0;
    }
  }

  Future<List<FileItem>> searchFiles({String searchTerm = '', String fileType = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('http://$synologyApi/synology_api.php'),
        body: json.encode({
          'action': 'search_files',
          'searchTerm': searchTerm,
          'fileType': fileType,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResult = json.decode(response.body);
        items.value = (json.decode(response.body) as List).map((item) => FileItem.fromJson(item)).toList();
        return jsonResult.map((item) => FileItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search files');
      }
    } catch (e) {
      error.value = 'Failed to search files: $e';
      Get.snackbar('Error', error.value);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getFolderSize(String folder) async {
    try {
      final response = await http.post(
        Uri.parse('http://$synologyApi/synology_api.php'),
        body: json.encode({
          'action': 'size',
          'path': path.join(currentPath.value, folder),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        int size = json.decode(response.body);
        return '${(size / 1024 / 1024).toStringAsFixed(2)} MB';
      } else {
        throw Exception('Failed to get folder size');
      }
    } catch (e) {
      error.value = 'Failed to get folder size: $e';
      Get.snackbar('Error', error.value);
      return '0 MB';
    }
  }

  Future<void> pickAndUploadFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: kIsWeb,
    );

    if (result != null) {
      isUploading.value = true;
      List<PlatformFile> files = result.files;
      List<String> successfulUploads = [];
      List<String> failedUploads = [];

      for (PlatformFile file in files) {
        bool success = await _uploadSingleFile(file);
        if (success) {
          successfulUploads.add(file.name);
        } else {
          failedUploads.add(file.name);
        }
      }

      isUploading.value = false;
      await loadItems(); // 업로드 후 파일 목록 새로고침

      _showUploadResult(successfulUploads, failedUploads);
    }
  }

  Future<bool> _uploadSingleFile(PlatformFile file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://$synologyApi/synology_api.php'));
      request.fields['action'] = 'upload';
      request.fields['path'] = currentPath.value;

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', file.path!, filename: file.name));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        error.value = 'Failed to upload ${file.name}: Server responded with status code ${response.statusCode}';
        return false;
      }
    } catch (e) {
      error.value = 'Failed to upload ${file.name}: $e';
      return false;
    }
  }

  void _showUploadResult(List<String> successfulUploads, List<String> failedUploads) {
    if (successfulUploads.isNotEmpty) {
      Get.snackbar(
        'Upload Success',
        'Successfully uploaded: ${successfulUploads.join(", ")}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    if (failedUploads.isNotEmpty) {
      Get.snackbar(
        'Upload Failed',
        'Failed to upload: ${failedUploads.join(", ")}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> deleteItem(String itemName) async {
    try {
      final response = await http.post(
        Uri.parse('http://$synologyApi/synology_api.php'),
        body: json.encode({
          'action': 'delete',
          'path': path.join(currentPath.value, itemName),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await loadItems();
        Get.snackbar('Success', 'Item deleted successfully');
        return true;
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      error.value = 'Failed to delete item: $e';
      Get.snackbar('Error', error.value);
      return false;
    }
  }

  void navigateToParentDirectory() {
    if (currentPath.value.isNotEmpty) {
      currentPath.value = path.dirname(currentPath.value);
      loadItems();
    }
  }

  void navigateToFolder(String folderPath) {
    currentPath.value = folderPath;
    loadItems();
  }

  String getCurrentPath() {
    return currentPath.value;
  }

  List<FileItem> getItems() {
    return items;
  }

  bool getIsLoading() {
    return isLoading.value;
  }

  String getErrorMessage() {
    return error.value;
  }
}
