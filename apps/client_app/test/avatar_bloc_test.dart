import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/profile/avatar.bloc.dart';
import 'package:client_app/src/features/profile/avatar.event.dart';
import 'package:client_app/src/features/profile/avatar.state.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeProfileRepository repository;

  setUp(() => repository = FakeProfileRepository());

  AvatarBloc bloc() => AvatarBloc(repository);

  blocTest<AvatarBloc, AvatarState>(
    'an avatar upload publishes the returned url',
    build: bloc,
    act: (bloc) => bloc.add(const AvatarPhotoChanged('/tmp/avatar.jpg')),
    verify: (bloc) {
      expect(repository.avatarUploadCalls, 1);
      expect(repository.lastAvatarPath, '/tmp/avatar.jpg');
      expect(bloc.state.isUploading, isFalse);
      expect(bloc.state.avatarUrl, 'https://cdn.example.com/avatar.jpg');
      expect(bloc.state.error, isNull);
    },
  );

  blocTest<AvatarBloc, AvatarState>(
    'an upload failure keeps the previous avatar and records the error',
    build: bloc,
    seed: () => const AvatarState(avatarUrl: 'https://cdn.example.com/old.jpg'),
    setUp: () => repository.uploadError = offline(),
    act: (bloc) => bloc.add(const AvatarPhotoChanged('/tmp/avatar.jpg')),
    verify: (bloc) {
      expect(bloc.state.isUploading, isFalse);
      expect(bloc.state.avatarUrl, 'https://cdn.example.com/old.jpg');
      expect(bloc.state.error, isA<NetworkException>());
    },
  );
}