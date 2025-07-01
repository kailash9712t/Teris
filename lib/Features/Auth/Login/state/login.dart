import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:http/http.dart' as http;
import 'package:tetris/Core/Models/Hive/Register/register.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Widgets/custom_widget.dart';
import 'package:tetris/Core/Services/firebase_operations.dart';
import 'package:tetris/Core/Services/logger.dart';
import 'package:tetris/Core/Services/socket.dart';

enum Field { loginStatus }

enum FieldStatus { notStart, start, notValid, valid, emailNotVerify }

class LoginPageModel extends ChangeNotifier {
  bool _obscurePassword = true;

  Map<Field, FieldStatus> status = {Field.loginStatus: FieldStatus.notStart};

  bool get obscurePassword => _obscurePassword;

  final Logger logs = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );
  String currentFileName = "login.dart";

  void iconTap() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> loginButtonClicked(
    GlobalKey<FormState> formKey,
    BuildContext context,
    String email,
    String password,
  ) async {
    if (!formKey.currentState!.validate()) {
      logs.e("Form state invalid");
      return;
    }

    status[Field.loginStatus] = FieldStatus.start;
    notifyListeners();

    logs.i("Form state valid");

    try {
      String? response = await loginRequest(email, password);

      if (response == null) {
        TextButton button = TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text("Ok"),
        );

        if (!context.mounted) return;

        customPopUp(
          context,
          "Invalid Credintials",
          "enter valid email or password",
          button,
        );
        status[Field.loginStatus] = FieldStatus.notValid;
        notifyListeners();
        return;
      }

      logs.i("response got");

      await storeTokens(response);

      logs.i("token store");

      if (!context.mounted) return;

      await context.read<FirebaseOperation>().signIn(email, password);

      logs.i("Sign done");

      User? user = FirebaseAuth.instance.currentUser;

      logs.i("Current User $user");

      if (user != null) {
        logs.i("user not null");

        if (context.mounted && user.emailVerified) {
          logs.i("email verifed");
          if (context.mounted) {
            logs.e("process start to connect to the socket");

            context.read<SocketOperation>().initialize();
          }
          context.go("/home");

          status[Field.loginStatus] = FieldStatus.valid;
        } else {
          logs.i("User Not Verify");

          TextButton button = TextButton(
            onPressed: () {
              context.read<FirebaseOperation>().verification(context);

              context.push("/email");
            },
            child: Text('Verify'),
          );

          if (!context.mounted) return;

          customPopUp(
            context,
            "Email Verification",
            "please verify your email.",
            button,
          );

          status[Field.loginStatus] = FieldStatus.emailNotVerify;
        }
      }
      notifyListeners();
    } catch (error) {
      ErrorLogs.logError(
        currentFileName,
        error.toString(),
        "loginButtonClicked",
      );
    }
  }

  Future<void> storeTokens(String tokens) async {
    try {
      final secureStorage = FlutterSecureStorage();
      final mapTokens = jsonDecode(tokens);
      await secureStorage.write(
        key: "accessToken",
        value: mapTokens["accessToken"],
      );
      await secureStorage.write(
        key: "refreshToken",
        value: mapTokens["refreshToken"],
      );
      await loadUserData(mapTokens);
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "storeTokens");
    }
  }

  Future<String?> loginRequest(String usernameOrEmail, String password) async {
    try {
      String baseUrl = "${Config.baseUrl}/Login";
      Map<String, String> body = {
        "EmailOrUsername": usernameOrEmail,
        "password": password,
      };
      Uri parseUrl = Uri.parse(baseUrl);
      http.Response response = await http.post(
        parseUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "loginRequest");
    }
    return null;
  }

  Future<void> loadUserData(Map<String, dynamic> data) async {
    try {
      UserMetaData instance = UserMetaData(
        username: data["username"],
        email: data["email"],
        mobileNumber: data["mobileNumber"].toString(),
        bio: data["bio"],
        displayName: data["displayName"],
        profilePhotoUrl: data["profilePhotoId"],
      );

      await storeCurrentUser(data["username"]);

      UserDataProvider().loadDataManually(instance);
      await UserDataProvider().updateData();
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "loadUserData");
    }
  }

  Future<void> storeCurrentUser(String username) async {
    try {
      String boxName = "newBox";
      Box box =
          Hive.isBoxOpen(boxName)
              ? Hive.box(boxName)
              : await Hive.openBox(boxName);

      await box.put("UserName", username);
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "storeCurrentUser");
    }
  }
}
