
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Services/socket.dart';

class ChatPageModel extends ChangeNotifier {
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));
  bool typingStatus = false;

  void addMessage(TextEditingController controller) {
    final text = controller.text.trim();

    if (text.isNotEmpty) {
      notifyListeners();
      controller.clear();
    }
  }

  Future<void> sendMessage(
    Map<String, dynamic> chat,
    BuildContext context,
  ) async {
    logs.i("socket send message to server");

    context.read<SocketOperation>().socket?.emit("RealTimeChat", chat);
  }

  void startTyping(TextEditingController controller) {
    if (controller.text.isNotEmpty)
      typingStatus = true;
    else
      typingStatus = false;
    notifyListeners();
  }
}
