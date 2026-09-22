import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:url_launcher/url_launcher.dart';

// Chat Detail Screen
class ChatDetailPage extends StatefulWidget {
  final int chatId;
  final String userName;
  final int? currentUserId; // O'zingizning user ID'ingiz

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.userName,
   required this.currentUserId, // Default, keyin o'zgartiring
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatDetailService _chatService = ChatDetailService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Future<ChatResponse> _messagesFuture;
  List<MessageModel> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messagesFuture = _chatService.getChatMessages(widget.chatId);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    final success = await _chatService.sendMessage(widget.chatId, messageText);

    if (success) {
      _loadMessages();
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xatolik yuz berdi')),
      );
    }

    setState(() {
      _isSending = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF6B7FFF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: FutureBuilder<ChatResponse>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7FFF)),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Xatolik yuz berdi',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadMessages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B7FFF),
                          ),
                          child: const Text('Qayta urinish'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Hech qanday xabar yo\'q',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                _messages = snapshot.data!.messages;

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadMessages();
                    await _messagesFuture;
                  },
                  color: const Color(0xFF6B7FFF),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage = message.senderId == widget.currentUserId;

                      return MessageBubble(
                        message: message,
                        isMyMessage: isMyMessage,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Xabar yozing...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B7FFF),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.flag, color: Colors.grey[700], size: 20),
                      onPressed: () {
                        // Attach file functionality
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Message Bubble Widget
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMyMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // System message
    if (message.messageType == 'system') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Regular message
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage)
            GestureDetector(
              onTap: () {
                // Show reply arrow or options
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: Icon(
                  Icons.reply,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMyMessage ? const Color(0xFF6B7FFF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMyMessage ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  // URL if exists
                  if (message.url != null && message.url!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchUrl(message.url!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMyMessage
                              ? Colors.white.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link,
                              size: 16,
                              color: isMyMessage ? Colors.white : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Natija havolada',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isMyMessage ? Colors.white : Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Independent data (test results)
                  if (message.independentData != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMyMessage
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📊 Test natijalari',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isMyMessage ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ball: ${message.independentData!['result']['score']}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMyMessage ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'To\'g\'ri javoblar: ${message.independentData!['result']['correct_answers']}/${message.independentData!['result']['total_answers']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMyMessage ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Time and read status
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMyMessage
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),
                      if (isMyMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Message Model
class MessageModel {
  final int id;
  final int conversation;
  final int senderId;
  final String senderName;
  final String messageType; // text, system
  final String text;
  final String? url;
  final String? file;
  final int? replyTo;
  final String? replyToText;
  final String? replyToSender;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final bool isRead;
  final String? independent;
  final Map<String, dynamic>? independentData;

  MessageModel({
    required this.id,
    required this.conversation,
    required this.senderId,
    required this.senderName,
    required this.messageType,
    required this.text,
    this.url,
    this.file,
    this.replyTo,
    this.replyToText,
    this.replyToSender,
    required this.isEdited,
    required this.isDeleted,
    required this.createdAt,
    required this.isRead,
    this.independent,
    this.independentData,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversation: json['conversation'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      messageType: json['message_type'],
      text: json['text'],
      url: json['url'],
      file: json['file'],
      replyTo: json['reply_to'],
      replyToText: json['reply_to_text'],
      replyToSender: json['reply_to_sender'],
      isEdited: json['is_edited'],
      isDeleted: json['is_deleted'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'],
      independent: json['independent'],
      independentData: json['independent_data'],
    );
  }
}

// Chat Response Model
class ChatResponse {
  final int conversationId;
  final List<MessageModel> messages;

  ChatResponse({
    required this.conversationId,
    required this.messages,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      conversationId: json['conversation_id'],
      messages: (json['messages'] as List)
          .map((msg) => MessageModel.fromJson(msg))
          .toList(),
    );
  }
}

// Chat Service
class ChatDetailService {
  static const String baseUrl = 'https://api.iqmath.uz/api/v1/func_chat';

  Future<ChatResponse> getChatMessages(int chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId/messages/'),
        headers: {
          'Content-Type': 'application/json',
          // Authorization headerini qo'shing:
          'Authorization': sl<LocalSource>().getAccessToken()??'',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return ChatResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> sendMessage(int chatId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$chatId/send/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sl<LocalSource>().getAccessToken()??'',
        },
        body: json.encode({
          'text': message,
          'message_type': 'text',
        }),
      );
alice.onHttpResponse(response);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}