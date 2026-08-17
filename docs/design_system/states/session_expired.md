# Session Expired

**Already implemented — no Track 12 component.**

Flow (see `docs/core/interceptors.md`, `docs/core/session.md`,
`docs/navigation/guards.md`): a 401/403 on an authenticated request →
`ApiClient.unauthorizedStream` → `client_app` forwards `UnauthorizedDetected`
to `SessionBloc` → `SessionState.signal` = `sessionExpired` → the router
listener redirects to `/auth` and acknowledges via `SignalAcknowledged`.

Tested end-to-end by `apps/client_app/test/session_expired_test.dart`.

**Authentication required** (guest action → `RequireAuthentication` → auth
entry pushed on top) is the sibling state — see
[`authentication_required.md`](./authentication_required.md). Its mechanism is
complete and tested, but nothing in production dispatches
`RequireAuthentication` yet.