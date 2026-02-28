import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight cache layer on top of Hive.
///
/// Stores raw JSON strings from Gemini API responses, keyed by a hash
/// of the relevant input parameters. No TTL for demo use.
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  static const String _boxName = 'gemini_cache';

  /// Must be called once at app startup (after Hive.initFlutter).
  Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  /// Build a deterministic cache key from input parts.
  ///
  /// Sorts list values to ensure order-independence.
  String buildKey(String prefix, Map<String, dynamic> parts) {
    // Sort map entries and list values for consistency
    final sorted = parts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final buffer = StringBuffer(prefix);
    for (final entry in sorted) {
      buffer.write('|${entry.key}=');
      if (entry.value is List) {
        final list = List<String>.from(entry.value as List)..sort();
        buffer.write(list.join(','));
      } else {
        buffer.write(entry.value.toString());
      }
    }

    // Hash to keep the key short
    final bytes = utf8.encode(buffer.toString());
    return md5.convert(bytes).toString();
  }

  /// Get cached raw JSON string, or null if not cached.
  String? get(String key) {
    return _box.get(key);
  }

  /// Save raw JSON string to cache.
  Future<void> put(String key, String value) async {
    await _box.put(key, value);
  }

  /// Clear all cached data.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
