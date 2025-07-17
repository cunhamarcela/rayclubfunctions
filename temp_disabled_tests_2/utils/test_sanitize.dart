// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/utils/input_validator.dart';

void main() {
  test('Test sanitizeText with specific inputs', () {
    final input = 'joao@exemplo.com onclick="alert(1)"';
    final result = InputValidator.sanitizeText(input);
    print('Input: $input');
    print('Result: $result');
    print('Length: ${result.length}');
    print('Chars: ${result.split('').map((c) => '${c.codeUnitAt(0)}:$c').join(', ')}');
  });
} 