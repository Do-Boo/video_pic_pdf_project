import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mom_project/widgets/w_video_thumbnail.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  VideoPlayerMediaKit.ensureInitialized(macOS: true);

  MediaKit.ensureInitialized();

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

  runApp(
    GetMaterialApp(
      home: Container(
        color: Colors.blueGrey,
        child: const Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: VideoThumbnail(videoPath: 'https://doboo.tplinkdns.com/files/aa.mp4')),
                  Expanded(child: VideoThumbnail(videoPath: 'http://doboo.tplinkdns.com/files/연습폴더%201/asdf.mp4')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: VideoThumbnail(videoPath: 'http://doboo.tplinkdns.com/files/연습폴더%201/asdf.mp4')),
                  Expanded(child: VideoThumbnail(videoPath: 'https://doboo.tplinkdns.com/files/aa.mp4')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
