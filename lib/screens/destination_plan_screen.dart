import 'package:flutter/material.dart';
import 'package:voyz/data/saved_trips_provider.dart';
import 'package:voyz/models/itinerary_plan.dart';
import 'package:voyz/screens/saved_screen.dart';
import 'package:voyz/screens/smart_planner_screen.dart';
import 'package:voyz/screens/suggestions_screen.dart';
import 'package:voyz/services/gemini_service.dart';
import 'package:voyz/theme/app_theme.dart';
import 'package:voyz/widgets/shared/bottom_nav_bar.dart';
import 'package:voyz/widgets/shared/glass_card.dart';

/// Destination Plan screen — day-by-day itinerary timeline.
class DestinationPlanScreen extends StatefulWidget {
  const DestinationPlanScreen({
    super.key,
    required this.destinationName,
    required this.dateRange,
  });

  final String destinationName;
  final String dateRange;

  @override
  State<DestinationPlanScreen> createState() => _DestinationPlanScreenState();
}

class _DestinationPlanScreenState extends State<DestinationPlanScreen> {
  int _selectedDay = 0;
  ItineraryPlan? _plan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlan());
  }

  Future<void> _loadPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final trip = SavedTripsProvider.of(context).currentTrip;
      // Calculate number of days from date range or default to 3
      int numDays = 3;
      if (trip.departDate != null && trip.returnDate != null) {
        numDays = trip.returnDate!.difference(trip.departDate!).inDays;
        if (numDays < 1) numDays = 1;
        if (numDays > 7) numDays = 7; // Cap at 7 days
      }

      final plan = await GeminiService.instance.getItineraryPlan(
        widget.destinationName,
        numDays,
        trip,
        limit: 4,
      );
      if (mounted) {
        setState(() {
          _plan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SmartPlannerScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
          (route) => false,
        );
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'AI đang lên lịch trình...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _plan == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không thể tạo lịch trình',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'Lỗi không xác định',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _loadPlan,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final plan = _plan!;
    final currentDay = _selectedDay < plan.days.length
        ? plan.days[_selectedDay]
        : null;

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
              _buildHeaderBar(theme: theme, plan: plan),
              Expanded(
                child: Stack(
                  children: [
                    if (currentDay != null)
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentDay.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentDay.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _Timeline(items: currentDay.items),
                          ],
                        ),
                      ),
                    // Pro tip card
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 72,
                      child: _ProTipCard(theme: theme, tip: plan.proTip),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomNavBar(currentIndex: 0, onTap: _onNavTap),
    );
  }

  Widget _buildHeaderBar({
    required ThemeData theme,
    required ItineraryPlan plan,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleBtn(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
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
                      Text(
                        plan.destinationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.dateRange.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 40),
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
            itemCount: plan.days.length,
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
                    'Day ${plan.days[i].dayNumber}',
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
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── Timeline ────────────────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});
  final List<ItineraryItem> items;

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
      children: List.generate(items.length, (i) {
        final item = items[i];
        final isFirst = i == 0;
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
                        _iconMap[item.icon] ?? Icons.circle,
                        color: isFirst ? Colors.white : color,
                        size: 20,
                      ),
                    ),
                    if (i < items.length - 1)
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
                          item.time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
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
  const _ProTipCard({required this.theme, required this.tip});
  final ThemeData theme;
  final String tip;

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
                    text: tip,
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
