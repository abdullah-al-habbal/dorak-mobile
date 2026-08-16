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

## Not yet implemented

Cache strategy and profile-completion persistence (Track 05 objectives, Track 17
consumer) have no implementation. Locale is still in-memory only and resets on
restart.

## Verification

```bash
dart run melos run analyze
dart run melos run test    # packages/core/test/storage_test.dart
```
