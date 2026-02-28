import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Gold-standard example: PodcastCard widget
//
// Demonstrates all conventions required by the flutter:widgets skill:
//   ✅ Extends StatelessWidget with const constructor
//   ✅ All fields are final with explicit types
//   ✅ Colors from Theme.of(context) — no hardcoded hex values
//   ✅ Text styles from theme.textTheme
//   ✅ Static data imported from mock_data.dart (simulated below)
//   ✅ Clean composition — no deeply nested widget trees
// ---------------------------------------------------------------------------

/// Mock data — in a real project, this would live in `lib/data/mock_data.dart`.
class PodcastCardData {
  const PodcastCardData({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.duration,
    required this.episodeCount,
  });

  final String title;
  final String author;
  final String imageUrl;
  final String duration;
  final int episodeCount;
}

const samplePodcast = PodcastCardData(
  title: 'Design Systems Weekly',
  author: 'Sarah Chen',
  imageUrl: 'https://picsum.photos/seed/podcast/300/300',
  duration: '32 min',
  episodeCount: 147,
);

/// A card displaying podcast information.
///
/// Uses [Theme.of] for all color and text style references.
class PodcastCard extends StatelessWidget {
  const PodcastCard({super.key, required this.data, this.onTap});

  final PodcastCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _CoverImage(imageUrl: data.imageUrl),
            _CardBody(data: data),
          ],
        ),
      ),
    );
  }
}

/// Cover image section of the podcast card.
class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final colors = Theme.of(context).colorScheme;
          return Container(
            color: colors.surfaceContainerHighest,
            child: Icon(
              Icons.podcasts,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

/// Text and metadata section of the podcast card.
class _CardBody extends StatelessWidget {
  const _CardBody({required this.data});

  final PodcastCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            data.author,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetadataChip(icon: Icons.access_time, label: data.duration),
              const SizedBox(width: 12),
              _MetadataChip(
                icon: Icons.headphones,
                label: '${data.episodeCount} eps',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small chip showing an icon and a label.
class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
