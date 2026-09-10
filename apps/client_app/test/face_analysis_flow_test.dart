import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/profile/avatar.bloc.dart';
import 'package:client_app/src/features/profile/face_analysis.bloc.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeAuthRepository authRepository;
  late FakeFaceProfileRepository faceRepository;
  late FakeServiceCatalogRepository catalogRepository;
  late FakeProfileRepository profileRepository;
  late FakePhotoPicker picker;
  late InMemoryTokenStorage storage;

  setUp(() {
    authRepository = FakeAuthRepository();
    faceRepository = FakeFaceProfileRepository();
    catalogRepository = FakeServiceCatalogRepository();
    profileRepository = FakeProfileRepository();
    picker = FakePhotoPicker();
    storage = InMemoryTokenStorage('stored-token');
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final pair = sessionPair(authRepository, storage);
    addTearDown(pair.coordinator.cancel);
    final faceAnalysis = FaceAnalysisBloc(faceRepository, catalogRepository);
    final avatar = AvatarBloc(profileRepository);
    addTearDown(faceAnalysis.close);
    addTearDown(avatar.close);

    final router = buildRouter(
      session: pair.session,
      auth: pair.auth,
      faceAnalysis: faceAnalysis,
      avatar: avatar,
      photoPicker: picker,
      preferences: InMemoryAppPreferences(dontShowOnboarding: true),
      apiClient: fakeApiClient(),
    );
    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    router.router.go(AppRoutes.profile);
    await tester.pumpAndSettle();
  }

  testWidgets('empty analysis shows the empty card and the scan action',
      (tester) async {
    await pumpProfile(tester);

    expect(find.text('Face Analysis'), findsOneWidget);
    expect(find.text('No analysis yet'), findsOneWidget);
    expect(find.text('Scan my face'), findsOneWidget);
    expect(find.text('No matching styles yet.'), findsOneWidget);
  });

  testWidgets(
      'scan upload lands on the pending card and a refresh loads the result',
      (tester) async {
    picker.path = '/tmp/face.jpg';
    await pumpProfile(tester);

    await tester.tap(find.text('Scan my face'));
    await tester.pumpAndSettle();

    expect(faceRepository.uploadCalls, 1);
    expect(faceRepository.lastUploadedPath, '/tmp/face.jpg');
    expect(find.text('Analysis in progress'), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);

    faceRepository.recommendations = [testFaceAnalysis()];
    await tester.tap(find.text('Check again'));
    await tester.pumpAndSettle();

    expect(find.text('Detected Shape: Oval'), findsOneWidget);
    expect(find.text('Confidence: 90%'), findsOneWidget);
    expect(find.text('Classic Fade'), findsOneWidget);
    expect(find.textContaining('50–90 SAR'), findsOneWidget);
  });

  testWidgets('cancelling the picker dispatches nothing', (tester) async {
    picker.path = null;
    await pumpProfile(tester);

    await tester.tap(find.text('Scan my face'));
    await tester.pumpAndSettle();

    expect(picker.pickCalls, 1);
    expect(faceRepository.uploadCalls, 0);
    expect(find.text('No analysis yet'), findsOneWidget);
  });

  testWidgets('tapping the avatar uploads the picked photo', (tester) async {
    picker.path = '/tmp/avatar.jpg';
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    await tester.pumpAndSettle();

    expect(picker.pickCalls, 1);
    expect(profileRepository.avatarUploadCalls, 1);
    expect(profileRepository.lastAvatarPath, '/tmp/avatar.jpg');
  });
}