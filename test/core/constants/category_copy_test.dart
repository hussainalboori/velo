import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';

void main() {
  group('CategoryCopy', () {
    group('normalize', () {
      test('trims leading and trailing whitespace', () {
        expect(CategoryCopy.normalize('  work  '), equals('work'));
        expect(CategoryCopy.normalize('\tstudy\n'), equals('study'));
      });

      test('converts uppercase and mixed-case to lowercase', () {
        expect(CategoryCopy.normalize('WORK'), equals('work'));
        expect(CategoryCopy.normalize('Personal'), equals('personal'));
        expect(CategoryCopy.normalize('HeLLo WoRLd'), equals('hello world'));
      });

      test('collapses multiple consecutive spaces into a single space', () {
        expect(CategoryCopy.normalize('home   office'), equals('home office'));
        expect(CategoryCopy.normalize('  deep   work   now  '), equals('deep work now'));
        expect(CategoryCopy.normalize('a \t \n b'), equals('a b'));
      });

      test('returns empty string for empty input or whitespace-only input', () {
        expect(CategoryCopy.normalize(''), equals(''));
        expect(CategoryCopy.normalize('   '), equals(''));
        expect(CategoryCopy.normalize('\t\n  '), equals(''));
      });

      test('is idempotent on already normalized strings', () {
        const input = 'software engineering';
        final firstPass = CategoryCopy.normalize(input);
        final secondPass = CategoryCopy.normalize(firstPass);
        expect(secondPass, equals(firstPass));
      });
    });

    group('label', () {
      test('returns "General" for empty string or whitespace-only input', () {
        expect(CategoryCopy.label(''), equals('General'));
        expect(CategoryCopy.label('   '), equals('General'));
        expect(CategoryCopy.label('\t\n'), equals('General'));
      });

      test('capitalizes the first letter of a single-word category', () {
        expect(CategoryCopy.label('work'), equals('Work'));
        expect(CategoryCopy.label('PERSONAL'), equals('Personal'));
        expect(CategoryCopy.label('sTUdy'), equals('Study'));
      });

      test('capitalizes each word in multi-word category and normalizes spacing', () {
        expect(CategoryCopy.label('home office'), equals('Home Office'));
        expect(CategoryCopy.label('  DEEP   WORK  '), equals('Deep Work'));
        expect(CategoryCopy.label('side   projects\tnow'), equals('Side Projects Now'));
      });
    });
  });
}
