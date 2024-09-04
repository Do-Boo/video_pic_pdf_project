import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class VideoThumbnailExtractor {
  static Future<String?> getThumbnail(String videoUrl) async {
    String? thumbnailUrl = await _extractOgImage(videoUrl);
    thumbnailUrl ??= await _getServerGeneratedThumbnail(videoUrl);
    return thumbnailUrl;
  }

  static Future<String?> _extractOgImage(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final ogImage = document.querySelector('meta[property="og:image"]');
        if (ogImage != null) {
          return ogImage.attributes['content'];
        }
      }
    } catch (e) {
      debugPrint('Error extracting OG image: $e');
    }
    return null;
  }

  static Future<String?> _getServerGeneratedThumbnail(String videoUrl) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-server.com/generate-thumbnail'),
        body: {'videoUrl': videoUrl},
      );
      if (response.statusCode == 200) {
        return response.body; // 서버에서 반환한 썸네일 URL
      }
    } catch (e) {
      debugPrint('Error generating thumbnail on server: $e');
    }
    return null;
  }
}
