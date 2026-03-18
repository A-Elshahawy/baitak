import 'dart:async';

class AuthEvents {
  AuthEvents._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get onUnauthorized => _controller.stream;

  static void fireUnauthorized() {
    _controller.add(null);
  }
}
