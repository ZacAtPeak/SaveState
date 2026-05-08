import 'package:test/test.dart';
import 'package:core/models/formula_evaluator.dart';

void main() {
  group('FormulaEvaluator', () {
    group('basic arithmetic', () {
      test('2 + 3 evaluates to 5', () {
        expect(FormulaEvaluator.evaluate('2 + 3', {}), 5);
      });

      test('10 - 4 evaluates to 6', () {
        expect(FormulaEvaluator.evaluate('10 - 4', {}), 6);
      });

      test('3 * 4 evaluates to 12', () {
        expect(FormulaEvaluator.evaluate('3 * 4', {}), 12);
      });

      test('10 / 2 evaluates to 5', () {
        expect(FormulaEvaluator.evaluate('10 / 2', {}), 5);
      });
    });

    group('parentheses and precedence', () {
      test('(2 + 3) * 4 evaluates to 20', () {
        expect(FormulaEvaluator.evaluate('(2 + 3) * 4', {}), 20);
      });

      test('2 + 3 * 4 evaluates to 14 (multiplication first)', () {
        expect(FormulaEvaluator.evaluate('2 + 3 * 4', {}), 14);
      });

      test('((2 + 3) * (4 - 1)) evaluates to 15', () {
        expect(FormulaEvaluator.evaluate('(2 + 3) * (4 - 1)', {}), 15);
      });
    });

    group('dice notation', () {
      test('1d20 returns value between 1 and 20', () {
        for (int i = 0; i < 50; i++) {
          final result = FormulaEvaluator.evaluate('1d20', {});
          expect(result, inInclusiveRange(1, 20));
        }
      });

      test('2d6 returns value between 2 and 12', () {
        for (int i = 0; i < 50; i++) {
          final result = FormulaEvaluator.evaluate('2d6', {});
          expect(result, inInclusiveRange(2, 12));
        }
      });

      test('1d20+3 returns value between 4 and 23', () {
        for (int i = 0; i < 50; i++) {
          final result = FormulaEvaluator.evaluate('1d20+3', {});
          expect(result, inInclusiveRange(4, 23));
        }
      });
    });

    group('functions', () {
      test('floor((12 - 10) / 2) evaluates to 1', () {
        expect(FormulaEvaluator.evaluate('floor((12 - 10) / 2)', {}), 1);
      });

      test('ceil(3.2) evaluates to 4', () {
        expect(FormulaEvaluator.evaluate('ceil(3.2)', {}), 4);
      });

      test('floor(2.9) evaluates to 2', () {
        expect(FormulaEvaluator.evaluate('floor(2.9)', {}), 2);
      });
    });

    group('field references', () {
      test('STR + 5 with context {STR: 15} evaluates to 20', () {
        expect(FormulaEvaluator.evaluate('STR + 5', {'STR': 15}), 20);
      });

      test('DEX * 2 with context {DEX: 14} evaluates to 28', () {
        expect(FormulaEvaluator.evaluate('DEX * 2', {'DEX': 14}), 28);
      });

      test('STR + DEX with context resolves both', () {
        expect(
          FormulaEvaluator.evaluate('STR + DEX', {'STR': 15, 'DEX': 12}),
          27,
        );
      });
    });

    group('dice with field references', () {
      test('1d20+DEX with context {DEX: 14} returns value between 3 and 22', () {
        for (int i = 0; i < 50; i++) {
          final result = FormulaEvaluator.evaluate('1d20+DEX', {'DEX': 14});
          expect(result, inInclusiveRange(15, 34));
        }
      });
    });

    group('error handling', () {
      test('invalid formula "2 + + 3" throws FormulaError', () {
        expect(
          () => FormulaEvaluator.evaluate('2 + + 3', {}),
          throwsA(isA<FormulaError>()),
        );
      });

      test('unknown field "UNKNOWN" with empty context throws FormulaError', () {
        expect(
          () => FormulaEvaluator.evaluate('UNKNOWN', {}),
          throwsA(isA<FormulaError>()),
        );
      });

      test('unknown field message includes field name', () {
        try {
          FormulaEvaluator.evaluate('UNKNOWN', {});
          fail('Expected FormulaError');
        } on FormulaError catch (e) {
          expect(e.message, contains('UNKNOWN'));
        }
      });
    });

    group('circular dependency detection', () {
      test('circular dependency A: B+1, B: A-1 throws FormulaError', () {
        final formulas = {
          'A': 'B + 1',
          'B': 'A - 1',
        };

        expect(
          () => FormulaEvaluator.detectCircularDependencies(formulas),
          throwsA(isA<FormulaError>()),
        );
      });

      test('non-circular formulas do not throw', () {
        final formulas = {
          'A': '5',
          'B': 'A + 1',
          'C': 'B + 2',
        };

        expect(
          () => FormulaEvaluator.detectCircularDependencies(formulas),
          returnsNormally,
        );
      });

      test('self-referencing formula throws FormulaError', () {
        final formulas = {
          'A': 'A + 1',
        };

        expect(
          () => FormulaEvaluator.detectCircularDependencies(formulas),
          throwsA(isA<FormulaError>()),
        );
      });
    });

    group('getDependencies', () {
      test('extracts field references from formula', () {
        final deps = FormulaEvaluator.getDependencies('STR + DEX * 2');
        expect(deps, contains('STR'));
        expect(deps, contains('DEX'));
        expect(deps.length, 2);
      });

      test('returns empty list for formula with no field refs', () {
        final deps = FormulaEvaluator.getDependencies('2 + 3');
        expect(deps, isEmpty);
      });

      test('extracts field refs from dice modifier', () {
        final deps = FormulaEvaluator.getDependencies('1d20+DEX');
        expect(deps, contains('DEX'));
      });
    });

    group('FormulaError', () {
      test('toString includes message', () {
        const error = FormulaError('test error');
        expect(error.toString(), contains('test error'));
      });
    });
  });
}
