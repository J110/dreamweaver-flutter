import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dreamweaver/config/theme.dart';

enum ContentType { story, poem, song }

class AlbumArtDisplay extends StatelessWidget {
  final String url;
  final String contentType;
  final double? size;
  final bool hasGlow;

  const AlbumArtDisplay({
    Key? key,
    required this.url,
    required this.contentType,
    this.size = 200,
    this.hasGlow = false,
  }) : super(key: key);

  IconData _getContentTypeIcon() {
    switch (contentType.toLowerCase()) {
      case 'poem':
        return Icons.edit_outlined;
      case 'song':
        return Icons.music_note;
      default:
        return Icons.book;
    }
  }

  Color _getContentTypeColor() {
    switch (contentType.toLowerCase()) {
      case 'poem':
        return Colors.pink;
      case 'song':
        return Colors.teal;
      default:
        return DreamTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BoxShadow> shadows = [];
    if (hasGlow) {
      shadows = [
        BoxShadow(
          color: DreamTheme.primary.withOpacity(0.5),
          blurRadius: 30,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: DreamTheme.secondary.withOpacity(0.3),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final color = _getContentTypeColor();
    final icon = _getContentTypeIcon();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: (size ?? 200) * 0.4,
          color: Colors.white,
        ),
      ),
    );
  }
}
