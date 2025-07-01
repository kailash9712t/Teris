import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/logger.dart';
import 'package:tetris/Core/Services/socket.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final Logger logs = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );

  String currentFileName = "loading.dart";

  @override
  void initState() {
    logs.i("App initialization");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _intializeApp();
    });
    super.initState();
  }

  void _intializeApp() async {
    try {
      FlutterSecureStorage storage = FlutterSecureStorage();
      bool hasTokens = await storage.containsKey(key: "accessToken");
      bool isUserValid = await verifyAuthThroughFirebase();

      if (hasTokens && isUserValid) {
        await UserDataProvider().loadDataThroughStorage();

        if (!mounted) return;

        context.read<SocketOperation>().initialize();

        logs.i("go to home activity");

        await loadUserData();

        if (!mounted) return;
        context.go("/home");
      } else {
        logs.i("go to login activity");

        if (!mounted) return;
        context.go("/login");
      }
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "_intializeApp");
      if (mounted) {
        context.go("/login");
      }
    }
  }

  Future<bool> verifyAuthThroughFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        logs.i("User Not Present");
        return false;
      }
      logs.i("User Present : - $user");
      return user.emailVerified;
    } catch (error) {
      ErrorLogs.logError(
        "loading.dart",
        error.toString(),
        "verifyAuthThroughFirebase",
      );
    }
    return false;
  }

  Future<String?> fetchUsername() async {
    try {
      String boxName = "newBox";
      Box box =
          Hive.isBoxOpen(boxName)
              ? Hive.box(boxName)
              : await Hive.openBox(boxName);

      String username = await box.get("UserName");
      logs.i("login username : - $username");
      return username;
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "fetchUsername");
    }
    return null;
  }

  Future<void> loadUserData() async {
    try {
      String? username = await fetchUsername();
      if (username == null) return;
      UserDataProvider().basicUserData.username = username;
      await UserDataProvider().loadDataThroughStorage();
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "loadUserData");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("this is loading page")));
  }
}
