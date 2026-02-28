import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:voyz/data/mock_data.dart';
import 'package:voyz/data/saved_trips_provider.dart';
import 'package:voyz/screens/destination_detail_screen.dart';
import 'package:voyz/screens/saved_screen.dart';
import 'package:voyz/screens/smart_planner_screen.dart';
import 'package:voyz/theme/app_theme.dart';
import 'package:voyz/widgets/shared/bottom_nav_bar.dart';

/// AI Travel Suggestions screen — scrollable list of AI-recommended destinations.
class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SmartPlannerScreen()),
          (route) => false,
        );
        break;
      case 1:
        // Already on Explore
        break;
      case 2:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SavedScreen()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0A16), Color(0xFF1A1528)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              _Header(theme: theme),

              // ── Destination Cards ──
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: MockData.destinations.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final dest = MockData.destinations[index];
                    return _DestinationCard(
                      data: dest,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DestinationDetailScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomNavBar(currentIndex: 1, onTap: _onNavTap),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              // Instead of maybePop, push back/replace with SmartPlannerScreen
              // to ensure we load the data and nav state correctly.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SmartPlannerScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.brandGradient.createShader(bounds),
                child: const Text(
                  'AIVIVU',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Travel Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

// ── Destination Card ────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.data, this.onTap});

  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTopMatch = data['isTopMatch'] as bool;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isTopMatch
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: isTopMatch
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            _CardImage(data: data, isTopMatch: isTopMatch),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(data: data, theme: theme),
                  const SizedBox(height: 12),
                  _AiInsightBox(data: data, isTopMatch: isTopMatch),
                  const SizedBox(height: 16),
                  _CardActions(theme: theme, data: data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.data, required this.isTopMatch});
  final Map<String, dynamic> data;
  final bool isTopMatch;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: data['imageUrl'] as String,
            fit: BoxFit.cover,
            errorWidget: (_, e, s) => Container(
              color: const Color(0xFF1E293B),
              child: const Icon(Icons.image, color: Colors.white24, size: 48),
            ),
          ),
          // Match badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isTopMatch ? AppTheme.brandGradient : null,
                color: isTopMatch ? null : Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: isTopMatch
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${data['matchPercent']}% Match${isTopMatch ? ' ✨' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.data, required this.theme});
  final Map<String, dynamic> data;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final rating = (data['rating'] as num).toDouble();
    final fullStars = rating.floor();
    final hasHalf = rating - fullStars >= 0.5;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(
                    fullStars,
                    (_) => const Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xFFFF8E53),
                    ),
                  ),
                  if (hasHalf)
                    const Icon(
                      Icons.star_half,
                      size: 16,
                      color: Color(0xFFFF8E53),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    '(${data['reviewCount']} reviews)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              data['price'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const Text(
              '/ person',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AiInsightBox extends StatelessWidget {
  const _AiInsightBox({required this.data, required this.isTopMatch});
  final Map<String, dynamic> data;
  final bool isTopMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTopMatch
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTopMatch
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.5),
          children: [
            TextSpan(
              text: '💡 AI Insight: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isTopMatch
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
              ),
            ),
            TextSpan(
              text: data['aiInsight'] as String,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions({required this.theme, required this.data});
  final ThemeData theme;
  final Map<String, dynamic> data;

  void _onAddToWishlist(BuildContext context) {
    final added = SavedTripsProvider.of(context).saveToWishlist(
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String,
      price: data['price'] as String,
      matchPercent: data['matchPercent'] as int,
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'] as int,
      aiInsight: data['aiInsight'] as String,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              added ? Icons.favorite : Icons.info_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                added
                    ? '${data['name']} added to wishlist!'
                    : '${data['name']} is already saved!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: added
            ? AppTheme.primaryPink.withValues(alpha: 0.9)
            : const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Share link copied!'),
          ],
        ),
        backgroundColor: const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Share button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _onShare(context),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Add to Wishlist button
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () => _onAddToWishlist(context),
            icon: Icon(
              Icons.favorite_outline,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Add to Wishlist',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.08,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
