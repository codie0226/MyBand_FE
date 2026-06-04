import 'package:flutter_test/flutter_test.dart';
import 'package:my_band/features/chat/data/chat_repository.dart';

void main() {
  group('buildChatWebSocketUri', () {
    test('uses ws for http API hosts without token query params', () {
      final uri = buildChatWebSocketUri(
        apiBaseUrl: 'http://localhost:3000',
        bandId: 'band-1',
      );

      expect(uri.scheme, 'ws');
      expect(uri.host, 'localhost');
      expect(uri.port, 3000);
      expect(uri.path, '/bands/band-1/chat');
      expect(uri.queryParameters, isEmpty);
    });

    test('uses wss for https API hosts without token query params', () {
      final uri = buildChatWebSocketUri(
        apiBaseUrl: 'https://api.example.com',
        bandId: 'band-1',
      );

      expect(uri.toString(), 'wss://api.example.com/bands/band-1/chat');
    });
  });

  test('buildChatWebSocketProtocols sends bearer subprotocol before jwt', () {
    expect(buildChatWebSocketProtocols('jwt-token'), ['bearer', 'jwt-token']);
  });
}
