/// Model for the day-by-day itinerary plan displayed on the Plan screen.
class ItineraryPlan {
  final String destinationName;
  final String dateRange;
  final List<ItineraryDay> days;
  final String proTip;

  const ItineraryPlan({
    required this.destinationName,
    required this.dateRange,
    required this.days,
    required this.proTip,
  });

  factory ItineraryPlan.fromJson(Map<String, dynamic> json) {
    return ItineraryPlan(
      destinationName: json['destinationName'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      proTip: json['proTip'] as String? ?? '',
    );
  }
}

/// A single day within the itinerary.
class ItineraryDay {
  final int dayNumber;
  final String title;
  final String subtitle;
  final List<ItineraryItem> items;

  const ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A single activity/event within a day of the itinerary.
class ItineraryItem {
  final String time;
  final String title;
  final String description;
  final String icon;

  const ItineraryItem({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      time: json['time'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'circle',
    );
  }

  Map<String, dynamic> toMap() => {
    'time': time,
    'title': title,
    'description': description,
    'icon': icon,
    'isFirst': false,
  };
}
