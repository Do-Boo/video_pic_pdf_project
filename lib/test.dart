import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Directory, FileSystemEntity, Platform;

class FolderItem {
  final String name;
  final String path;
  List<FolderItem> children;

  FolderItem(this.name, this.path, [this.children = const []]);
}

class FolderManagementApp extends StatelessWidget {
  const FolderManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folder Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FolderManagerHome(),
    );
  }
}

class FolderManagerHome extends StatefulWidget {
  const FolderManagerHome({super.key});

  @override
  _FolderManagerHomeState createState() => _FolderManagerHomeState();
}

class _FolderManagerHomeState extends State<FolderManagerHome> {
  List<FolderItem> folders = [];
  List<FolderItem> currentPath = [];

  @override
  void initState() {
    super.initState();
    _loadInitialDirectory();
  }

  Future<void> _loadInitialDirectory() async {
    Directory directory;
    if (Platform.isWindows || Platform.isMacOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      // For web, we'll use a mock directory
      directory = Directory('/');
    }
    _loadDirectory(directory.path);
  }

  Future<void> _loadDirectory(String path) async {
    if (Platform.isWindows || Platform.isMacOS) {
      final dir = Directory(path);
      final List<FileSystemEntity> entities = await dir.list().toList();
      setState(() {
        folders = entities.whereType<Directory>().map((entity) => FolderItem(entity.path.split(Platform.pathSeparator).last, entity.path)).toList();
      });
    } else {
      // For web, we'll use mock data
      setState(() {
        folders = [
          FolderItem('Documents', '/Documents'),
          FolderItem('Pictures', '/Pictures'),
          FolderItem('Downloads', '/Downloads'),
        ];
      });
    }
  }

  void _addNewFolder(String folderName) async {
    if (Platform.isWindows || Platform.isMacOS) {
      final path = currentPath.isEmpty ? folders.first.path : currentPath.last.path;
      final newFolderPath = '$path${Platform.pathSeparator}$folderName';
      final newDirectory = await Directory(newFolderPath).create();
      setState(() {
        if (currentPath.isEmpty) {
          folders.add(FolderItem(folderName, newDirectory.path));
        } else {
          currentPath.last.children.add(FolderItem(folderName, newDirectory.path));
        }
      });
    } else {
      // For web, just add to the list
      setState(() {
        if (currentPath.isEmpty) {
          folders.add(FolderItem(folderName, '/$folderName'));
        } else {
          currentPath.last.children.add(FolderItem(folderName, '${currentPath.last.path}/$folderName'));
        }
      });
    }
  }

  void _navigateToFolder(FolderItem folder) async {
    if (Platform.isWindows || Platform.isMacOS) {
      await _loadDirectory(folder.path);
    }
    setState(() {
      currentPath.add(folder);
    });
  }

  void _navigateBack() {
    setState(() {
      currentPath.removeLast();
      if (currentPath.isNotEmpty) {
        _loadDirectory(currentPath.last.path);
      } else {
        _loadInitialDirectory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folder Manager'),
        leading: currentPath.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : null,
      ),
      body: ListView.builder(
        itemCount: currentPath.isEmpty ? folders.length : currentPath.last.children.length,
        itemBuilder: (context, index) {
          final folder = currentPath.isEmpty ? folders[index] : currentPath.last.children[index];
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(folder.name),
            onTap: () => _navigateToFolder(folder),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newFolderName = '';
              return AlertDialog(
                title: const Text('Create New Folder'),
                content: TextField(
                  onChanged: (value) {
                    newFolderName = value;
                  },
                  decoration: const InputDecoration(hintText: "Folder Name"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Create'),
                    onPressed: () {
                      _addNewFolder(newFolderName);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const FolderManagementApp());
}
