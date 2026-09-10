import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/profile/face_analysis.bloc.dart';
import 'package:client_app/src/features/profile/face_analysis.event.dart';
import 'package:client_app/src/features/profile/face_analysis.state.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeFaceProfileRepository face;
  late FakeServiceCatalogRepository catalog;

  setUp(() {
    face = FakeFaceProfileRepository();
    catalog = FakeServiceCatalogRepository();
  });

  FaceAnalysisBloc bloc() {
    return FaceAnalysisBloc(face, catalog);
  }

  group('FaceAnalysisStarted', () {
    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'empty recommendations settle into the ready empty state',
      build: bloc,
      act: (bloc) => bloc.add(const FaceAnalysisStarted()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.ready);
        expect(bloc.state.latest, isNull);
        expect(bloc.state.curated, isEmpty);
        expect(bloc.state.awaitingAnalysis, isFalse);
      },
    );

    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'resolves curated catalog items for the latest recommendation',
      build: bloc,
      seed: () => FaceAnalysisState(status: FaceAnalysisStatus.initial),
      setUp: () {
        face.recommendations = [
          testFaceAnalysis(
            recommendedIds: ['catalog-1', 'catalog-2'],
          ),
        ];
        catalog.page = testCatalogPage(items: [
          testCatalogItem(id: 'catalog-1', name: 'Classic Fade'),
          testCatalogItem(id: 'catalog-2', name: 'Taper Cut'),
        ]);
      },
      act: (bloc) => bloc.add(const FaceAnalysisStarted()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.ready);
        expect(bloc.state.latest?.id, 'analysis-1');
        expect(
          bloc.state.curated.map((item) => item.id),
          ['catalog-1', 'catalog-2'],
        );
        expect(face.recommendationsCalls, 1);
      },
    );

    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'a failed recommendations fetch fails the card',
      build: bloc,
      setUp: () => face.recommendationsError = offline(),
      act: (bloc) => bloc.add(const FaceAnalysisStarted()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.failed);
        expect(bloc.state.error, isA<NetworkException>());
      },
    );

    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'a catalog failure is tolerated and the analysis still renders',
      build: bloc,
      setUp: () {
        face.recommendations = [testFaceAnalysis()];
        catalog.page = testCatalogPage(items: const []);
        catalog.error = offline();
      },
      act: (bloc) => bloc.add(const FaceAnalysisStarted()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.ready);
        expect(bloc.state.latest, isNotNull);
        expect(bloc.state.curated, isEmpty);
      },
    );
  });

  group('FaceAnalysisPhotoScanned', () {
    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'an upload followed by no result leaves the card awaiting analysis',
      build: bloc,
      act: (bloc) => bloc.add(const FaceAnalysisPhotoScanned('/tmp/face.jpg')),
      verify: (bloc) {
        expect(face.uploadCalls, 1);
        expect(face.lastUploadedPath, '/tmp/face.jpg');
        expect(face.lastIsPrimary, isFalse);
        expect(bloc.state.status, FaceAnalysisStatus.ready);
        expect(bloc.state.uploadedPhotoUrl, isNotNull);
        expect(bloc.state.latest, isNull);
        expect(bloc.state.awaitingAnalysis, isTrue);
      },
    );

    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'an upload failure fails the card and keeps the pending flag',
      build: bloc,
      setUp: () => face.uploadError = offline(),
      act: (bloc) => bloc.add(const FaceAnalysisPhotoScanned('/tmp/face.jpg')),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.failed);
        expect(bloc.state.error, isA<NetworkException>());
        expect(bloc.state.awaitingAnalysis, isTrue);
      },
    );
  });

  group('FaceAnalysisCheckedAgain', () {
    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'checking again after the job completes loads the result',
      build: bloc,
      seed: () => const FaceAnalysisState(
        status: FaceAnalysisStatus.ready,
        awaitingAnalysis: true,
        uploadedPhotoUrl: 'https://cdn.example.com/face.jpg',
      ),
      setUp: () {
        face.recommendations = [testFaceAnalysis()];
      },
      act: (bloc) => bloc.add(const FaceAnalysisCheckedAgain()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.ready);
        expect(bloc.state.latest?.detectedFaceShape, 'oval');
        expect(bloc.state.awaitingAnalysis, isFalse);
        expect(
          bloc.state.curated.map((item) => item.id),
          ['catalog-1'],
        );
      },
    );

    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'checking again while still empty stays pending',
      build: bloc,
      seed: () => const FaceAnalysisState(
        status: FaceAnalysisStatus.ready,
        awaitingAnalysis: true,
      ),
      act: (bloc) => bloc.add(const FaceAnalysisCheckedAgain()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.ready);
        expect(bloc.state.latest, isNull);
        expect(bloc.state.awaitingAnalysis, isTrue);
      },
    );

    blocTest<FaceAnalysisBloc, FaceAnalysisState>(
      'retrying after a failed load reloads the recommendations',
      build: bloc,
      seed: () => const FaceAnalysisState(
        status: FaceAnalysisStatus.ready,
      ),
      setUp: () => face.recommendationsError = offline(),
      act: (bloc) => bloc.add(const FaceAnalysisCheckedAgain()),
      verify: (bloc) {
        expect(bloc.state.status, FaceAnalysisStatus.failed);
      },
    );
  });
}