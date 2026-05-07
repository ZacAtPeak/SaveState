import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';
import 'package:core/utils/utils.dart';

void main() {
  group('DebounceUtil', () {
    test('callback does not fire before duration elapses', () {
      fakeAsync((async) {
        var called = false;
        final debounce = DebounceUtil(const Duration(milliseconds: 250));

        debounce.run(() => called = true);

        expect(called, isFalse);

        async.elapse(const Duration(milliseconds: 249));
        expect(called, isFalse);
      });
    });

    test('callback fires after 250ms debounce', () {
      fakeAsync((async) {
        var called = false;
        final debounce = DebounceUtil(const Duration(milliseconds: 250));

        debounce.run(() => called = true);

        async.elapse(const Duration(milliseconds: 250));
        expect(called, isTrue);
      });
    });

    test('rapid calls reset the timer (trailing-edge only)', () {
      fakeAsync((async) {
        var callCount = 0;
        final debounce = DebounceUtil(const Duration(milliseconds: 250));

        debounce.run(() => callCount++);
        async.elapse(const Duration(milliseconds: 100));
        debounce.run(() => callCount++);
        async.elapse(const Duration(milliseconds: 100));
        debounce.run(() => callCount++);

        expect(callCount, equals(0));

        async.elapse(const Duration(milliseconds: 250));
        expect(callCount, equals(1));
      });
    });

    test('cancel prevents callback from firing', () {
      fakeAsync((async) {
        var called = false;
        final debounce = DebounceUtil(const Duration(milliseconds: 250));

        debounce.run(() => called = true);
        debounce.cancel();

        async.elapse(const Duration(milliseconds: 250));
        expect(called, isFalse);
      });
    });

    test('dispose cancels pending timer', () {
      fakeAsync((async) {
        var called = false;
        final debounce = DebounceUtil(const Duration(milliseconds: 250));

        debounce.run(() => called = true);
        debounce.dispose();

        async.elapse(const Duration(milliseconds: 250));
        expect(called, isFalse);
      });
    });

    test('multiple dispose calls are safe', () {
      final debounce = DebounceUtil(const Duration(milliseconds: 250));
      debounce.dispose();
      debounce.dispose();
      // No exception thrown
    });
  });
}
