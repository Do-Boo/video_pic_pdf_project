import 'package:flutter/material.dart';

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(width: 88, color: Colors.red),
          Expanded(flex: 10, child: Container(color: Colors.blue)),
          Container(width: 256 + 24, color: Colors.yellow),
        ],
      ),
    );
  }
}
