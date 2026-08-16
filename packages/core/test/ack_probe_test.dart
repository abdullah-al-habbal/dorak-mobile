import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';

void main() {
  test('ack after async register is processed', () async {
    final repository = FakeAuthRepository();
    final storage = InMemoryTokenStorage();
    final bloc = AuthBloc(repository, storage);

    final states = <AuthState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const RegisterRequested(
      name: 'Sara',
      email: 'sara@example.com',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    ));
    bloc.add(AuthSignalAcknowledged());

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    await bloc.close();

    for (final s in states) {
      print('STATE client=${s.client?.email} submitting=${s.isSubmitting} '
          'signal=${s.signal}');
    }
    expect(states.length, 3);
  });
}
