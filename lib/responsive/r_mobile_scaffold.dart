import 'package:flutter/material.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(width: 88, color: Colors.red),
          Expanded(flex: 10, child: Container(color: Theme.of(context).primaryColor)),
          Container(width: 256 + 24, color: Colors.yellow),
        ],
      ),
    );
  }
}
