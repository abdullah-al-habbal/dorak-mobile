# Storage

Status: `DONE`

## Purpose

`packages/core` owns all device persistence. Apps must not add a second storage
stack; they consume the contracts below through `package:core/core.dart`.

Two stores, split by sensitivity:

| Store | Backing | Holds |
| --- | --- | --- |
| `TokenStorage` | `flutter_secure_storage` (Keychain / EncryptedSharedPreferences) | the Sanctum bearer token |
| `AppPreferences` | `shared_preferences` | `dontShowOnboarding` |

Both are declared as abstract classes so tests substitute in-memory fakes and
never touch a platform channel.

## TokenStorage

`lib/src/storage/token.storage.dart`

```dart
abstract class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}
```

`SecureTokenStorage` is the production implementation. Key `dorak_client_token`;
Android uses `AndroidOptions(encryptedSharedPreferences: true)`. `read()`
normalises an empty string to `null` so callers only test for null.

The token is the credential for a **non-expiring** server-side session
(`SANCTUM_EXPIRATION` is unset on the backend), which is why it must not live in
plain preferences.

`ApiClient` is wired to it directly:

```dart
ApiClient(
  baseUrl: ConfigProvider.config.apiBaseV1Url,
  tokenProvider: _tokenStorage.read,   // activates AuthInterceptor
);
```

Reading storage rather than the session layer keeps construction acyclic —
`SessionBloc` depends on `ApiClient`, not the other way round.

## AppPreferences

`lib/src/storage/preferences.storage.dart`

```dart
abstract class AppPreferences {
  bool get dontShowOnboarding;
  Future<void> setDontShowOnboarding(bool value);
}
```

`dontShowOnboarding` is a **synchronous** getter: the post-splash gate branches
on it without an await. `SharedAppPreferences` therefore wraps an
already-resolved `SharedPreferences` instance; use the async factory once during
bootstrap:

```dart
final preferences = await SharedAppPreferences.create();
```

Key `dont_show_onboarding`, default `false`. Semantics are defined in
`flows/onboarding.md` — in particular `Skip for now` does **not** set it.

`create()` exists so apps never declare `shared_preferences` themselves.

## Feed cache (Track 05 — cache strategy, `DONE`)

`FeedCache` / `SharedFeedCache` (`feed_cache.storage.dart`) is the cache
strategy. Its first consumer is Discovery 016
(`docs/future-features/discovery-016.md` §5); nothing else reads it yet.

Design:

* **Wire payload, not DTOs.** Feed stores the raw item maps + pagination meta
  from a real response. DTOs use `createToJson: false`, so a cache read
  re-parses through the same `itemParser`/`PaginationMeta.fromJson` as the
  network path — one parse path, no second serialization format.
* **Bounded keys.** `keyFor(universe, latitude, longitude, radius, perPage)`:
  lat/long rounded to 3 dp (≈111 m), radius snapped to a 5 km bucket,
  `universe` + `per_page` exact. Local feeds for the same neighbourhood hit the
  same entry; distance-ranked requests don't explode the key space.
* **Staleness is read-time, not write-time.** `FeedCacheEntry{items, meta,
  storedAt}` + `isStale(now, [ttl])`; default `feedCacheTtl` = 30 min. The store
  never refuses to return — the consumer decides (offline retry renders stale,
  pull-to-refresh revalidates). A TTL inside the store would force re-fetch in
  the one situation the cache exists for.
* **Eviction is explicit.** Universe switch / filter change → `evict(key)` then
  re-query; `clear()` drops every `dorak_cache:v1:` key (logout, cache reset).
* **Corrupt payloads read as `null`**, never throw.

```dart
final cache = await SharedFeedCache.create();
final key = cache.keyFor(
  universe: 'men',
  latitude: 33.5138,
  longitude: 36.2765,
  radius: 10,
);
final cached = await cache.read(key);          // FeedCacheEntry? — consumer
if (cached != null && !cached.isStale(DateTime.now())) {
  // render from cache; refresh in the background
}
```

Profile-completion persistence is still absent (Track 05 objective, consumer is
Track 17). Locale is still in-memory only and resets on restart.

## Verification

```bash
dart run melos run analyze
dart run melos run test    # packages/core/test/storage_test.dart, feed_cache_test.dart
```
