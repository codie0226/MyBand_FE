import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/network/token_storage.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  ChatRepository(this._api, this._tokenStorage);

  Future<ChatMessagePage> getMessages({
    required String bandId,
    required String currentUserId,
    int limit = 50,
    String? cursor,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (cursor != null) {
      queryParameters['cursor'] = cursor;
    }

    final res = await _api.dio.get<Map<String, dynamic>>(
      '/bands/$bandId/messages',
      queryParameters: queryParameters,
    );

    final data = res.data!;
    final messages = (data['messages'] as List<dynamic>)
        .map(
          (e) => ChatMessage.fromJson(
            e as Map<String, dynamic>,
            currentUserId: currentUserId,
          ),
        )
        .toList();

    return ChatMessagePage(
      messages: messages,
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<ChatMessage> sendMessage({
    required String bandId,
    required String currentUserId,
    required String text,
  }) async {
    final res = await _api.dio.post<Map<String, dynamic>>(
      '/bands/$bandId/messages',
      data: {'text': text},
    );

    return ChatMessage.fromJson(res.data!, currentUserId: currentUserId);
  }

  Future<WebSocketChannel> connectMessages(String bandId) async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('로그인이 필요합니다.');
    }

    final base = Uri.parse(AppConfig.apiBaseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final uri = base.replace(
      scheme: scheme,
      path: '/bands/$bandId/chat',
      queryParameters: {'token': token},
    );

    return WebSocketChannel.connect(uri);
  }

  Stream<ChatMessage> messageStream({
    required WebSocketChannel channel,
    required String currentUserId,
  }) {
    return channel.stream
        .map((raw) => jsonDecode(raw as String) as Map<String, dynamic>)
        .where((event) => event['type'] == 'message')
        .map(
          (event) => ChatMessage.fromJson(
            event['data'] as Map<String, dynamic>,
            currentUserId: currentUserId,
          ),
        );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});
