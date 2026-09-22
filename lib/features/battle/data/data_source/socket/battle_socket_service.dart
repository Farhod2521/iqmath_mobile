import 'dart:async';
import 'dart:convert';

import 'package:my_flutter_template/constants/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Battle xonasi uchun WebSocket ulanishi.
///
/// Veb ilovada qayta ulanish (reconnect) mantiqi umuman yo'q — mobil
/// tarmoqlar ko'proq uzilib turgani uchun bu yerda oddiy backoff bilan
/// avtomatik qayta ulanish qo'shilgan. Server `room_snapshot` orqali
/// joriy holatni (savol, o'tgan vaqt) to'liq qayta yuboradi, shu sababli
/// qayta ulanish xavfsiz.
class BattleSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  int _reconnectAttempts = 0;
  bool _manuallyClosed = false;
  int? _roomId;
  String? _token;

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  /// `true` — ulangan, `false` — uzilgan/ulanmoqda.
  Stream<bool> get connectionState => _connectionController.stream;

  void connect({required int roomId, required String token}) {
    _roomId = roomId;
    _token = token;
    _manuallyClosed = false;
    _reconnectAttempts = 0;
    _openChannel();
  }

  void _openChannel() {
    if (_roomId == null || _token == null) return;

    final uri = Uri.parse(
      '${Constants.battleWsBase}/$_roomId/?token=$_token',
    );

    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;

      _channelSubscription = channel.stream.listen(
        (raw) {
          _reconnectAttempts = 0;
          if (!_connectionController.isClosed) {
            _connectionController.add(true);
          }
          _handleRawMessage(raw);
        },
        onError: (_) => _scheduleReconnect(),
        onDone: () {
          if (!_manuallyClosed) _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _handleRawMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String);
      if (decoded is Map<String, dynamic> && !_eventController.isClosed) {
        _eventController.add(decoded);
      }
    } catch (_) {
      // Noto'g'ri JSON — e'tiborsiz qoldiramiz
    }
  }

  void _scheduleReconnect() {
    if (_manuallyClosed) return;
    if (!_connectionController.isClosed) _connectionController.add(false);

    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    // 1s, 2s, 4s, 8s ... maksimum 15s oralig'ida qayta urinadi
    final delaySeconds = (1 << _reconnectAttempts).clamp(1, 15);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_manuallyClosed) _openChannel();
    });
  }

  void send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(payload));
    } catch (_) {
      // Ulanish uzilgan bo'lishi mumkin — keyingi reconnect kutiladi
    }
  }

  /// `answerFields` — savol turiga qarab o'zgaradigan javob maydonlari,
  /// masalan `{'choices': [id]}` yoki `{'answer_uz': matn}` yoki
  /// `{'answers': [matn1, matn2]}`.
  void sendAnswer({
    required int questionOrder,
    required Map<String, dynamic> answerFields,
  }) {
    send({
      'type': 'answer',
      'question_order': questionOrder,
      ...answerFields,
    });
  }

  void sendSkip(int questionOrder) {
    send({'type': 'skip', 'question_order': questionOrder});
  }

  void sendChat(String text) {
    send({'type': 'chat', 'text': text});
  }

  void sendTimeoutCheck(int questionOrder) {
    send({'type': 'timeout_check', 'question_order': questionOrder});
  }

  void dispose() {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    if (!_eventController.isClosed) _eventController.close();
    if (!_connectionController.isClosed) _connectionController.close();
  }
}
