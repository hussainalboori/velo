import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';

void main() {
  group('smoke checks', () {
    test('default categories are present', () {
      expect(AppConstants.defaultCategories, isA<List<String>>());
      expect(AppConstants.defaultCategories, hasLength(3));
      expect(AppConstants.defaultCategories, containsAll(['personal', 'work', 'study']));
    });

    test('ad config falls back to known safe test IDs', () {
      expect(AppConstants.showAds, isFalse);
      expect(EnvConfig.adMobRewardedId, isNotEmpty);
      expect(EnvConfig.adMobBannerId, isNotEmpty);
    });

    test('task and category limits are constrained', () {
      expect(AppConstants.maxTodoLength, greaterThan(0));
      expect(AppConstants.maxCategoryLength, greaterThan(0));
      expect(AppConstants.maxSubTaskLength, greaterThan(0));
    });
  });
}
