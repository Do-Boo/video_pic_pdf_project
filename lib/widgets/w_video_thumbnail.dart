import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mom_project/service/api_data.dart';

class VideoThumbnailGenerator extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailGenerator({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailGenerator> createState() => _VideoThumbnailGeneratorState();
}

class _VideoThumbnailGeneratorState extends State<VideoThumbnailGenerator> {
  String? _thumbnailUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final response = await http.post(
        Uri.parse('http://$synologyApi/video_thumbnail_api.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'video_url': widget.videoUrl,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            _thumbnailUrl = result['thumbnail_url'];
          });
        } else {
          setState(() {
            _error = result['error'] ?? 'Unknown error occurred';
          });
        }
      } else {
        setState(() {
          _error = 'Server responded with status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('Error: $_error');
    }

    if (_thumbnailUrl == null) {
      return const CircularProgressIndicator();
    }

    return Image.network(
      _thumbnailUrl!,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          width: 200,
          height: 200,
          child: Center(child: Icon(Icons.error)),
        );
      },
    );
  }
}
