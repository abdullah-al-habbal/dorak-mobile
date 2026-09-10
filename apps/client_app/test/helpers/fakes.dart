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
import 'package:client_app/src/features/booking/branch_detail.bloc.dart';
import 'package:client_app/src/features/discovery/discovery.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';
import 'package:client_app/src/features/profile/avatar.bloc.dart';
import 'package:client_app/src/features/profile/face_analysis.bloc.dart';
import 'package:client_app/src/features/profile/history.bloc.dart';
import 'package:client_app/src/features/profile/photo_picker.provider.dart';

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
  BranchDetailBloc? branchDetail,
  ChangePasswordBloc? passwordChange,
  DiscoveryBloc? discovery,
  HistoryBloc? history,
  FaceAnalysisBloc? faceAnalysis,
  AvatarBloc? avatar,
  PhotoPicker? photoPicker,
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
    branchDetail: branchDetail ?? fakeBranchDetailBloc(),
    passwordChange: passwordChange ??
        ChangePasswordBloc(recoveryRepository ?? FakeAuthRepository()),
    discovery: discovery ?? fakeDiscoveryBloc(),
    history: history ?? fakeHistoryBloc(),
    faceAnalysis: faceAnalysis ?? fakeFaceAnalysisBloc(),
    avatar: avatar ?? fakeAvatarBloc(),
    photoPicker: photoPicker ?? FakePhotoPicker(),
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

  BranchDetailDto detail = testBranchDetail();

  @override
  Future<BranchDetailDto> getBranchDetail(String branchId) async {
    final failure = error;
    if (failure != null) throw failure;
    return detail;
  }
}

BranchDetailDto testBranchDetail() => const BranchDetailDto(
      id: 1,
      name: 'Branch 1',
      email: 'branch1@example.com',
      status: 'approved',
      latitude: 24.7136,
      longitude: 46.6753,
      brandId: 7,
      chairsCount: 2,
      barbers: [
        BookingBarberDto(id: 'barber-1', name: 'Karim'),
      ],
      services: [
        BookingServiceDto(id: 'service-1', name: 'Fade', price: 80),
      ],
    );

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
  Future<BookingDto> createBooking({
    String? chairId,
    String? barberId,
    required DateTime timeSlot,
    List<String>? serviceIds,
    double? atHomeLatitude,
    double? atHomeLongitude,
  }) async {
    createCalls++;
    final failure = createError;
    if (failure != null) throw failure;
    return createdBooking ?? testBooking();
  }

  BookingDto? createdBooking;
  Object? createError;
  int createCalls = 0;

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

ServiceHistoryDto testServiceHistory({
  String id = 'history-1',
  String? itemName,
}) =>
    ServiceHistoryDto(
      id: id,
      bookingId: 'booking-1',
      catalogItemId: 'catalog-1',
      performedAt: DateTime.utc(2026, 8, 30, 11),
      clientRating: 5,
      clientNotes: 'Great fade',
      barber: const HistoryBarberDto(id: 'barber-1', name: 'Karim'),
      branch: const HistoryBranchDto(id: 'branch-1', name: 'Riyadh Downtown'),
      catalogItem: HistoryCatalogItemDto(
        id: 'catalog-1',
        name: {'en': itemName ?? 'Classic Fade'},
      ),
      createdAt: DateTime.utc(2026, 8, 30, 12),
    );

PaginatedData<ServiceHistoryDto> testHistoryPage({
  List<ServiceHistoryDto>? items,
  int currentPage = 1,
  int totalPages = 1,
}) {
  final data = items ?? [testServiceHistory()];
  return PaginatedData(
    data: data,
    meta: PaginationMeta(
      total: data.length,
      count: data.length,
      perPage: 15,
      currentPage: currentPage,
      totalPages: totalPages,
    ),
  );
}

class FakeHistoryRepository implements HistoryRepository {
  PaginatedData<ServiceHistoryDto> firstPage = testHistoryPage();
  PaginatedData<ServiceHistoryDto>? morePage;
  Object? error;
  Object? rebookError;

  int getHistoryCalls = 0;
  int lastPage = 1;
  int rebookCalls = 0;
  String? lastRebookedId;
  DateTime? lastRebookSlot;

  @override
  Future<PaginatedData<ServiceHistoryDto>> getHistory({
    int page = 1,
    int perPage = 15,
  }) async {
    getHistoryCalls++;
    lastPage = page;
    final failure = error;
    if (failure != null) throw failure;
    if (page > 1 && morePage != null) return morePage!;
    return firstPage;
  }

  @override
  Future<BookingDto> rebookFromHistory(String historyId, DateTime timeSlot) async {
    rebookCalls++;
    lastRebookedId = historyId;
    lastRebookSlot = timeSlot;
    final failure = rebookError;
    if (failure != null) throw failure;
    return testBooking(id: 'booking-2');
  }
}

HistoryBloc fakeHistoryBloc({FakeHistoryRepository? repository}) {
  return HistoryBloc(repository ?? FakeHistoryRepository());
}

FloorPlanDto testFloorPlan() => const FloorPlanDto(
      branchId: '1',
      branchName: 'Branch 1',
      chairs: [
        FloorChairDto(id: 'chair-1', label: 'A', status: 'available'),
        FloorChairDto(id: 'chair-2', label: 'B', status: 'occupied'),
      ],
    );

class FakeBranchRepository implements BranchRepository {
  FloorPlanDto plan = testFloorPlan();
  Object? error;
  int getFloorPlanCalls = 0;

  @override
  Future<FloorPlanDto> getFloorPlan(String branchId) async {
    getFloorPlanCalls++;
    final failure = error;
    if (failure != null) throw failure;
    return plan;
  }
}

BranchDetailBloc fakeBranchDetailBloc({
  FakeExploreRepository? explore,
  FakeBranchRepository? branches,
  FakeBookingRepository? bookings,
}) {
  return BranchDetailBloc(
    explore ?? FakeExploreRepository(),
    branches ?? FakeBranchRepository(),
    bookings ?? FakeBookingRepository(),
  );
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

FacePhotoDto testFacePhoto({String id = 'photo-1'}) => FacePhotoDto(
      id: id,
      imageUrl: 'https://cdn.example.com/face-$id.jpg',
      isPrimary: false,
      uploadedAt: DateTime.utc(2026, 9, 10, 12),
    );

FaceAnalysisResultDto testFaceAnalysis({
  String id = 'analysis-1',
  String shape = 'oval',
  double confidence = 0.9,
  List<String>? recommendedIds = const ['catalog-1'],
  String? photoUrl = 'https://cdn.example.com/face-photo-1.jpg',
}) =>
    FaceAnalysisResultDto(
      id: id,
      faceProfileId: 'photo-1',
      detectedFaceShape: shape,
      confidenceScore: confidence,
      recommendedCatalogItemIds: recommendedIds,
      computedAt: DateTime.utc(2026, 9, 10, 11),
      faceProfile: photoUrl == null
          ? null
          : FacePhotoDto(
              id: 'photo-1',
              imageUrl: photoUrl,
              isPrimary: false,
              uploadedAt: DateTime.utc(2026, 9, 10, 12),
            ),
      createdAt: DateTime.utc(2026, 9, 10, 13),
    );

CatalogItemDto testCatalogItem({
  String id = 'catalog-1',
  String name = 'Classic Fade',
  num min = 50,
  num max = 90,
  String currency = 'SAR',
  String? stylePeriod = 'Modern',
}) =>
    CatalogItemDto(
      id: id,
      name: {'en': name},
      priceRange:
          CatalogPriceRangeDto(min: min, max: max, currency: currency),
      faceShapes: const ['oval'],
      stylePeriod: stylePeriod,
    );

PaginatedData<CatalogItemDto> testCatalogPage({
  List<CatalogItemDto>? items,
}) {
  final data = items ?? [testCatalogItem()];
  return PaginatedData(
    data: data,
    meta: PaginationMeta(
      total: data.length,
      count: data.length,
      perPage: 100,
      currentPage: 1,
      totalPages: 1,
    ),
  );
}

class FakePhotoPicker implements PhotoPicker {
  String? path;
  int pickCalls = 0;

  @override
  Future<String?> pickPhoto() async {
    pickCalls++;
    return path;
  }
}

class FakeFaceProfileRepository implements FaceProfileRepository {
  List<FaceAnalysisResultDto> recommendations = const [];
  Object? uploadError;
  Object? recommendationsError;

  int uploadCalls = 0;
  int recommendationsCalls = 0;
  String? lastUploadedPath;
  bool? lastIsPrimary;

  @override
  Future<FacePhotoDto> uploadFacePhoto(
    String filePath, {
    bool isPrimary = false,
  }) async {
    uploadCalls++;
    lastUploadedPath = filePath;
    lastIsPrimary = isPrimary;
    final failure = uploadError;
    if (failure != null) throw failure;
    return testFacePhoto();
  }

  @override
  Future<List<FaceAnalysisResultDto>> getRecommendations() async {
    recommendationsCalls++;
    final failure = recommendationsError;
    if (failure != null) throw failure;
    return recommendations;
  }
}

class FakeProfileRepository implements ProfileRepository {
  String avatarUrl = 'https://cdn.example.com/avatar.jpg';
  Object? uploadError;
  int avatarUploadCalls = 0;
  String? lastAvatarPath;

  @override
  Future<AvatarDto> uploadAvatar(String filePath) async {
    avatarUploadCalls++;
    lastAvatarPath = filePath;
    final failure = uploadError;
    if (failure != null) throw failure;
    return AvatarDto(avatarUrl: avatarUrl);
  }

  @override
  Future<ClientDto> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    return const ClientDto(
      id: 'uuid-1',
      name: 'Sara',
      email: 'sara@example.com',
    );
  }

  @override
  Future<UniversePreferenceDto> updatePreferredUniverse(
    String universe,
  ) async {
    return UniversePreferenceDto(preferredUniverse: universe);
  }
}

class FakeServiceCatalogRepository implements ServiceCatalogRepository {
  PaginatedData<CatalogItemDto> page = testCatalogPage();
  Object? error;

  int calls = 0;
  int lastPage = 1;

  @override
  Future<PaginatedData<CatalogItemDto>> getCatalogItems({
    int page = 1,
    int perPage = 100,
  }) async {
    calls++;
    lastPage = page;
    final failure = error;
    if (failure != null) throw failure;
    return this.page;
  }
}

FaceAnalysisBloc fakeFaceAnalysisBloc({
  FakeFaceProfileRepository? face,
  FakeServiceCatalogRepository? catalog,
}) {
  return FaceAnalysisBloc(
    face ?? FakeFaceProfileRepository(),
    catalog ?? FakeServiceCatalogRepository(),
  );
}

AvatarBloc fakeAvatarBloc({FakeProfileRepository? repository}) {
  return AvatarBloc(repository ?? FakeProfileRepository());
}
