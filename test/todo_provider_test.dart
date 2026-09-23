import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://fake-project.supabase.co',
      anonKey: 'fake-anon-key',
    );
  });

  group('TodoProvider waitForProStatus benchmark & unit tests', () {
    test('returns true immediately when already pro', () async {
      final provider = TodoProvider();
      provider.setProStatus(true);

      final stopwatch = Stopwatch()..start();
      final result = await provider.waitForProStatus();
      stopwatch.stop();

      expect(result, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('returns false fast when user is not authenticated', () async {
      final provider = TodoProvider();

      final stopwatch = Stopwatch()..start();
      final result = await provider.waitForProStatus();
      stopwatch.stop();

      expect(result, isFalse);
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}
