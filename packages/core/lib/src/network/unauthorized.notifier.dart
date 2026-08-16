import 'package:flutter/widgets.dart';

class UnauthorizedNotifier extends ChangeNotifier {
  bool _fired = false;

  bool get fired => _fired;

  void fire() {
    if (_fired) return;
    _fired = true;
    notifyListeners();
  }

  void reset() {
    _fired = false;
  }
}
