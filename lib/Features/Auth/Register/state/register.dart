import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Core/Models/Hive/Register/register.dart';
import 'package:http/http.dart' as http;
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/firebase_operations.dart';   
import 'package:tetris/Core/Services/logger.dart';

enum Fields { username, email, mobileNumber }

enum FieldsStatus { notStart, start, valid, invalid }

class RegisterPageModel extends ChangeNotifier {
  bool showPassword = false;
  bool registerStatus = false;
  final String currentFileName = "register.dart";
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));

  Map<Fields, FieldsStatus> showStatus = {
    Fields.username: FieldsStatus.notStart,
    Fields.email: FieldsStatus.notStart,
    Fields.mobileNumber: FieldsStatus.notStart,
  };

  Future<bool> register(
    GlobalKey<FormState> formKey,
    BuildContext context,
    UserMetaData instance,
  ) async {
    registerStatus = true;
    notifyListeners();

    try {
      if (formKey.currentState!.validate()) {
        if (context.mounted &&
            showStatus[Fields.username] == FieldsStatus.valid &&
            showStatus[Fields.email] == FieldsStatus.valid &&
            showStatus[Fields.mobileNumber] == FieldsStatus.valid) {
          Provider.of<FirebaseOperation>(
            context,
            listen: false,
          ).signUp(instance.email, instance.password!, context);
          await registerCall(
            instance.username,
            instance.email,
            instance.mobileNumber,
            instance.password!,
          );
          storePhaseOneData(instance);

          registerStatus = false;
          notifyListeners();

          return true;
        }
      }
    } catch (error) {
      logs.w("Error : - $error");
    }

    registerStatus = false;
    notifyListeners();

    return false;
  }

  void showIcon() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void storePhaseOneData(UserMetaData instance) async {
    UserDataProvider().loadDataManually(instance);
    UserDataProvider().updateData();

    logs.i('Data Store!');
  }

  Future<void> databaseInExists(String key, String value) async {
    if (key == "username") {
      showStatus[Fields.username] = FieldsStatus.start;
    } else if (key == "mobileNumber") {
      showStatus[Fields.mobileNumber] = FieldsStatus.start;
    } else {
      showStatus[Fields.email] = FieldsStatus.start;
    }

    notifyListeners();

    try {
      String baseUrl = "${Config.baseUrl}/checkFields";
      Uri parseUrl = Uri.parse(baseUrl);

      Map<String, String> body = {"key": key, "value": value};

      http.Response response = await http.post(
        parseUrl,
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        if (key == "username") {
          showStatus[Fields.username] = FieldsStatus.valid;
        } else if (key == "mobileNumber") {
          showStatus[Fields.mobileNumber] = FieldsStatus.valid;
        } else {
          showStatus[Fields.email] = FieldsStatus.valid;
        }
      } else {
        if (key == "username") {
          showStatus[Fields.username] = FieldsStatus.invalid;
        } else if (key == "mobileNumber") {
          showStatus[Fields.mobileNumber] = FieldsStatus.invalid;
        } else {
          showStatus[Fields.email] = FieldsStatus.invalid;
        }
      }
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "databaseInExists");
    }

    notifyListeners();
  }

  Future<void> registerCall(
    String username,
    String email,
    String mobileNumber,
    String password,
  ) async {
    try {
      String baseUrl = "${Config.baseUrl}/Register";
      Uri parseUrl = Uri.parse(baseUrl);

      final body = {
        "Username": username,
        "Email": email,
        "MobileNumber": mobileNumber,
        "Password": password,
      };

      final response = await http.post(
        parseUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        logs.i("Register Process Complete");
        String tokens = response.body;
        storeTokens(tokens);
      } else {
        logs.i("Register Data Not Complete");
      }
    } catch (error) {
      logs.e("Error : - $error");
    }
  }

  Future<void> storeTokens(String tokens) async {
    Map<String, dynamic> mapTokens = jsonDecode(tokens);

    FlutterSecureStorage instance = FlutterSecureStorage();

    await instance.write(key: "accessToken", value: mapTokens["accessToken"]);
    await instance.write(key: "refreshToken", value: mapTokens["refreshToken"]);
  }
}
