import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/enhanced_messaging_service.dart';
import '../services/chat_room_service.dart';
import '../models/messaging_models.dart';
import '../widgets/chat_ui_components.dart';

/// Complete Chat Screen
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String? initialMessage;

  const ChatScreen({
    Key? key,
    required this.chatId,
    this.initialMessage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  final ScrollController _scrollController = ScrollController();
  final MessagingService _messagingService = MessagingService.instance;
  final ChatRoomService _chatRoomService = ChatRoomService.instance;
  
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;
  
  ChatModel? _chat;
  List<MessageModel> _messages = [];
  List<TypingIndicator> _typingUsers = [];
  String? _currentUserId;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    _setupScrollListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _messagingService.stopTyping(widget.chatId);
    }
  }

  Future<void> _initialize() async {
    try {
      // Get current user ID (would come from auth service)
      _currentUserId = 'current_user_id'; // Replace with actual auth
      
      // Load chat details
      await _loadChat();
      
      // Load initial messages
      await _loadMessages();
      
      // Setup real-time subscriptions
      _setupRealTimeSubscriptions();
      
      // Send initial message if provided
      if (widget.initialMessage != null) {
        await _sendMessage(widget.initialMessage!);
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to load chat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChat() async {
    final chat = await _chatRoomService.getChatById(widget.chatId);
    setState(() => _chat = chat);
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (loadMore && (!_hasMoreMessages || _isLoadingMore)) return;
    
    try {
      if (loadMore) {
        setState(() => _isLoadingMore = true);
      }
      
      final messages = await _messagingService.getMessages(
        chatId: widget.chatId,
        limit: 20,
        offset: loadMore ? _messages.length : 0,
      );
      
      setState(() {
        if (loadMore) {
          _messages.addAll(messages);
          _isLoadingMore = false;
        } else {
          _messages = messages;
        }
        
        _hasMoreMessages = messages.length == 20;
      });
      
      if (!loadMore) {
        _scrollToBottom(animated: false);
      }
    } catch (e) {
      setState(() {
        if (loadMore) {
          _isLoadingMore = false;
        }
        _error = 'Failed to load messages: $e';
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Load more messages when near top
      if (_scrollController.position.pixels <= 200 && _hasMoreMessages) {
        _loadMessages(loadMore: true);
      }
    });
  }

  void _setupRealTimeSubscriptions() {
    // Listen for new messages
    _messagesSubscription = _messagingService
        .getChatMessagesStream(widget.chatId)
        .listen(
      (messages) {
        setState(() => _messages = messages);
        _scrollToBottom();
      },
      onError: (error) {
        print('❌ Messages stream error: $error');
      },
    );

    // Listen for typing indicators
    _typingSubscription = _messagingService
        .getTypingIndicatorStream(widget.chatId)
        .listen(
      (indicators) {
        setState(() {
          _typingUsers = indicators
              .where((i) => i.userId != _currentUserId && i.isTyping)
              .toList();
        });
      },
      onError: (error) {
        print('❌ Typing stream error: $error');
      },
    );
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _chat == null) return;
    
    try {
      await _messagingService.sendMessage(
        chatId: widget.chatId,
        content: content.trim(),
        type: MessageType.text,
      );
      
      _scrollToBottom();
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  Future<void> _sendImageMessage() async {
    try {
      // This would open image picker
      // For now, simulate with placeholder
      await _messagingService.sendMessage(
        chatId: widget.chatId,
        content: 'Photo',
        type: MessageType.image,
        // attachments: [picked image]
      );
      
      _scrollToBottom();
    } catch (e) {
      _showError('Failed to send image: $e');
    }
  }

  Future<void> _sendFileMessage() async {
    try {
      // This would open file picker
      // For now, simulate with placeholder
      await _messagingService.sendMessage(
        chatId: widget.chatId,
        content: 'Document',
        type: MessageType.file,
        // attachments: [picked file]
      );
      
      _scrollToBottom();
    } catch (e) {
      _showError('Failed to send file: $e');
    }
  }

  void _onTypingChanged(bool isTyping) {
    if (_currentUserId == null) return;
    
    if (isTyping) {
      _messagingService.startTyping(widget.chatId);
      
      // Stop typing after 3 seconds of inactivity
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _messagingService.stopTyping(widget.chatId);
      });
    } else {
      _messagingService.stopTyping(widget.chatId);
      _typingTimer?.cancel();
    }
  }

  void _onMessageTap(MessageModel message) {
    // Handle message tap (e.g., show details, copy text)
    if (message.type == MessageType.text) {
      Clipboard.setData(ClipboardData(text: message.content));
      _showSnackBar('Message copied to clipboard');
    }
  }

  void _onMessageLongPress(MessageModel message) {
    // Show message options (react, reply, copy, delete, etc.)
    _showMessageOptions(message);
  }

  void _onReactionTap(MessageModel message, String emoji) async {
    try {
      await _messagingService.addReaction(
        messageId: message.id,
        emoji: emoji,
      );
    } catch (e) {
      _showError('Failed to add reaction: $e');
    }
  }

  void _showMessageOptions(MessageModel message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageOptionsSheet(
        message: message,
        isFromCurrentUser: message.senderId == _currentUserId,
        onReply: () => _replyToMessage(message),
        onCopy: () => _copyMessage(message),
        onDelete: () => _deleteMessage(message),
        onReact: (emoji) => _onReactionTap(message, emoji),
      ),
    );
  }

  void _replyToMessage(MessageModel message) {
    // Implement reply functionality
    Navigator.pop(context);
    _showSnackBar('Reply to: ${message.content}');
  }

  void _copyMessage(MessageModel message) {
    Clipboard.setData(ClipboardData(text: message.content));
    Navigator.pop(context);
    _showSnackBar('Message copied to clipboard');
  }

  Future<void> _deleteMessage(MessageModel message) async {
    Navigator.pop(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _messagingService.deleteMessage(message.id);
      } catch (e) {
        _showError('Failed to delete message: $e');
      }
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getChatSubtitle() {
    if (_chat == null) return '';
    
    if (_chat!.type == ChatType.private) {
      final otherUser = _chat!.participants
          .firstWhere((p) => p.userId != _currentUserId);
      return _getUserStatusText(otherUser.user.status);
    } else {
      final activeCount = _chat!.participants
          .where((p) => p.isActive)
          .length;
      return '$activeCount members';
    }
  }

  String _getUserStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return 'online';
      case UserStatus.offline:
        return 'offline';
      case UserStatus.away:
        return 'away';
      case UserStatus.busy:
        return 'busy';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _initialize(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ChatAppBar(
        title: _chat?.name ?? 'Chat',
        subtitle: _getChatSubtitle(),
        avatarUrl: _chat?.avatarUrl,
        onAvatarTap: () => _showChatInfo(),
        actions: [
          IconButton(
            onPressed: _showChatInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          if (_typingUsers.isNotEmpty) _buildTypingIndicators(),
          MessageInput(
            onSendMessage: _sendMessage,
            onAttachmentTap: _sendFileMessage,
            onCameraTap: _sendImageMessage,
            onTypingChanged: _onTypingChanged,
            hintText: 'Message ${_chat?.name ?? 'chat'}',
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoadingMore && index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final message = _messages[_messages.length - 1 - index];
        final isFromCurrentUser = message.senderId == _currentUserId;
        
        // Show avatar and timestamp for first message in a group
        final showAvatar = index == 0 || 
            _messages[_messages.length - index].senderId != message.senderId;
        
        final showTimestamp = index == 0 ||
            DateTime.now().difference(message.createdAt).inMinutes > 5;

        return MessageBubble(
          key: ValueKey(message.id),
          message: message,
          isFromCurrentUser: isFromCurrentUser,
          showAvatar: showAvatar && !isFromCurrentUser,
          showTimestamp: showTimestamp,
          onTap: () => _onMessageTap(message),
          onLongPress: () => _onMessageLongPress(message),
          onReactionTap: (emoji) => _onReactionTap(message, emoji),
        );
      },
    );
  }

  Widget _buildTypingIndicators() {
    final usernames = _typingUsers.map((t) => t.username).toList();
    
    return TypingIndicator(
      usernames: usernames,
    );
  }

  void _showChatInfo() {
    if (_chat == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatInfoScreen(chat: _chat!),
      ),
    );
  }
}

/// Message Options Bottom Sheet
class MessageOptionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isFromCurrentUser;
  final VoidCallback? onReply;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final Function(String)? onReact;

  const MessageOptionsSheet({
    Key? key,
    required this.message,
    required this.isFromCurrentUser,
    this.onReply,
    this.onCopy,
    this.onDelete,
    this.onReact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick reactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['👍', '❤️', '😂', '😢', '😡', '👏'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  onReact?.call(emoji);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          if (onReply != null)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: onReply,
            ),
          
          if (onCopy != null && message.type == MessageType.text)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: onCopy,
            ),
          
          if (onDelete != null && isFromCurrentUser)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
        ],
      ),
    );
  }
}

/// Chat Info Screen (placeholder)
class ChatInfoScreen extends StatelessWidget {
  final ChatModel chat;

  const ChatInfoScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${chat.name} Info'),
      ),
      body: ListView(
        children: [
          // Chat avatar and name
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: chat.avatarUrl != null 
                      ? NetworkImage(chat.avatarUrl!) 
                      : null,
                  child: chat.avatarUrl == null
                      ? Text(
                          chat.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  chat.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (chat.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    chat.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          // Chat details
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Members'),
            subtitle: Text('${chat.participantCount} members'),
            onTap: () {
              // Show members list
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Created'),
            subtitle: Text(_formatDate(chat.createdAt)),
          ),
          
          if (chat.type == ChatType.group) ...[
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Chat Settings'),
              onTap: () {
                // Show settings
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Leave Chat', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Leave chat
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}