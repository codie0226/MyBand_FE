class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.isMe,
    required this.timestamp,
  });
}

// 더미 데이터 생성기
List<ChatMessage> generateDummyChatMessages(String bandId) {
  if (bandId == 'b1') {
    return [
      ChatMessage(
        id: '0_1',
        text: '여러분 다음 달 공연 셋리스트 아직 안 정했죠?',
        senderName: '박보컬',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      ),
      ChatMessage(
        id: '0_2',
        text: '네 아직이요. 이번에도 잔잔한 곡 하나 넣을까요?',
        senderName: '이베이스',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 4, minutes: 30)),
      ),
      ChatMessage(
        id: '0_3',
        text: '좋습니다. 아이디어 있으면 편하게 단톡에 남겨주세요.',
        senderName: '최건반',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 4, minutes: 15)),
      ),
      ChatMessage(
        id: '0_4',
        text: '그럼 백예린 곡은 어때요?',
        senderName: '박보컬',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
      ),
      ChatMessage(
        id: '0_5',
        text: '오 찬성합니다! 건반 비중이 좀 있긴 한데 괜찮나요?',
        senderName: '김기타',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 9, minutes: 50)),
      ),
      ChatMessage(
        id: '0_6',
        text: '제가 밤새서 연습해올게요 ㅋㅋㅋ',
        senderName: '최건반',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 9, minutes: 40)),
      ),
      ChatMessage(
        id: '0_7',
        text: '든든하네요! 그럼 확정합시다.',
        senderName: '이베이스',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 9, minutes: 10)),
      ),
      ChatMessage(
        id: '1',
        text: '오늘 합주 7시 맞나요?',
        senderName: '김기타',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      ),
      ChatMessage(
        id: '2',
        text: '네 맞습니다! 다들 악기 챙겨오세요.',
        senderName: '이베이스',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
      ),
      ChatMessage(
        id: '1_1',
        text: '드럼 스틱 하나 빌려주실 분? 연습실 거 너무 낡아서요.',
        senderName: '박드럼',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      ),
      ChatMessage(
        id: '1_2',
        text: '제꺼 여분 있어요 가져갈게요~',
        senderName: '김기타',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 35)),
      ),
      ChatMessage(
        id: '1_3',
        text: '감사합니다!!',
        senderName: '박드럼',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      ChatMessage(
        id: '3',
        text: '저 조금 늦을 것 같아요 ㅠㅠ 차가 막혀서요.',
        senderName: '박보컬',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
      ),
      ChatMessage(
        id: '4',
        text: '알겠습니다! 조심히 오세요~',
        senderName: '이베이스',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 2)),
      ),
      ChatMessage(
        id: '5',
        text: '저도 지금 합정역에서 내려서 걸어가고 있어요. 금방 도착합니다!',
        senderName: '최건반',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      ChatMessage(
        id: '6',
        text: '네 먼저 와서 세팅하고 있을게요.',
        senderName: '이베이스',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
      ),
    ];
  } else if (bandId == 'b2') {
    return [
      ChatMessage(
        id: '10',
        text: '이번 주말 재즈 스탠다드 셋리스트 공유합니다.',
        senderName: '정섹소폰',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      ),
      ChatMessage(
        id: '11',
        text: 'Autumn Leaves 무조건 하죠! 제가 좋아해서요 ㅋㅋ',
        senderName: '이베이스',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        id: '12',
        text: '좋아요. 악보도 카톡으로 보내드릴게요.',
        senderName: '정섹소폰',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
  return [];
}
