import 'dart:async';
import 'package:flutter/foundation.dart';

/// A reusable trailing-edge debounce utility.
///
/// Cancels any pending timer and schedules a new one. The callback fires
/// only after [duration] has elapsed without another [run] call.
class DebounceUtil {
  DebounceUtil(this.duration);

  final Duration duration;
  Timer? _timer;

  /// Schedules [callback] to run after [duration] with no further calls.
  /// Cancels any pending timer from a previous [run] call.
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  /// Cancels any pending timer without firing the callback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Releases resources. Call when the debounce utility is no longer needed.
  void dispose() {
    cancel();
  }
}
