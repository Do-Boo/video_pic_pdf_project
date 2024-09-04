import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:mom_project/service/api_data.dart';
import 'package:mom_project/widgets/w_video_thumbnail.dart';
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
    home: const SizedBox(
      width: 200,
      height: 200,
      child: VideoThumbnailGenerator(
        videoUrl: 'https://doboo.tplinkdns.com/files/%EC%97%B0%EC%8A%B5%ED%8F%B4%EB%8D%94%201/asdf.mp4',
      ),
    ),
  ));
}

class SynologyFileManagerTest extends StatefulWidget {
  const SynologyFileManagerTest({super.key});

  @override
  _SynologyFileManagerTestState createState() => _SynologyFileManagerTestState();
}

class _SynologyFileManagerTestState extends State<SynologyFileManagerTest> {
  final String apiUrl = 'http://$synologyApi/synology_api.php';
  List<dynamic> items = [];
  String currentPath = '';

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'action': 'list',
          'path': currentPath,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      showErrorDialog('Failed to load items: $e');
    }
  }

  Future<void> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.fields['action'] = 'upload';
        request.fields['path'] = currentPath;
        request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('Server response: ${response.body}'); // 디버깅을 위한 출력

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            showSuccessDialog('File uploaded successfully');
            loadItems();
          } else {
            throw Exception(jsonResponse['error'] ?? 'Unknown error occurred');
          }
        } else {
          throw Exception('Server responded with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      showErrorDialog('File upload failed: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'action': 'delete',
          'path': filePath,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          showSuccessDialog('File deleted successfully');
          loadItems();
        } else {
          throw Exception(jsonResponse['error']);
        }
      } else {
        throw Exception('File deletion failed');
      }
    } catch (e) {
      showErrorDialog('File deletion failed: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synology File Manager Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: uploadFile,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Current Path: $currentPath'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(item['isDirectory'] ? Icons.folder : Icons.insert_drive_file),
                  title: Text(item['name']),
                  subtitle: Text(item['isDirectory'] ? 'Directory' : 'File'),
                  trailing: item['isDirectory']
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteFile(item['path']),
                        ),
                  onTap: item['isDirectory']
                      ? () {
                          setState(() {
                            currentPath = item['path'];
                            loadItems();
                          });
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentPath != '') {
            setState(() {
              currentPath = currentPath.substring(0, currentPath.lastIndexOf('/'));
              loadItems();
            });
          }
        },
        tooltip: 'Go to parent directory',
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}
