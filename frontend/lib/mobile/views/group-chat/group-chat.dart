import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/shared/models/message.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/config_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GroupChatPage extends StatefulWidget {
  final int groupId;

  const GroupChatPage({super.key, required this.groupId});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();
  String baseUrl = ConfigService.baseUrl;
  String wsUrl = ConfigService.wsUrl;
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/ws/${widget.groupId}'),
    );
    _channel.stream.listen((message) {
      print(message);
      setState(() {
        _messages.add(Message.fromJson(jsonDecode(message)));
      });
    });
  }

  void _fetchMessages() async {
    final url = Uri.parse('$baseUrl/groups/${widget.groupId}/messages');
    final user = Provider.of<UserProvider>(context, listen: false).user;

    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer ${user!.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _messages = data.map((json) => Message.fromJson(json)).toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      // Handle error
      print("error");
    }
  }

  void _sendMessage(String content) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final message = Message(
      userId: user!.id,
      content: content,
    );

    _channel.sink.add(json.encode(message.toJson()));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.userId == user!.id;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMe
                            ? message.username.toString()
                            : message.username.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.blue : Colors.green,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[600] : Colors.grey[600],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(message.content),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
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
    _channel.sink.close();
    _scrollController.dispose();
    super.dispose();
  }
}
