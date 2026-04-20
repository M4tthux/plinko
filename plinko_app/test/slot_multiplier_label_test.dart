import 'package:flutter_test/flutter_test.dart';
import 'package:plinko_app/config/plinko_config.dart';

void main() {
  group('formatMultiplier — valeurs < 1 perdent le 0 initial', () {
    test('0.1 → x.1',   () => expect(PlinkoConfig.formatMultiplier(0.1),  'x.1'));
    test('0.5 → x.5',   () => expect(PlinkoConfig.formatMultiplier(0.5),  'x.5'));
    test('0.25 → x.25', () => expect(PlinkoConfig.formatMultiplier(0.25), 'x.25'));
    test('0.05 → x.05', () => expect(PlinkoConfig.formatMultiplier(0.05), 'x.05'));
  });

  group('formatMultiplier — valeurs ≥ 1 inchangées', () {
    test('2 → x2',     () => expect(PlinkoConfig.formatMultiplier(2),    'x2'));
    test('10 → x10',   () => expect(PlinkoConfig.formatMultiplier(10),   'x10'));
    test('100 → x100', () => expect(PlinkoConfig.formatMultiplier(100),  'x100'));
    test('2.5 → x2.5', () => expect(PlinkoConfig.formatMultiplier(2.5),  'x2.5'));
  });
}
