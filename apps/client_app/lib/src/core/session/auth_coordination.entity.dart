import 'package:core/core.dart';

void coordinateAuthSuccess(AuthState authState, SessionBloc session) {
  switch (authState.signal) {
    case AuthSignal.loginSucceeded:
    case AuthSignal.registrationSucceeded:
      final client = authState.client;
      if (client != null) {
        session.add(SessionAuthenticated(client));
      }
    case AuthSignal.verificationSucceeded:
    case AuthSignal.none:
      break;
  }
}
