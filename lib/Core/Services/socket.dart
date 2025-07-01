
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';

class SocketOperation extends ChangeNotifier {
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));
  io.Socket? socket;
  
  void initialize() {
    logs.i("Socket Connected ${socket?.connected}");

    socket = io.io(Config.socketBaseUrl, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": "false",
    });

    socket?.onConnect((_) {
      logs.i("user Connect with socket");
      listen();
    });

    socket?.onError((error) {
      logs.i("Socket Error : - ${error.toString()}");
    });
    socket?.onDisconnect((_) async {
      logs.i("user disconnect with socket");
    });
  }

  void listen() {
    socket?.on("ClientID", (data) async {
      String? username = UserDataProvider().basicUserData.username;

      logs.i("Current Username : - $username");

      final object = {"username": username, "clientId": data};

      socket?.emit("newUsername", object);
    });

    socket?.on("NewMessage", (data) async {
      logs.i(data);
      logs.i(data.runtimeType);
    });
  }
}
