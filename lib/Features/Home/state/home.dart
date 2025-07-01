import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Core/Models/Hive/Chat/chats.dart';
import 'package:tetris/Core/Models/Hive/Home/user_chat_model.dart';
import 'package:tetris/Core/Services/logger.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/add_header.dart';
import 'package:http/http.dart' as http;
import 'package:tetris/Core/Services/firebase_operations.dart';
import 'package:tetris/Core/Services/socket.dart';

class HomePageModel extends ChangeNotifier {
  Map<String, UserChatModel> listOfUsers = {};
  Map<String, Map<String, ChatsData>> listOfChats = {};
  String chatsOfUser = "";
  List<ChatsData> currentChat = [];

  String homeBoxName = LocalData.homePageBoxName;
  String currentFileName = "home.dart";

  final Logger logs = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );

  void resetState() {
    listOfUsers = {};
    listOfChats = {};
    chatsOfUser = "";
    currentChat = [];
  }

  void fetchData() async {
    logs.i("fetch data ${LocalData.homePageBoxName}");

    homeBoxName = LocalData.homePageBoxName;

    try {
      Box box =
          Hive.isBoxOpen(homeBoxName)
              ? Hive.box(homeBoxName)
              : await Hive.openBox(homeBoxName);
      final userData = await box.get("ListOfUser");
      final userChat = await box.get("ListOfChat");

      if (userData != null) {
        logs.i("data use through local storage");
        storeUserData(userData);
        notifyListeners();
      }
      if (userChat != null) {
        logs.w("i got user chat");
        storeUserChat(userChat);
        notifyListeners();
      } else {
        logs.w("their no chats");
      }
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "backCall");
    }
  }

  Future<String?> backCall(String username) async {
    try {
      String baseUrl = "${Config.baseUrl}/userMetaData";
      Uri parseUrl = Uri.parse(baseUrl);
      final requireData = {"displayName": 1, "profilePhotoId": 1, "_id": 0};
      final body = {"username": username, "requiredField": requireData};
      final header = await RequestOperation.getHeader();
      final response = await http.post(
        parseUrl,
        headers: header,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        logs.i("we got a response");
        return response.body;
      }
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "backCall");
    }
    return null;
  }

  void storeUserData(Map<dynamic, dynamic> instance) {
    instance.forEach((key, value) {
      listOfUsers[key] = value;
    });
  }

  void storeUserChat(Map<dynamic, dynamic> instance) {
    instance.forEach((key, value) {
      Map<String, ChatsData> innerChats = deepChatConvert(value);
      listOfChats[key] = innerChats;
    });
  }

  Map<String, ChatsData> deepChatConvert(Map<dynamic, dynamic> instance) {
    Map<String, ChatsData> innerChats = {};
    instance.forEach((key, value) {
      innerChats[key] = value;
    });

    return innerChats;
  }

  // home page

  void signOut(BuildContext context) {
    FirebaseOperation instance = FirebaseOperation();
    instance.signOut();
    removeTokens();
    context.read<SocketOperation>().socket?.dispose();
    resetState();
  }

  // home page

  void clearBox() async {
    UserDataProvider().clearData();

    Box homeBox =
        Hive.isBoxOpen(homeBoxName)
            ? Hive.box(homeBoxName)
            : await Hive.openBox(homeBoxName);

    await homeBox.clear();
  }

  // storage

  void removeTokens() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
  }

  // socket

  void listen(BuildContext context) {
    context.read<SocketOperation>().socket?.on("RealTimeChat", (data) {
      logs.i("Message received $data");
      handleSocketMessage(data);
    });
    context.read<SocketOperation>().socket?.on("penddingData", (data) async {
      logs.i("Socket pending data : - $data");
      logs.e(data.runtimeType);
      handlePendingMessages(data);

      final penddingMessageDelete = {
        "username": UserDataProvider().basicUserData.username,
      };

      context.read<SocketOperation>().socket?.emit(
        "penddingData",
        penddingMessageDelete,
      );
    });
  }

  // home page

  void handlePendingMessages(List<dynamic> data) async {
    for (int i = 0; i < data.length; i++) {
      logs.w(data[i]);
      await handleSocketMessage(data[i]);
    }
  }

  // home Page

  Future<void> handleSocketMessage(Map<String, dynamic> data) async {
    logs.i("user go to handler");
    logs.i("list not contains user");
    String? userData = await backCall(data["from"]);
    logs.i("Data fetchFrom backcall");
    Map<String, dynamic>? info;
    if (userData != null) info = jsonDecode(userData);
    UserChatModel instance = UserChatModel(
      displayName: info?["displayName"],
      lastMessage: data["message"],
      timeStamp: data["timeStamp"],
      username: data["from"],
      profilePhotoUrl: info?["profilePhotoId"],
      unreadMessage: 1,
    );

    ChatsData chatsData = ChatsData(
      from: instance.username,
      message: instance.lastMessage,
      messageId: data["messageId"],
      seen: instance.unreadMessage,
      timeStamp: instance.timeStamp,
    );
    await insertUser(instance.username, instance);
    await insertChat(instance.username, chatsData);
  }

  // insert chat

  Future<void> insertChat(String username, ChatsData chat) async {
    if (!listOfChats.containsKey(username)) {
      Map<String, ChatsData> newChat = {};
      newChat[chat.messageId] = chat;
      listOfChats[username] = newChat;
    } else {
      Map<String, ChatsData>? storedChats = listOfChats[username];
      storedChats?[chat.messageId] = chat;
      listOfChats[username] = storedChats!;
    }

    if (username == chatsOfUser) {
      currentChat.add(chat);
      notifyListeners();
    }

    try {
      Box box =
          Hive.isBoxOpen(homeBoxName)
              ? Hive.box(homeBoxName)
              : await Hive.openBox(homeBoxName);

      await box.put("ListOfChat", listOfChats);
      logs.i("new chat store");
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "insertChat");
    }
  }

  // handle Home Page

  Future<void> insertUser(String username, UserChatModel instance) async {
    try {
      if (listOfUsers.containsKey(username)) {
        listOfUsers.remove(username);
      }
      listOfUsers[username] = instance;
      notifyListeners();

      Box box =
          Hive.isBoxOpen(homeBoxName)
              ? Hive.box(homeBoxName)
              : await Hive.openBox(homeBoxName);

      await box.put("ListOfUser", listOfUsers);
      logs.i("new user not store");
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "insertUser");
    }
  }

  // handle chats

  void loadChats(String username) {
    chatsOfUser = username;
    Map<String, ChatsData>? temp = listOfChats[username];
    currentChat = convertIntoList(temp);
    logs.i(currentChat);
    notifyListeners();
  }

  // handle chats

  List<ChatsData> convertIntoList(Map<String, ChatsData>? chatsMap) {
    List<ChatsData> data = [];
    chatsMap?.entries.forEach((entry) {
      data.add(entry.value);
    });

    return data;
  }

  void updateBoxFromUsername() {
    List<String> splitHomeBox = LocalData.homePageBoxName.split(" ");
    List<String> splitUserBox = LocalData.userDataboxName.split(" ");
    if (splitHomeBox.length == 1) {
      LocalData.homePageBoxName =
          "${UserDataProvider().basicUserData.username} ${LocalData.homePageBoxName}";
      LocalData.userDataboxName =
          "${UserDataProvider().basicUserData.username} ${LocalData.userDataboxName}";
    } else {
      LocalData.homePageBoxName =
          "${UserDataProvider().basicUserData.username} ${splitHomeBox[1]}";
      LocalData.userDataboxName =
          "${UserDataProvider().basicUserData.username} ${splitUserBox[1]}";
    }

    homeBoxName = LocalData.homePageBoxName;
  }
}
