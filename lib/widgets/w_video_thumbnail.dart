import 'package:flutter/material.dart';
import 'package:mom_project/functions/f_video_thumbnail.dart';

class VideoThumbnail extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnail({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: VideoThumbnailExtractor.getThumbnail(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
          );
        } else if (snapshot.hasError) {
          return _buildErrorPlaceholder(message: 'Error loading thumbnail');
        } else {
          return const SizedBox(
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildErrorPlaceholder({String message = 'Thumbnail not available'}) {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Text(message)),
    );
  }
}
