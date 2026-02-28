import 'package:flutter/material.dart';
import 'package:voyz/data/mock_data.dart';
import 'package:voyz/theme/app_theme.dart';
import 'package:voyz/widgets/shared/bottom_nav_bar.dart';
import 'package:voyz/widgets/shared/glass_card.dart';

/// Destination Plan screen — day-by-day itinerary timeline.
class DestinationPlanScreen extends StatefulWidget {
  const DestinationPlanScreen({super.key});

  @override
  State<DestinationPlanScreen> createState() => _DestinationPlanScreenState();
}

class _DestinationPlanScreenState extends State<DestinationPlanScreen> {
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [const Color(0xFF0A1628), AppTheme.backgroundDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderBar(theme: theme),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MockData.dayTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            MockData.daySubtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _Timeline(),
                        ],
                      ),
                    ),
                    // Pro tip card
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 72,
                      child: _ProTipCard(theme: theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomNavBar(currentIndex: 2, onTap: (_) {}),
    );
  }

  Widget _buildHeaderBar({required ThemeData theme}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleBtn(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Côn Đảo, Vietnam',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MAR 15 - MAR 18',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              _CircleBtn(
                icon: Icons.favorite,
                onTap: () {},
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Day tabs
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: MockData.dayTabs.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isActive = i == _selectedDay;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.brandGradient : null,
                    color: isActive
                        ? null
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(999),
                    border: isActive
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryPink.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    MockData.dayTabs[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, this.onTap, this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 22),
      ),
    );
  }
}

// ── Timeline ────────────────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  static const _iconColors = [
    AppTheme.primaryPink,
    AppTheme.secondaryOrange,
    AppTheme.accentBlue,
    Color(0xFF34D399),
  ];

  static const _iconMap = <String, IconData>{
    'flight_land': Icons.flight_land,
    'hotel': Icons.hotel,
    'restaurant': Icons.restaurant,
    'beach_access': Icons.beach_access,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(MockData.itineraryItems.length, (i) {
        final item = MockData.itineraryItems[i];
        final isFirst = item['isFirst'] as bool;
        final color = _iconColors[i % _iconColors.length];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isFirst ? AppTheme.brandGradient : null,
                        color: isFirst
                            ? null
                            : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: isFirst
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        _iconMap[item['icon']] ?? Icons.circle,
                        color: isFirst ? Colors.white : color,
                        size: 20,
                      ),
                    ),
                    if (i < MockData.itineraryItems.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color, color.withValues(alpha: 0.1)],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GlassCard(
                    glowColor: isFirst ? AppTheme.primaryPink : null,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Pro Tip Card ────────────────────────────────────────────────────────

class _ProTipCard extends StatelessWidget {
  const _ProTipCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      glowColor: theme.colorScheme.primary,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, height: 1.4),
                children: [
                  TextSpan(
                    text: 'Pro Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: MockData.proTip,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
