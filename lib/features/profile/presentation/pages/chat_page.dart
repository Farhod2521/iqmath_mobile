import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/subject/presentation/pages/telegram_bot_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:my_flutter_template/injector_container.dart';

import 'chat_detail_page.dart';

// Chat List Screen
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  late Future<List<ChatModel>> _chatListFuture;

  @override
  void initState() {
    super.initState();
    _chatListFuture = _chatService.getChatList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = TelegramBotLocalization(state.appLocale ?? 'uz');
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(l10n.title),
          ),
          body: FutureBuilder<List<ChatModel>>(
            future: _chatListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6B7FFF)),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Xatolik yuz berdi',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _chatListFuture = _chatService.getChatList();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7FFF),
                        ),
                        child: const Text('Qayta urinish'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Hech qanday suhbat yo\'q',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _chatListFuture = _chatService.getChatList();
                  });
                  await _chatListFuture;
                },
                color: const Color(0xFF6B7FFF),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatListItem(chat: snapshot.data![index]);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Chat List Item Widget
class ChatListItem extends StatelessWidget {
  final ChatModel chat;

  const ChatListItem({super.key, required this.chat});

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> words = name.trim().split(' ');
    if (words.length >= 2) {
      return words[0][0].toUpperCase() + words[1][0].toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final chatDate = DateTime(date.year, date.month, date.day);

    if (chatDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (chatDate == today.subtract(const Duration(days: 1))) {
      return 'Kecha';
    } else if (now.difference(chatDate).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MM-dd').format(date);
    }
  }

  Color _getAvatarColor(int userId) {
    List<Color> colors = [
      const Color(0xFF6B7FFF),
      const Color(0xFF7F6BFF),
      const Color(0xFF6BFFA3),
      const Color(0xFFFF6B9D),
      const Color(0xFFFFB56B),
    ];
    return colors[userId % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Chat detail screen'ga o'tish
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatId: chat.id,
              userName: chat.otherUserName,
              currentUserId: int.tryParse(sl<LocalSource>().getUserId() ?? '0'),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getAvatarColor(chat.otherUserId),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getInitials(chat.otherUserName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.otherUserName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(chat.lastMessageAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat Model
class ChatModel {
  final int id;
  final String chatType;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String otherUserName;
  final int otherUserId;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.chatType,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.otherUserName,
    required this.otherUserId,
    required this.unreadCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      chatType: json['chat_type'],
      lastMessage: json['last_message'],
      lastMessageAt: DateTime.parse(json['last_message_at']),
      otherUserName: json['other_user_name'],
      otherUserId: json['other_user_id'],
      unreadCount: json['unread_count'],
    );
  }
}

// Chat Service
class ChatService {
  static const String baseUrl = 'https://api.iqmath.uz/api/v1/func_chat';

  Future<List<ChatModel>> getChatList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/list/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sl<LocalSource>().getAccessToken() ?? '',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ChatModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
