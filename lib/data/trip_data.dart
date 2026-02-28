// Data model for trip planner form and saved items.

class TripData {
  String destination;
  DateTime? departDate;
  DateTime? returnDate;
  String budget;
  String currency;
  String participants;
  String ageRange;
  String additionalNotes;
  String aiPrompt;
  List<String> selectedInterests;

  TripData({
    this.destination = '',
    this.departDate,
    this.returnDate,
    this.budget = '',
    this.currency = 'VNĐ',
    this.participants = '',
    this.ageRange = '',
    this.additionalNotes = '',
    this.aiPrompt = '',
    this.selectedInterests = const [],
  });

  TripData copyWith({
    String? destination,
    DateTime? departDate,
    DateTime? returnDate,
    String? budget,
    String? currency,
    String? participants,
    String? ageRange,
    String? additionalNotes,
    String? aiPrompt,
    List<String>? selectedInterests,
  }) {
    return TripData(
      destination: destination ?? this.destination,
      departDate: departDate ?? this.departDate,
      returnDate: returnDate ?? this.returnDate,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      participants: participants ?? this.participants,
      ageRange: ageRange ?? this.ageRange,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

/// Represents a saved destination — either a full trip or a wishlist card.
class SavedItem {
  final String name;
  final String imageUrl;
  final String price;
  final int matchPercent;
  final double rating;
  final int reviewCount;
  final String aiInsight;
  final TripData? tripData; // non-null for full saves, null for wishlist-only
  final DateTime savedAt;

  SavedItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.matchPercent,
    required this.rating,
    required this.reviewCount,
    required this.aiInsight,
    this.tripData,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();
}
