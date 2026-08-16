enum AuthStatus {
  unknown,
  authenticated,
  guest;

  bool get isAuthenticated => this == AuthStatus.authenticated;

  bool get isResolved => this != AuthStatus.unknown;
}
