import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:voyz/data/mock_data.dart';
import 'package:voyz/data/saved_trips_provider.dart';
import 'package:voyz/screens/destination_plan_screen.dart';
import 'package:voyz/theme/app_theme.dart';
import 'package:voyz/widgets/shared/bottom_nav_bar.dart';
import 'package:voyz/widgets/shared/gradient_button.dart';

/// Destination Detail screen — hero image, tags, weather, budget breakdown.
class DestinationDetailScreen extends StatelessWidget {
  const DestinationDetailScreen({super.key});

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
        backgroundColor: AppTheme.primaryPink.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSaveInfo(BuildContext context) {
    SavedTripsProvider.of(context).saveFullTrip(
      name: MockData.detailName,
      imageUrl: MockData.detailHeroImageUrl,
      price: MockData.detailBudget,
      matchPercent: 98,
      rating: 4.5,
      reviewCount: 120,
      aiInsight: 'Perfect for your wellness budget. Dry season now.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bookmark_added, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Trip info saved! Check your Saved tab.')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroSection(
                  theme: theme,
                  onShare: () => _onShare(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LocationSubtitle(theme: theme),
                      const SizedBox(height: 8),
                      Text(
                        MockData.detailName,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TagsRow(),
                      const SizedBox(height: 24),
                      _WeatherCard(theme: theme),
                      const SizedBox(height: 16),
                      _BudgetCard(theme: theme),
                      const SizedBox(height: 32),
                      _ActionButtons(
                        theme: theme,
                        onSaveInfo: () => _onSaveInfo(context),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(currentIndex: 2, onTap: (_) {}),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.theme, required this.onShare});
  final ThemeData theme;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: MockData.detailHeroImageUrl,
            fit: BoxFit.cover,
            errorWidget: (ctx, url, err) =>
                Container(color: const Color(0xFF1E293B)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 1.0],
                colors: [Colors.transparent, AppTheme.backgroundDark],
              ),
            ),
          ),
          // Back + Share buttons at the very top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleBtn(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    _CircleBtn(icon: Icons.share, onTap: onShare),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: AppTheme.primaryPink, size: 22),
      ),
    );
  }
}

class _LocationSubtitle extends StatelessWidget {
  const _LocationSubtitle({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on, color: theme.colorScheme.tertiary, size: 20),
        const SizedBox(width: 4),
        Text(
          MockData.detailLocation.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.tertiary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _TagsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MockData.detailTags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sunny, 32°C',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  MockData.detailDateRange,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.theme});
  final ThemeData theme;

  static const _colors = [
    AppTheme.primaryPink,
    AppTheme.secondaryOrange,
    AppTheme.accentBlue,
    Color(0x33FFFFFF),
  ];
  static const _icons = {
    'flight': Icons.flight,
    'hotel': Icons.hotel,
    'restaurant': Icons.restaurant,
    'kayaking': Icons.kayaking,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATED BUDGET',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '~4.2M VNĐ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.payments,
                  color: theme.colorScheme.tertiary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: List.generate(MockData.budgetBreakdown.length, (i) {
                  final item = MockData.budgetBreakdown[i];
                  return Expanded(
                    flex: ((item['fraction'] as double) * 100).round(),
                    child: Container(color: _colors[i]),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: List.generate(MockData.budgetBreakdown.length, (i) {
              final item = MockData.budgetBreakdown[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[item['icon']] ?? Icons.circle,
                    size: 14,
                    color: _colors[i],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item['label']}: ${item['amount']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.theme, required this.onSaveInfo});
  final ThemeData theme;
  final VoidCallback onSaveInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientButton(
          label: 'Generate AI Itinerary',
          icon: Icons.auto_awesome,
          height: 56,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DestinationPlanScreen()),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OutlineBtn(
                label: 'Save Info',
                icon: Icons.bookmark,
                onPressed: onSaveInfo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Book Now',
                          style: TextStyle(
                            color: AppTheme.backgroundDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: AppTheme.backgroundDark,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.icon, this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
