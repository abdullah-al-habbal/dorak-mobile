import 'dart:convert';

import 'package:core/src/storage/feed_cache_entry.entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FeedCache {
  String keyFor({
    required String universe,
    required double latitude,
    required double longitude,
    required double radius,
    int perPage = 20,
  });

  Future<FeedCacheEntry?> read(String key);

  Future<void> write(String key, FeedCacheEntry entry);

  Future<void> evict(String key);

  Future<void> clear();
}

class SharedFeedCache implements FeedCache {
  static const String _prefix = 'dorak_cache:v1:';

  final SharedPreferences _prefs;

  SharedFeedCache(this._prefs);

  static Future<SharedFeedCache> create() async {
    return SharedFeedCache(await SharedPreferences.getInstance());
  }

  static double _roundToThree(final double value) =>
      (value * 1000).round() / 1000;

  @override
  String keyFor({
    required String universe,
    required double latitude,
    required double longitude,
    required double radius,
    int perPage = 20,
  }) {
    final latitudeKey = _roundToThree(latitude);
    final longitudeKey = _roundToThree(longitude);
    final radiusBucket = (radius / 5).round() * 5;
    return '$_prefix$universe:$latitudeKey:$longitudeKey:$radiusBucket:$perPage';
  }

  @override
  Future<FeedCacheEntry?> read(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return FeedCacheEntry(
        items: decoded['items'] as List<Object?>,
        meta: (decoded['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
        storedAt: DateTime.parse(decoded['stored_at'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, FeedCacheEntry entry) =>
      _prefs.setString(
        key,
        jsonEncode({
          'items': entry.items,
          'meta': entry.meta,
          'stored_at': entry.storedAt.toIso8601String(),
        }),
      );

  @override
  Future<void> evict(String key) => _prefs.remove(key);

  @override
  Future<void> clear() async {
    final keys = _prefs
        .getKeys()
        .where((final key) => key.startsWith(_prefix))
        .toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}