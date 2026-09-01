const Duration feedCacheTtl = Duration(minutes: 30);

class FeedCacheEntry {
  final List<Object?> items;
  final Map<String, dynamic> meta;
  final DateTime storedAt;

  const FeedCacheEntry({
    required this.items,
    required this.meta,
    required this.storedAt,
  });

  bool isStale(DateTime now, [Duration ttl = feedCacheTtl]) =>
      now.difference(storedAt) > ttl;
}