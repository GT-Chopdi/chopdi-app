import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/data/remote/error_code.dart';

/// Guards the client/server error-code contract.
///
/// These strings are not internal identifiers — the server sends them and this
/// app branches on them to decide whether an operation can be retried. Renaming
/// one on the server silently breaks every installed build until users update,
/// which for a mobile app can be months. A monorepo lets that change land in a
/// single PR; this test is what makes the PR fail when only one side moves.
void main() {
  const serverSource = '../api/src/common/errors/app.exception.ts';

  test('every server ErrorCode exists in the Dart mirror', () {
    final file = File(serverSource);

    expect(
      file.existsSync(),
      isTrue,
      reason: 'Cannot find $serverSource. This test compares the Dart mirror '
          'against the server, so a missing source means the contract is '
          'unverified — not that it is fine.',
    );

    final block = RegExp(r'export const ErrorCode = \{(.*?)\} as const;', dotAll: true)
        .firstMatch(file.readAsStringSync());

    expect(block, isNotNull, reason: 'ErrorCode block not found — did its shape change?');

    final serverCodes = RegExp(r"^\s*[A-Z_]+:\s*'([A-Z_]+)'", multiLine: true)
        .allMatches(block!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();

    expect(serverCodes, isNotEmpty, reason: 'Parsed zero codes — the parser is stale.');

    expect(
      serverCodes.difference(ApiErrorCode.known),
      isEmpty,
      reason: 'The server defines codes this client does not know. Add them to '
          'lib/data/remote/error_code.dart.',
    );

    expect(
      ApiErrorCode.known.difference(serverCodes),
      isEmpty,
      reason: 'This client references codes the server no longer sends. They '
          'are dead branches — remove them.',
    );
  });

  test('reauth codes are real codes, not typos', () {
    expect(ApiErrorCode.requiresReauth.difference(ApiErrorCode.known), isEmpty);
  });
}
