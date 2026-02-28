/// Model for destination detail displayed on the Destination Detail screen.
class DestinationDetail {
  final String name;
  final String location;
  final String imageUrl;
  final List<String> tags;
  final String weather;
  final String dateRange;
  final String totalBudget;
  final List<BudgetItem> budgetBreakdown;

  const DestinationDetail({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.tags,
    required this.weather,
    required this.dateRange,
    required this.totalBudget,
    required this.budgetBreakdown,
  });

  factory DestinationDetail.fromJson(
    Map<String, dynamic> json,
    String imageUrl,
  ) {
    return DestinationDetail(
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imageUrl: imageUrl,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      weather: json['weather'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
      totalBudget: json['totalBudget'] as String? ?? '',
      budgetBreakdown:
          (json['budgetBreakdown'] as List<dynamic>?)
              ?.map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A single line-item in the estimated budget breakdown.
class BudgetItem {
  final String label;
  final String amount;
  final double fraction;
  final String icon;

  const BudgetItem({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.icon,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      label: json['label'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      fraction: (json['fraction'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon'] as String? ?? 'circle',
    );
  }

  Map<String, dynamic> toMap() => {
    'label': label,
    'amount': amount,
    'fraction': fraction,
    'icon': icon,
  };
}
