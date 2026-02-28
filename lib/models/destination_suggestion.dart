/// Model for AI-suggested travel destinations displayed on the Suggestions screen.
class DestinationSuggestion {
  final String name;
  final String imageUrl;
  final int matchPercent;
  final double rating;
  final int reviewCount;
  final String price;
  final String aiInsight;
  final bool isTopMatch;

  const DestinationSuggestion({
    required this.name,
    required this.imageUrl,
    required this.matchPercent,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.aiInsight,
    this.isTopMatch = false,
  });

  factory DestinationSuggestion.fromJson(
    Map<String, dynamic> json,
    String imageUrl,
  ) {
    return DestinationSuggestion(
      name: json['name'] as String? ?? '',
      imageUrl: imageUrl,
      matchPercent: (json['matchPercent'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      price: json['price'] as String? ?? '',
      aiInsight: json['aiInsight'] as String? ?? '',
      isTopMatch: json['isTopMatch'] as bool? ?? false,
    );
  }

  /// Convert to Map for compatibility with existing UI widgets.
  Map<String, dynamic> toMap() => {
    'name': name,
    'imageUrl': imageUrl,
    'matchPercent': matchPercent,
    'rating': rating,
    'reviewCount': reviewCount,
    'price': price,
    'aiInsight': aiInsight,
    'isTopMatch': isTopMatch,
  };
}
