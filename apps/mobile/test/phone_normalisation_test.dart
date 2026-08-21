import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/service/auth_service.dart';

void main() {
  group('AuthService.normalisePhone', () {
    // Without normalisation the same person typing their number three
    // different ways would create three separate accounts, each with its own
    // ledger — and the server treats phone as the unique identity.
    test('adds the dial code to a bare national number', () {
      expect(AuthService.normalisePhone('9876543210'), '+919876543210');
    });

    test('strips a leading national trunk zero', () {
      expect(AuthService.normalisePhone('09876543210'), '+919876543210');
    });

    test('leaves an existing E.164 number untouched', () {
      expect(AuthService.normalisePhone('+919876543210'), '+919876543210');
    });

    test('ignores spaces, dashes and brackets', () {
      expect(AuthService.normalisePhone(' 98765 43210 '), '+919876543210');
      expect(AuthService.normalisePhone('98765-43210'), '+919876543210');
      expect(AuthService.normalisePhone('(98765) 43210'), '+919876543210');
    });

    test('honours a non-default dial code', () {
      expect(
        AuthService.normalisePhone('7700900123', dialCode: '+44'),
        '+447700900123',
      );
    });

    test('all spellings of one number converge on one identity', () {
      final variants = ['9876543210', '09876543210', '+919876543210', '98765 43210'];
      expect(variants.map(AuthService.normalisePhone).toSet(), hasLength(1));
    });
  });
}
