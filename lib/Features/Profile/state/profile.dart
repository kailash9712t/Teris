// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Core/Models/Hive/Register/register.dart';
import 'package:http/http.dart' as http;
import 'package:tetris/Core/Models/DTO/basic_user_data.dart';
import 'package:tetris/Core/Services/logger.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';

class ProfilePageModel extends ChangeNotifier {
  String? path;
  XFile? file;
  ImagePicker picker = ImagePicker();
  bool statusBio = false;
  String userBoxName = LocalData.userDataboxName;
  String currentFileName = "profile.dart";

  final Logger logs = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );

  void selectImage() async {
    file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      path = file!.path;
      notifyListeners();
    }
  }

  Future<bool> completeProfile(
    String displayName,
    String bio,
    String currentUsername,
  ) async {
    statusBio = true;
    notifyListeners();

    String baseUrl = "${Config.baseUrl}/CompleteProfile";
    Uri parseUrl = Uri.parse(baseUrl);

    http.MultipartRequest request = http.MultipartRequest("POST", parseUrl);

    request.fields["displayName"] = displayName;
    request.fields["bio"] = bio;
    request.fields["username"] = currentUsername;

    if (file != null) {
      final fileData = await file!.readAsBytes();

      final fileRequest = http.MultipartFile.fromBytes(
        "file",
        fileData,
        filename: 'check',
      );

      request.files.add(fileRequest);
    }

    final rawData = await request.send();
    final rawResponse = await http.Response.fromStream(rawData);

    if (rawResponse.statusCode == 200) {
      await storeCurrentUserData(bio, displayName);
      await updateData(rawResponse.body);
      await storeCurrentUserName();
      return true;
    }

    statusBio = false;
    notifyListeners();

    return false;
  }

  Future<void> storeCurrentUserName() async {
    try {
      String boxName = "newBox";
      String username = UserDataProvider().basicUserData.username;

      Box box =
          Hive.isBoxOpen(boxName)
              ? Hive.box(boxName)
              : await Hive.openBox(boxName);

      await box.put("UserName",username);
      
    } catch (error) {
      ErrorLogs.logError(
        currentFileName,
        error.toString(),
        "storeCurrentUserName",
      );
    }
  }

  Future<void> storeCurrentUserData(String bio, String displayName) async {
    BasicUserData instance1 = UserDataProvider().basicUserData;

    UserMetaData userMetaData = UserMetaData(
      username: instance1.username,
      email: instance1.email,
      mobileNumber: instance1.mobileNumber,
      displayName: displayName,
      bio: bio,
      profilePhotoUrl: instance1.photoUrl,
    );

    UserDataProvider().loadDataManually(userMetaData);
    await UserDataProvider().updateData();

    logs.i("this is global data");

    logs.i(UserDataProvider().basicUserData.username);
    logs.i(UserDataProvider().basicUserData.email);
    logs.i(UserDataProvider().basicUserData.mobileNumber);
    logs.i(UserDataProvider().basicUserData.bio);
    logs.i(UserDataProvider().basicUserData.displayName);
    logs.i(UserDataProvider().basicUserData.email);

    logs.i("this is global data where end");
  }

  Future<void> updateData(String data) async {
    final token = jsonDecode(data);

    UserDataProvider().basicUserData.photoUrl = token['photoUrl'];

    await UserDataProvider().updateData();

    logs.i("Token image url : - ${token["photoUrl"]}");

    await checkData();
  }

  Future<void> checkData() async {
    logs.i("check data start");

    Box box =
        Hive.isBoxOpen(LocalData.userDataboxName)
            ? Hive.box<UserMetaData>(LocalData.userDataboxName)
            : await Hive.openBox<UserMetaData>(LocalData.userDataboxName);

    UserMetaData? instance = await box.get("userMetaData");

    if (instance != null) {
      logs.i(instance.username);
      logs.i(instance.bio);
      logs.i(instance.displayName);
      logs.i(instance.profilePhotoUrl);
    } else {
      logs.i("check data instance is null");
    }
  }
}
