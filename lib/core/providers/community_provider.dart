import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../services/supabase_service.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final DateTime timestamp;
  final String? replyToId;
  final String? replyToMessage;
  final List<String> imageUrls;
  final bool isEdited;
  final bool isDeleted;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    this.replyToId,
    this.replyToMessage,
    this.imageUrls = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.type = MessageType.text,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? message,
    DateTime? timestamp,
    String? replyToId,
    String? replyToMessage,
    List<String>? imageUrls,
    bool? isEdited,
    bool? isDeleted,
    MessageType? type,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      replyToId: replyToId ?? this.replyToId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      imageUrls: imageUrls ?? this.imageUrls,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'reply_to_id': replyToId,
      'reply_to_message': replyToMessage,
      'image_urls': imageUrls,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'type': type.name,
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? 'Anonymous',
      senderAvatar: json['sender_avatar'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      replyToId: json['reply_to_id'],
      replyToMessage: json['reply_to_message'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      isEdited: json['is_edited'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

enum MessageType { text, image, file, location, crop_query, market_update }

class ChatRoom {
  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'is_active': isActive,
    };
  }

  static ChatRoom fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      memberCount: json['member_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }
}

class CommunityService {
  static StreamSubscription? _messageSubscription;
  static StreamSubscription? _roomSubscription;

  static void initialize() {
    _setupRealTimeListeners();
  }

  static void dispose() {
    _messageSubscription?.cancel();
    _roomSubscription?.cancel();
  }

  static void _setupRealTimeListeners() {
    if (!SupabaseService.isInitialized) {
      print('Supabase not initialized yet, skipping real-time listeners setup');
      return;
    }

    try {
      // Listen to new messages
      _messageSubscription = SupabaseService.client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .listen((data) {
            // Handle real-time message updates
            for (final message in data) {
              _handleNewMessage(ChatMessage.fromJson(message));
            }
          });

      // Listen to room updates
      _roomSubscription = SupabaseService.client
          .from('chat_rooms')
          .stream(primaryKey: ['id'])
          .listen((data) {
            // Handle real-time room updates
            for (final room in data) {
              _handleRoomUpdate(ChatRoom.fromJson(room));
            }
          });
    } catch (e) {
      print('Error setting up real-time listeners: $e');
    }
  }

  static void _handleNewMessage(ChatMessage message) {
    // Notify message listeners
    print('New message received: ${message.message}');
  }

  static void _handleRoomUpdate(ChatRoom room) {
    // Notify room listeners
    print('Room updated: ${room.name}');
  }

  static Future<List<ChatRoom>> getChatRooms() async {
    try {
      if (!SupabaseService.isInitialized) {
        print('Supabase not initialized yet, returning empty chat rooms');
        return [];
      }

      final response = await SupabaseService.client
          .from('chat_rooms')
          .select('*')
          .eq('is_active', true)
          .order('member_count', ascending: false);

      return (response as List).map((json) => ChatRoom.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return _getDefaultChatRooms();
    }
  }

  static List<ChatRoom> _getDefaultChatRooms() {
    return [
      ChatRoom(
        id: 'general',
        name: 'General Discussion',
        description: 'General farming discussions and tips',
        category: 'general',
        memberCount: 1250,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastMessage: 'Weather looks good for sowing this week',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatRoom(
        id: 'crop_advisory',
        name: 'Crop Advisory',
        description: 'Expert advice on crop management',
        category: 'advisory',
        memberCount: 850,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        lastMessage: 'Best time for wheat sowing in North India',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ChatRoom(
        id: 'market_updates',
        name: 'Market Updates',
        description: 'Latest market prices and trends',
        category: 'market',
        memberCount: 950,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastMessage: 'Onion prices rising in Delhi markets',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatRoom(
        id: 'pest_management',
        name: 'Pest Management',
        description: 'Pest and disease control discussions',
        category: 'pest',
        memberCount: 675,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        lastMessage: 'Organic solutions for aphid control',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatRoom(
        id: 'technology',
        name: 'Farm Technology',
        description: 'Modern farming tools and techniques',
        category: 'technology',
        memberCount: 425,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastMessage: 'Drone spraying benefits and costs',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];
  }

  static Future<List<ChatMessage>> getMessages(
    String roomId, {
    int limit = 50,
  }) async {
    try {
      if (!SupabaseService.isInitialized) {
        print('Supabase not initialized yet, returning empty messages');
        return [];
      }

      final response = await SupabaseService.client
          .from('chat_messages')
          .select('*')
          .eq('room_id', roomId)
          .eq('is_deleted', false)
          .order('timestamp', ascending: false)
          .limit(limit);

      final messages = (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
      return messages.reversed.toList(); // Reverse to show oldest first
    } catch (e) {
      print('Error fetching messages: $e');
      return _getDefaultMessages(roomId);
    }
  }

  static List<ChatMessage> _getDefaultMessages(String roomId) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Raj Patel',
        senderAvatar: '',
        message: 'Good morning everyone! How are your crops doing?',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: '2',
        senderId: 'user2',
        senderName: 'Priya Sharma',
        senderAvatar: '',
        message:
            'My tomatoes are showing good growth. Used organic fertilizer this season.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: '3',
        senderId: 'user3',
        senderName: 'Manoj Singh',
        senderAvatar: '',
        message: 'Can anyone suggest best time for wheat sowing in Punjab?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        type: MessageType.crop_query,
      ),
      ChatMessage(
        id: '4',
        senderId: 'user4',
        senderName: 'Expert Farmer',
        senderAvatar: '',
        message:
            '@Manoj Singh Mid-November is ideal for wheat sowing in Punjab. Soil temperature should be around 18-20°C.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
        replyToId: '3',
        replyToMessage:
            'Can anyone suggest best time for wheat sowing in Punjab?',
        type: MessageType.text,
      ),
      ChatMessage(
        id: '5',
        senderId: 'user5',
        senderName: 'Anita Verma',
        senderAvatar: '',
        message:
            'Market prices for onions are increasing. Good time to sell if you have stock.',
        timestamp: now.subtract(const Duration(minutes: 45)),
        type: MessageType.market_update,
      ),
    ];
  }

  static Future<String> sendMessage({
    required String roomId,
    required String message,
    String? replyToId,
    List<String> imageUrls = const [],
    MessageType type = MessageType.text,
  }) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userProfile = await SupabaseService.getCurrentUser();
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      final chatMessage = ChatMessage(
        id: messageId,
        senderId: user.id,
        senderName: userProfile?['full_name'] ?? 'Anonymous',
        senderAvatar: userProfile?['avatar_url'] ?? '',
        message: message,
        timestamp: DateTime.now(),
        replyToId: replyToId,
        imageUrls: imageUrls,
        type: type,
      );

      // Get reply message if replying
      String? replyToMessage;
      if (replyToId != null) {
        final replyResponse = await SupabaseService.client
            .from('chat_messages')
            .select('message')
            .eq('id', replyToId)
            .single();
        replyToMessage = replyResponse['message'];
      }

      final messageData = chatMessage.toJson();
      messageData['room_id'] = roomId;
      messageData['reply_to_message'] = replyToMessage;

      await SupabaseService.client.from('chat_messages').insert(messageData);

      // Update room's last message
      await SupabaseService.client
          .from('chat_rooms')
          .update({
            'last_message': message.length > 50
                ? '${message.substring(0, 50)}...'
                : message,
            'last_message_time': DateTime.now().toIso8601String(),
          })
          .eq('id', roomId);

      return messageId;
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  static Future<void> editMessage(String messageId, String newMessage) async {
    try {
      await SupabaseService.client
          .from('chat_messages')
          .update({'message': newMessage, 'is_edited': true})
          .eq('id', messageId);
    } catch (e) {
      print('Error editing message: $e');
      throw Exception('Failed to edit message');
    }
  }

  static Future<void> deleteMessage(String messageId) async {
    try {
      await SupabaseService.client
          .from('chat_messages')
          .update({'is_deleted': true})
          .eq('id', messageId);
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message');
    }
  }

  static Future<void> joinRoom(String roomId) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await SupabaseService.client.from('room_members').upsert({
        'room_id': roomId,
        'user_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Increment member count
      await SupabaseService.client.rpc(
        'increment_room_members',
        params: {'room_id': roomId},
      );
    } catch (e) {
      print('Error joining room: $e');
    }
  }

  static Future<void> leaveRoom(String roomId) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await SupabaseService.client
          .from('room_members')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', user.id);

      // Decrement member count
      await SupabaseService.client.rpc(
        'decrement_room_members',
        params: {'room_id': roomId},
      );
    } catch (e) {
      print('Error leaving room: $e');
    }
  }

  static Stream<List<ChatMessage>> getMessageStream(String roomId) {
    if (!SupabaseService.isInitialized) {
      return Stream.value([]); // Return empty stream if not initialized
    }

    return SupabaseService.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: true)
        .map(
          (data) => data
              .where(
                (json) =>
                    json['room_id'] == roomId &&
                    (json['is_deleted'] == false || json['is_deleted'] == null),
              )
              .map((json) => ChatMessage.fromJson(json))
              .toList(),
        );
  }
}

class ChatRoomNotifier extends StateNotifier<List<ChatRoom>> {
  ChatRoomNotifier() : super([]) {
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await CommunityService.getChatRooms();
      state = rooms;
    } catch (e) {
      print('Error loading chat rooms: $e');
    }
  }

  Future<void> refresh() async {
    await _loadRooms();
  }

  void updateRoom(ChatRoom updatedRoom) {
    state = state
        .map((room) => room.id == updatedRoom.id ? updatedRoom : room)
        .toList();
  }
}

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final String roomId;
  StreamSubscription? _messageSubscription;

  ChatMessagesNotifier(this.roomId) : super([]) {
    _loadMessages();
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await CommunityService.getMessages(roomId);
      state = messages;
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _setupRealTimeListener() {
    _messageSubscription = CommunityService.getMessageStream(roomId).listen((
      messages,
    ) {
      state = messages;
    });
  }

  Future<void> sendMessage(
    String message, {
    String? replyToId,
    MessageType type = MessageType.text,
  }) async {
    try {
      await CommunityService.sendMessage(
        roomId: roomId,
        message: message,
        replyToId: replyToId,
        type: type,
      );
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  Future<void> editMessage(String messageId, String newMessage) async {
    try {
      await CommunityService.editMessage(messageId, newMessage);
    } catch (e) {
      print('Error editing message: $e');
      throw e;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await CommunityService.deleteMessage(messageId);
    } catch (e) {
      print('Error deleting message: $e');
      throw e;
    }
  }
}

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomNotifier, List<ChatRoom>>((ref) {
      return ChatRoomNotifier();
    });

final chatMessagesProvider =
    StateNotifierProvider.family<
      ChatMessagesNotifier,
      List<ChatMessage>,
      String
    >((ref, roomId) {
      return ChatMessagesNotifier(roomId);
    });

final activeChatRoomsProvider = Provider<List<ChatRoom>>((ref) {
  final rooms = ref.watch(chatRoomsProvider);
  return rooms.where((room) => room.isActive).toList();
});

final roomMemberCountProvider = Provider.family<int, String>((ref, roomId) {
  final rooms = ref.watch(chatRoomsProvider);
  final room = rooms.firstWhere(
    (r) => r.id == roomId,
    orElse: () => ChatRoom(
      id: roomId,
      name: '',
      description: '',
      category: '',
      memberCount: 0,
      createdAt: DateTime.now(),
    ),
  );
  return room.memberCount;
});
