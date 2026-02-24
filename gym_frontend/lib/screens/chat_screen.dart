import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int userId;
  final int trainerId;
  final String trainerName;
  final String senderType; // 'user' or 'trainer'

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.trainerId,
    required this.trainerName,
    required this.senderType,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/api/chat/messages/${widget.userId}/${widget.trainerId}/?reader_type=${widget.senderType}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = data['messages'] ?? [];
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load messages');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/chat/send/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'trainer_id': widget.trainerId,
          'message': message,
          'sender_type': widget.senderType,
        }),
      );

      if (response.statusCode == 201) {
        _loadMessages(); // Reload messages to show the new one
      } else {
        _showError('Failed to send message');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isMine = message['sender_type'] == widget.senderType;
    final senderName = message['sender_name'] ?? 'Unknown';
    final messageText = message['message'] ?? '';
    final timestamp = message['created_at'] ?? '';
    final senderType = message['sender_type'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              backgroundColor: senderType == 'trainer' ? const Color(0xFF0F766E) : const Color(0xFF0891B2),
              child: Icon(
                senderType == 'trainer' ? Icons.fitness_center : Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMine 
                    ? (widget.senderType == 'trainer' ? const Color(0xFF0F766E) : const Color(0xFF0891B2))
                    : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 0),
                  bottomRight: Radius.circular(isMine ? 0 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${senderName} (${senderType == 'trainer' ? 'Trainer' : 'User'})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMine ? Colors.white : Colors.grey[800],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    messageText,
                    style: TextStyle(
                      color: isMine ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isMine ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: widget.senderType == 'trainer' ? const Color(0xFF0F766E) : const Color(0xFF0891B2),
              child: Icon(
                widget.senderType == 'trainer' ? Icons.fitness_center : Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      // Parse UTC timestamp and convert to local time
      final dateTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final difference = today.difference(messageDate).inDays;

      if (difference == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2933),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.trainerName[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFF1F2933)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.trainerName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: const Color(0xFF0F766E),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
