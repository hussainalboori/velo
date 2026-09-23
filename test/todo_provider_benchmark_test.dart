import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        anonKey: 'placeholder-anon-key',
      );
    } catch (_) {}
  });

  group('TodoProvider counts benchmark and correctness test', () {
    test('activeCount and completedCount initial values', () {
      final provider = TodoProvider();
      expect(provider.activeCount, equals(0));
      expect(provider.completedCount, equals(0));
    });

    test('Benchmark counts evaluation on active/completed access', () {
      final provider = TodoProvider();

      final stopwatch = Stopwatch()..start();

      int activeSum = 0;
      int completedSum = 0;
      for (int i = 0; i < 1000000; i++) {
        activeSum += provider.activeCount;
        completedSum += provider.completedCount;
      }
      stopwatch.stop();

      print(
          'Elapsed time for 1,000,000 count accesses: ${stopwatch.elapsedMicroseconds} us (${stopwatch.elapsedMilliseconds} ms)');
      expect(activeSum, equals(0));
      expect(completedSum, equals(0));
    });
  });
}
