import 'package:flutter_test/flutter_test.dart';
import 'package:my_band/core/network/api_resource_url.dart';

void main() {
  test('keeps absolute API resource URLs unchanged', () {
    final uri = resolveApiResourceUri(
      'https://api.example.com/attachments/att-1',
      apiBaseUrl: 'http://localhost:3000',
    );

    expect(uri.toString(), 'https://api.example.com/attachments/att-1');
  });

  test('resolves relative API resource URLs against the backend base URL', () {
    final uri = resolveApiResourceUri(
      '/attachments/att-1',
      apiBaseUrl: 'https://api.example.com',
    );

    expect(uri.toString(), 'https://api.example.com/attachments/att-1');
  });

  test('treats relative URLs as API resources', () {
    expect(isApiResourceUrl('/attachments/att-1'), isTrue);
  });

  test('detects same-origin API resource URLs', () {
    expect(
      isApiResourceUrl(
        'https://api.example.com/attachments/att-1',
        apiBaseUrl: 'https://api.example.com',
      ),
      isTrue,
    );
  });

  test('does not treat external URLs as API resources', () {
    expect(
      isApiResourceUrl(
        'https://lh3.googleusercontent.com/profile.jpg',
        apiBaseUrl: 'https://api.example.com',
      ),
      isFalse,
    );
  });
}
