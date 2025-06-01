import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(AppState appState) {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: appState.userProfile?.name ?? 'User',
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    appState.addChatMessage(message);
    _messageController.clear();
    
    // 메시지를 보낸 후 하단으로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final userType = appState.userType;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('과외방'),
            backgroundColor: userType == 'student' ? Colors.blue.shade500 : Colors.green.shade500,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (userType == 'student') {
                  context.go('/student');
                } else {
                  context.go('/tutor');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showChatInfo(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // 채팅 메시지 리스트
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: appState.chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = appState.chatMessages[index];
                      return _buildMessageBubble(message, appState);
                    },
                  ),
                ),
              ),
              
              // 메시지 입력 영역
              _buildMessageInput(appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, AppState appState) {
    final isMyMessage = message.sender == appState.userProfile?.name;
    final isSystemMessage = message.isSystem;

    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.amber.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                message.sender[0],
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMyMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.sender,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMyMessage ? Colors.blue.shade500 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMyMessage ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: Text(
                message.sender[0],
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(appState),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: appState.userType == 'student' ? Colors.blue.shade500 : Colors.green.shade500,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(appState),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info,
                  size: 48,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                const Text(
                  '과외방 안내',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '• 튜터와 학생이 소통할 수 있는 공간입니다\n'
                  '• 수업 관련 질문과 답변을 나눠보세요\n'
                  '• 시스템 메시지로 중요한 공지를 확인하세요\n'
                  '• 예의 바른 대화를 부탁드립니다',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('닫기'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // 시스템 메시지 추가
                        final appState = Provider.of<AppState>(context, listen: false);
                        final systemMessage = ChatMessage(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          sender: 'system',
                          content: '📢 공지: 다음 주 화요일은 공휴일로 인해 수업이 없습니다.',
                          timestamp: DateTime.now(),
                          isSystem: true,
                        );
                        appState.addChatMessage(systemMessage);
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      },
                      child: const Text('공지 추가'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 