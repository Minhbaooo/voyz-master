import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:voyz/data/mock_data.dart';
import 'package:voyz/data/saved_trips_provider.dart';
import 'package:voyz/data/trip_data.dart';
import 'package:voyz/screens/suggestions_screen.dart';
import 'package:voyz/theme/app_theme.dart';
import 'package:voyz/widgets/shared/bottom_nav_bar.dart';
import 'package:voyz/widgets/shared/glass_card.dart';
import 'package:voyz/widgets/shared/gradient_button.dart';
import 'package:voyz/widgets/shared/interest_chip.dart';

/// Smart Planner screen — AI-powered trip planning input form.
class SmartPlannerScreen extends StatefulWidget {
  const SmartPlannerScreen({super.key});

  @override
  State<SmartPlannerScreen> createState() => _SmartPlannerScreenState();
}

class _SmartPlannerScreenState extends State<SmartPlannerScreen> {
  final _promptController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _participantsController = TextEditingController();
  final _ageRangeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _departDate;
  DateTime? _returnDate;
  late List<bool> _selectedInterests;

  @override
  void initState() {
    super.initState();
    _selectedInterests = List.from(MockData.interestsSelected);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _participantsController.dispose();
    _ageRangeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDepart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDepart ? _departDate : _returnDate) ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: const Color(0xFF1A1C2E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1A1C2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _departDate = picked;
          // If return date is before depart, clear it
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Add date';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _onGetSuggestions() {
    // Collect selected interests
    final selected = <String>[];
    for (int i = 0; i < MockData.interests.length; i++) {
      if (_selectedInterests[i]) selected.add(MockData.interests[i]);
    }

    // Push data to provider
    SavedTripsProvider.of(context).updateTrip(
      TripData(
        destination: _destinationController.text,
        departDate: _departDate,
        returnDate: _returnDate,
        budget: _budgetController.text,
        participants: _participantsController.text,
        ageRange: _ageRangeController.text,
        additionalNotes: _notesController.text,
        aiPrompt: _promptController.text,
        selectedInterests: selected,
      ),
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SuggestionsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [const Color(0xFF1A1C2E), AppTheme.backgroundDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MockData.appName,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'Smart Planner',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: MockData.profileImageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (_, e, s) => Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        MockData.plannerGreeting,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── AI Prompt Box ──
                      _AiPromptBox(controller: _promptController),
                      const SizedBox(height: 24),

                      // ── Required Fields Label ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'REQUIRED INFO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Destination (text input) ──
                      _buildTextField(
                        icon: Icons.public,
                        label: 'Destination',
                        hint: 'Where to?',
                        controller: _destinationController,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 12),

                      // ── Depart / Return (date pickers) ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              icon: Icons.calendar_today,
                              label: 'Depart',
                              value: _formatDate(_departDate),
                              onTap: () => _pickDate(isDepart: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateField(
                              icon: Icons.calendar_month,
                              label: 'Return',
                              value: _formatDate(_returnDate),
                              onTap: () => _pickDate(isDepart: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Budget (decimal input) ──
                      _buildBudgetRow(),
                      const SizedBox(height: 12),

                      // ── Participants / Age Range ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              icon: Icons.group,
                              label: 'Participants',
                              hint: 'How many?',
                              controller: _participantsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              icon: Icons.cake,
                              label: 'Age Range',
                              hint: 'e.g. 25-35',
                              controller: _ageRangeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Interests ──
                      _buildInterests(),
                      const SizedBox(height: 24),

                      // ── Additional Notes (optional) ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PERSONALIZE YOUR TRIP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.5),
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'OPTIONAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.sticky_note_2,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ADDITIONAL NOTES',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: _notesController,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Dietary restrictions, mobility needs, special occasions...',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Action Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Free Explore',
                                style: TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: GradientButton(
                              label: 'Get AI Suggestions',
                              icon: Icons.arrow_forward,
                              height: 52,
                              onPressed: _onGetSuggestions,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomNavBar(currentIndex: 2, onTap: (_) {}),
    );
  }

  /// Text input field inside a GlassCard.
  Widget _buildTextField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Date picker field inside a GlassCard.
  Widget _buildDateField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final hasValue = value != 'Add date';
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasValue
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Amount
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payments,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
          ),
          // Currency
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.currency_exchange,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENCY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'VNĐ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sell,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'INTERESTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(MockData.interests.length, (i) {
              return InterestChip(
                label: MockData.interests[i],
                isSelected: _selectedInterests[i],
                onTap: () {
                  setState(
                    () => _selectedInterests[i] = !_selectedInterests[i],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// AI prompt textarea with branded border.
class _AiPromptBox extends StatelessWidget {
  const _AiPromptBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 20),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: MockData.plannerHint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: primaryColor.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              MockData.aiPoweredLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: primaryColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
