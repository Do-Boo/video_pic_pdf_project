import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Titlebar Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: getPlatformSpecificHome(),
    );
  }

  Widget getPlatformSpecificHome() {
    if (kIsWeb) {
      return const MyHomePage(title: 'Web App - No Titlebar');
    } else if (Platform.isWindows || Platform.isMacOS) {
      return const CustomTitleBar(child: MyHomePage(title: 'Desktop App'));
    } else {
      return const MyHomePage(title: 'Mobile App');
    }
  }
}

class CustomTitleBar extends StatelessWidget {
  final Widget child;

  const CustomTitleBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Text('Custom Titlebar', style: TextStyle(color: Colors.white)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.minimize, color: Colors.white, size: 20),
                onPressed: () {
                  // Implement minimize functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.crop_square, color: Colors.white, size: 20),
                onPressed: () {
                  // Implement maximize functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  // Implement close functionality
                },
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? null : AppBar(title: Text(title)),
      body: Center(
        child: Text('This is the main content of the $title'),
      ),
    );
  }
}
