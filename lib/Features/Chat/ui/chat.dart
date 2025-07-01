// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Models/Hive/Chat/chats.dart';
import 'package:tetris/Core/Models/Hive/Home/user_chat_model.dart';
import 'package:tetris/Features/Chat/state/chat.dart';
import 'package:tetris/Features/Home/state/home.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/generate_id.dart';

class ChatPage extends StatefulWidget {
  final String? username;
  final String? displayName;
  final String? userImage;

  const ChatPage({
    super.key,
    required this.username,
    required this.displayName,
    required this.userImage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(
        () => Provider.of<ChatPageModel>(
          context,
          listen: false,
        ).startTyping(_controller),
      );
      Provider.of<HomePageModel>(
        context,
        listen: false,
      ).loadChats(widget.username!);
    });
    super.initState();
  }

  Future<void> sendMessage() async {
    String currentUserName = UserDataProvider().basicUserData.username;
    Map<String, dynamic> chat = {
      "messageId": UUID.generateId(),
      "message": _controller.text,
      "from": currentUserName,
      "to": widget.username,
      "timeStamp": DateTime.now().toString(),
      "seen": 0,
    };
    UserChatModel instance = UserChatModel(
      profilePhotoUrl: widget.userImage!,
      displayName: widget.displayName!,
      lastMessage: _controller.text,
      timeStamp: DateTime.now().toString(),
      username: widget.username!,
    );

    ChatsData chatInstance = ChatsData(
      from: currentUserName,
      message: _controller.text,
      messageId: UUID.generateId(),
      seen: 0,
      timeStamp: DateTime.now().toString(),
    );

    Provider.of<HomePageModel>(
      context,
      listen: false,
    ).insertUser(widget.username!, instance);

    Provider.of<HomePageModel>(
      context,
      listen: false,
    ).insertChat(widget.username!, chatInstance);

    if (mounted)
      Provider.of<ChatPageModel>(
        context,
        listen: false,
      ).sendMessage(chat, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[200],
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircleAvatar(
                  backgroundImage:
                      widget.userImage!.contains("default_user")
                          ? AssetImage("assets/image/default_user.png")
                          : NetworkImage(widget.userImage!),
                ),
              ),
              const SizedBox(width: 25),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.displayName ?? "Default User",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("online", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.phone, color: Colors.black),
              SizedBox(width: 13),
              Icon(Icons.video_camera_front, color: Colors.black),
              SizedBox(width: 13),
              Icon(Icons.more_vert, color: Colors.black),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<HomePageModel>(
              builder: (context, instance, child) {
                return ListView.builder(
                  physics: ScrollPhysics(),
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: instance.currentChat.length,
                  itemBuilder: (context, index) {
                    final msg =
                        instance.currentChat[instance.currentChat.length -
                            1 -
                            index];
                    return ChatBubble(
                      message: msg.message,
                      messageFrom: msg.from,
                      currentUsername: widget.username!,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 35),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Consumer<ChatPageModel>(
                    builder: (context, instance, child) {
                      return IconButton(
                        onPressed:
                            instance.typingStatus
                                ? () async {

                                  await sendMessage();

                                  if (!context.mounted) return;

                                  context.read<ChatPageModel>().addMessage(
                                    _controller,
                                  );

                                }
                                : () => {},
                        icon: Icon(
                          Icons.send,
                          color:
                              instance.typingStatus
                                  ? Colors.white
                                  : Colors.grey[800],
                        ),
                      );
                    },
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

class ChatBubble extends StatelessWidget {
  final String message;
  final String messageFrom;
  final String currentUsername;

  const ChatBubble({
    required this.message,
    required this.messageFrom,
    required this.currentUsername,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          messageFrom != currentUsername
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:
              messageFrom != currentUsername
                  ? const Color(0xFFDCF8C6)
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(
              messageFrom != currentUsername ? 12 : 0,
            ),
            bottomRight: Radius.circular(
              messageFrom != currentUsername ? 0 : 12,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Text(message, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
