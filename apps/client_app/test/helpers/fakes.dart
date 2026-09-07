import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/session/auth_coordination.entity.dart';
import 'package:client_app/src/features/auth/change_password.bloc.dart';
import 'package:client_app/src/features/auth/password_recovery.bloc.dart';
import 'package:client_app/src/features/booking/booking.bloc.dart';
import 'package:client_app/src/features/discovery/discovery.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';

// todo: read this file, and I think is better to make a fakes folder and then move each block/class into a file for better code.
Widget routerHarness(AppRouter appRouter) {
  return MaterialApp.router(
    routerConfig: appRouter.router,
    debugShowCheckedModeBanner: false,
    theme: DorakTheme.forLocale(const Locale('en'), Brightness.light),
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

AppRouter buildRouter({
  required SessionBloc session,
  required AuthBloc auth,
  required AppPreferences preferences,
  required ApiClient apiClient,
  PasswordRecoveryBloc? recovery,
  AuthRepository? recoveryRepository,
  BookingBloc? bookings,
  ChangePasswordBloc? passwordChange,
  DiscoveryBloc? discovery,
  VoidCallback switchLocale = _noSwitchLocale,
}) {
  return AppRouter(
    session: session,
    auth: auth,
    recovery: recovery ??
        PasswordRecoveryBloc(recoveryRepository ?? FakeAuthRepository()),
    preferences: preferences,
    onboardingConfig: fakeOnboardingConfig(),
    bookings: bookings ?? fakeBookingBloc(),
    passwordChange: passwordChange ??
        ChangePasswordBloc(recoveryRepository ?? FakeAuthRepository()),
    discovery: discovery ?? fakeDiscoveryBloc(),
    switchLocale: switchLocale,
    apiClient: apiClient,
  );
}

({AuthBloc auth, SessionBloc session, StreamSubscription<AuthState> coordinator})
    sessionPair(
  AuthRepository repository,
  TokenStorage storage,
) {
  final auth = AuthBloc(repository, storage);
  final session = SessionBloc(repository, storage);
  final coordinator = auth.stream.listen(
    (authState) => coordinateAuthSuccess(authState, session),
  );
  return (auth: auth, session: session, coordinator: coordinator);
}

void _noSwitchLocale() {}

ApiClient fakeApiClient() {
  return ApiClient(
    baseUrl: 'https://api.example.com',
    tokenProvider: () async => null,
    enableLogging: false,
  );
}

class InMemoryTokenStorage implements TokenStorage {
  String? token;
  int clearCount = 0;

  InMemoryTokenStorage([this.token]);

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async {
    token = null;
    clearCount++;
  }
}

class InMemoryAppPreferences implements AppPreferences {
  @override
  bool dontShowOnboarding;

  InMemoryAppPreferences({this.dontShowOnboarding = false});

  @override
  Future<void> setDontShowOnboarding(bool value) async {
    dontShowOnboarding = value;
  }
}

class FakeAuthRepository implements AuthRepository {
  static const ClientDto _client = ClientDto(
    id: 'uuid-1',
    name: 'Sara',
    email: 'sara@example.com',
    phone: null,
  );

  Object? refreshTokenError;
  Object? loginError;
  Object? registerError;
  Object? verifyEmailError;
  Object? forgotPasswordError;
  Object? resetPasswordError;

  String? forgotPasswordEmail;
  int forgotPasswordCalls = 0;
  Map<String, String>? resetPasswordPayload;

  /// Counts session re-probes. One `RestoreRequested` with a stored token calls
  /// `refreshToken` exactly once, so this is how a test observes a restore
  /// without depending on frame timing.
  int refreshTokenCalls = 0;

  /// When set, `refreshToken` blocks on it. Lets a test hold the session in
  /// `AuthStatus.unknown` / `isLoading`. Null by default, so every other test
  /// keeps resolving in a microtask.
  Completer<void>? refreshTokenGate;

  int sendVerificationCalls = 0;
  String? verifiedCode;

  @override
  Future<String> refreshToken() async {
    refreshTokenCalls++;
    final gate = refreshTokenGate;
    if (gate != null) await gate.future;
    final error = refreshTokenError;
    if (error != null) throw error;
    return 'rotated-token';
  }

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final error = loginError;
    if (error != null) throw error;
    return const AuthResponseDto(token: 'login-token', client: _client);
  }

  @override
  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final error = registerError;
    if (error != null) throw error;
    return const AuthResponseDto(token: 'register-token', client: _client);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendEmailVerification() async {
    sendVerificationCalls++;
  }

  @override
  Future<void> verifyEmail(String code) async {
    verifiedCode = code;
    final error = verifyEmailError;
    if (error != null) throw error;
  }

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordEmail = email;
    forgotPasswordCalls++;
    final error = forgotPasswordError;
    if (error != null) throw error;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    resetPasswordPayload = {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    final error = resetPasswordError;
    if (error != null) throw error;
  }

  Object? changePasswordError;
  Map<String, String>? changePasswordPayload;
  int changePasswordCalls = 0;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    changePasswordCalls++;
    changePasswordPayload = {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    final error = changePasswordError;
    if (error != null) throw error;
  }
}

class FakeOnboardingConfigRepository implements OnboardingConfigRepository {
  @override
  Future<OnboardingConfigDto> fetchOnboardingConfig({String? locale}) async {
    return const OnboardingConfigDto(
      heroImageUrl: '',
      season: null,
      locale: 'en',
    );
  }
}

OnboardingConfigBloc fakeOnboardingConfig() {
  return OnboardingConfigBloc(FakeOnboardingConfigRepository());
}

Position testPosition({
  double latitude = 24.7136,
  double longitude = 46.6753,
}) =>
    Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.utc(2026, 1, 1),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

BranchDto testBranch({int id = 1}) => BranchDto(
      id: id,
      name: 'Branch $id',
      email: 'branch$id@example.com',
      status: 'approved',
      latitude: 24.7136,
      longitude: 46.6753,
      brandId: 7,
      distance: 3.5,
      compatibilityScore: 0.92,
      rank: id,
    );

PaginatedData<BranchDto> testBranchPage({
  List<BranchDto>? branches,
  int currentPage = 1,
  int totalPages = 1,
}) {
  final items = branches ?? [testBranch()];
  return PaginatedData(
    data: items,
    meta: PaginationMeta(
      total: items.length,
      count: items.length,
      perPage: 20,
      currentPage: currentPage,
      totalPages: totalPages,
    ),
  );
}

class FakeExploreRepository implements ExploreRepository {
  PaginatedData<BranchDto> firstPage = testBranchPage();
  PaginatedData<BranchDto>? morePage;
  List<Object?> rawItems = const [];
  Map<String, dynamic> rawMeta = const {};
  Object? error;

  int getBranchesCalls = 0;
  int getBranchesPayloadCalls = 0;
  int lastPage = 1;
  String? lastUniverse;
  bool? lastAvailableNow;

  @override
  Future<PaginatedData<BranchDto>> getBranches({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int page = 1,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  }) async {
    getBranchesCalls++;
    lastPage = page;
    lastUniverse = universe;
    lastAvailableNow = availableNow;
    final failure = error;
    if (failure != null) throw failure;
    if (page > 1 && morePage != null) return morePage!;
    return firstPage;
  }

  @override
  Future<RawPaginated<BranchDto>> getBranchesPayload({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int page = 1,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  }) async {
    getBranchesPayloadCalls++;
    lastUniverse = universe;
    lastAvailableNow = availableNow;
    final failure = error;
    if (failure != null) throw failure;
    return (data: firstPage, rawItems: rawItems, rawMeta: rawMeta);
  }
}

class FakeLocationProvider implements LocationProvider {
  LocationPermissionStatus status = LocationPermissionStatus.granted;
  Position? position = testPosition();

  int ensurePermissionCalls = 0;

  @override
  Future<LocationPermissionStatus> ensurePermission() async {
    ensurePermissionCalls++;
    return status;
  }

  @override
  Future<Position?> getCurrentPosition() async => position;

  @override
  Stream<LocationPermissionStatus> permissionChanges() =>
      Stream.value(status);
}

class FakeFeedCache implements FeedCache {
  final Map<String, FeedCacheEntry> entries = {};
  final List<String> evictedKeys = [];
  int writeCalls = 0;

  @override
  String keyFor({
    required String universe,
    required double latitude,
    required double longitude,
    required double radius,
    int perPage = 20,
  }) =>
      'fake:$universe:$latitude:$longitude:$radius:$perPage';

  @override
  Future<FeedCacheEntry?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, FeedCacheEntry entry) async {
    entries[key] = entry;
    writeCalls++;
  }

  @override
  Future<void> evict(String key) async {
    entries.remove(key);
    evictedKeys.add(key);
  }

  @override
  Future<void> clear() async => entries.clear();
}

BookingDto testBooking({String id = 'booking-1', String status = 'confirmed'}) =>
    BookingDto(
      id: id,
      timeSlot: DateTime.utc(2026, 9, 10, 14, 30),
      status: status,
      chair: const BookingChairDto(id: 'chair-1', label: 'Chair A'),
      barber: const BookingBarberDto(id: 'barber-1', name: 'Karim'),
      services: const [
        BookingServiceDto(id: 'service-1', name: 'Fade', price: 80),
      ],
      createdAt: DateTime.utc(2026, 9, 2, 10),
    );

PaginatedData<BookingDto> testBookingPage({
  List<BookingDto>? bookings,
  int currentPage = 1,
  int totalPages = 1,
}) {
  final items = bookings ?? [testBooking()];
  return PaginatedData(
    data: items,
    meta: PaginationMeta(
      total: items.length,
      count: items.length,
      perPage: 20,
      currentPage: currentPage,
      totalPages: totalPages,
    ),
  );
}

class FakeBookingRepository implements BookingRepository {
  PaginatedData<BookingDto> firstPage = testBookingPage();
  PaginatedData<BookingDto>? morePage;
  Object? error;
  Object? cancelError;

  int getBookingsCalls = 0;
  int cancelCalls = 0;
  String? lastStatus;
  int lastPage = 1;
  String? lastCancelledId;

  @override
  Future<PaginatedData<BookingDto>> getBookings({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    getBookingsCalls++;
    lastStatus = status;
    lastPage = page;
    final failure = error;
    if (failure != null) throw failure;
    if (page > 1 && morePage != null) return morePage!;
    return firstPage;
  }

  @override
  Future<void> cancelBooking(String id) async {
    cancelCalls++;
    lastCancelledId = id;
    final failure = cancelError;
    if (failure != null) throw failure;
  }
}

BookingBloc fakeBookingBloc({FakeBookingRepository? repository}) {
  return BookingBloc(repository ?? FakeBookingRepository());
}

DiscoveryBloc fakeDiscoveryBloc({
  FakeExploreRepository? repository,
  FakeLocationProvider? location,
  FakeFeedCache? cache,
  DateTime Function()? clock,
}) {
  return DiscoveryBloc(
    repository ?? FakeExploreRepository(),
    location ?? FakeLocationProvider(),
    cache: cache ?? FakeFeedCache(),
    clock: clock,
  );
}

ApiException unauthorized() => const ApiException(
      statusCode: 401,
      code: 'UNKNOWN',
      message: 'Unauthenticated.',
    );

NetworkException offline() => const NetworkException(
      type: DioExceptionType.connectionError,
      retryable: true,
      message: 'Connection refused',
    );
