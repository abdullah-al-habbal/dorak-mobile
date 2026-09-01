import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime clock;
  late SharedFeedCache cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    clock = DateTime.utc(2026, 9, 2, 12);
    final prefs = await SharedPreferences.getInstance();
    cache = SharedFeedCache(prefs);
  });

  FeedCacheEntry entry(final List<Object?> items, [final DateTime? storedAt]) =>
      FeedCacheEntry(
        items: items,
        meta: const {'pagination': {'total_pages': 1}},
        storedAt: storedAt ?? clock,
      );

  group('key derivation', () {
    test('two queries for the same neighbourhood share a key', () {
      final a = cache.keyFor(
        universe: 'men',
        latitude: 33.513807,
        longitude: 36.276528,
        radius: 10,
      );
      final b = cache.keyFor(
        universe: 'men',
        latitude: 33.513809,
        longitude: 36.276531,
        radius: 12,
      );

      expect(a, b);
    });

    test('universe, radius bucket and per_page split keys', () {
      final men = cache.keyFor(
        universe: 'men',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      final women = cache.keyFor(
        universe: 'women',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      final widerRadius = cache.keyFor(
        universe: 'men',
        latitude: 0,
        longitude: 0,
        radius: 25,
      );
      final differentPageSize = cache.keyFor(
        universe: 'men',
        latitude: 0,
        longitude: 0,
        radius: 10,
        perPage: 40,
      );

      expect(men, isNot(women));
      expect(men, isNot(widerRadius));
      expect(men, isNot(differentPageSize));
    });

    test('far-apart coordinates do not collide', () {
      final damascus = cache.keyFor(
        universe: 'men',
        latitude: 33.5,
        longitude: 36.2,
        radius: 10,
      );
      final aleppo = cache.keyFor(
        universe: 'men',
        latitude: 36.2,
        longitude: 37.1,
        radius: 10,
      );

      expect(damascus, isNot(aleppo));
    });
  });

  group('read / write / evict / clear', () {
    test('a written entry round-trips item payload and storedAt', () async {
      final key = cache.keyFor(
        universe: 'men',
        latitude: 33.5,
        longitude: 36.2,
        radius: 10,
      );
      await cache.write(key, entry([
        {'id': 1, 'name': 'The Royal Barber'},
        {'id': 2, 'name': 'Elite Salon'},
      ]));

      final read = await cache.read(key);

      expect(read, isNotNull);
      expect(read!.items, hasLength(2));
      expect((read.items.first as Map)['name'], 'The Royal Barber');
      expect(read.storedAt, clock);
    });

    test('an absent key reads as null', () async {
      expect(await cache.read('dorak_cache:v1:women:0:0:0:20'), isNull);
    });

    test('evict removes only the targeted key', () async {
      final men = cache.keyFor(
        universe: 'men',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      final women = cache.keyFor(
        universe: 'women',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      await cache.write(men, entry([]));
      await cache.write(women, entry([]));

      await cache.evict(men);

      expect(await cache.read(men), isNull);
      expect(await cache.read(women), isNotNull);
    });

    test('clear removes all stored feeds', () async {
      final men = cache.keyFor(
        universe: 'men',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      final women = cache.keyFor(
        universe: 'women',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      await cache.write(men, entry([]));
      await cache.write(women, entry([]));

      await cache.clear();

      expect(await cache.read(men), isNull);
      expect(await cache.read(women), isNull);
    });
  });

  group('staleness', () {
    test('a fresh entry is not stale', () {
      final cached = entry([], clock);

      expect(cached.isStale(clock), isFalse);
      expect(cached.isStale(clock.add(const Duration(minutes: 29))), isFalse);
    });

    test('an entry older than the ttl is stale', () {
      final cached = entry([], clock);

      expect(cached.isStale(clock.add(const Duration(minutes: 31))), isTrue);
    });

    test('a custom ttl overrides the default', () {
      final cached = entry([], clock);

      expect(
        cached.isStale(
          clock.add(const Duration(hours: 2)),
          const Duration(hours: 1),
        ),
        isTrue,
      );
    });
  });

  group('corruption', () {
    test('an unparseable payload reads as null instead of throwing', () async {
      final key = cache.keyFor(
        universe: 'men',
        latitude: 0,
        longitude: 0,
        radius: 10,
      );
      SharedPreferences.setMockInitialValues({key: 'not-json'});
      final prefs = await SharedPreferences.getInstance();

      final rebuilt = SharedFeedCache(prefs);

      expect(await rebuilt.read(key), isNull);
    });
  });
}