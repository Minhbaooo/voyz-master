import 'package:flutter/material.dart';
import 'package:voyz/data/trip_data.dart';

/// InheritedWidget-based provider for sharing trip data and saved items
/// across screens without adding a state management dependency.
class SavedTripsProvider extends StatefulWidget {
  const SavedTripsProvider({super.key, required this.child});
  final Widget child;

  @override
  State<SavedTripsProvider> createState() => SavedTripsProviderState();

  /// Convenience accessor.
  static SavedTripsProviderState of(BuildContext context) {
    final state = context.findAncestorStateOfType<SavedTripsProviderState>();
    assert(state != null, 'No SavedTripsProvider found in widget tree');
    return state!;
  }
}

class SavedTripsProviderState extends State<SavedTripsProvider> {
  TripData _currentTrip = TripData();
  final List<SavedItem> _savedItems = [];

  TripData get currentTrip => _currentTrip;
  List<SavedItem> get savedItems => List.unmodifiable(_savedItems);

  /// Update the current trip form data.
  void updateTrip(TripData trip) {
    setState(() => _currentTrip = trip);
  }

  /// Save the full trip (planner data + destination detail) to the saved list.
  void saveFullTrip({
    required String name,
    required String imageUrl,
    required String price,
    required int matchPercent,
    required double rating,
    required int reviewCount,
    required String aiInsight,
  }) {
    setState(() {
      _savedItems.add(
        SavedItem(
          name: name,
          imageUrl: imageUrl,
          price: price,
          matchPercent: matchPercent,
          rating: rating,
          reviewCount: reviewCount,
          aiInsight: aiInsight,
          tripData: _currentTrip.copyWith(),
        ),
      );
    });
  }

  /// Save only the destination card to the wishlist (no planner data).
  void saveToWishlist({
    required String name,
    required String imageUrl,
    required String price,
    required int matchPercent,
    required double rating,
    required int reviewCount,
    required String aiInsight,
  }) {
    setState(() {
      _savedItems.add(
        SavedItem(
          name: name,
          imageUrl: imageUrl,
          price: price,
          matchPercent: matchPercent,
          rating: rating,
          reviewCount: reviewCount,
          aiInsight: aiInsight,
          tripData: null,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
