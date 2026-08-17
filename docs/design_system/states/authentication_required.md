# Authentication Required

**Mechanism exists and is tested; no producer yet.**

`SessionBloc` handles the `RequireAuthentication` event (add → auth entry
pushed on top of the current screen). It is exercised only by tests
(`apps/client_app/test/session_expired_test.dart`); nothing in production
dispatches the event, because no post-auth feature exists yet.

The first producer will be Discovery 016 (guest attempts an authenticated
action). No widget is needed beyond the existing auth entry screen — this
state is navigation, not presentation. If 016 needs an inline
"sign in to continue" prompt, use `StatusView` with feature copy.