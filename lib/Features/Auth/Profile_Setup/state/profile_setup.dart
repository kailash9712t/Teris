import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Core/Models/Hive/Register/register.dart' show UserMetaData;
import 'package:http/http.dart' as http;
import 'package:tetris/Core/Models/DTO/basic_user_data.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/add_header.dart';
import 'package:tetris/Core/Services/logger.dart';

class ProfileBioPageModel extends ChangeNotifier {
  String? path;
  XFile? file;
  ImagePicker picker = ImagePicker();
  UserMetaData? userMetaData;
  bool muteSwitch = false;
  bool bioEditStatus = false;
  bool usernameEditStatus = false;
  String boxName = LocalData.userDataboxName;

  final Logger logs = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );

  Future<void> updateImage(BuildContext context) async {

    try {
      logs.i("update Image start");
      final baseUrl = "${Config.baseUrl}/uplaodImage";
      Uri parseUrl = Uri.parse(baseUrl);

      http.MultipartRequest request = http.MultipartRequest("POST", parseUrl);

      if (file != null) {
        final bytes = await file!.readAsBytes();
        final fileRequest = http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: "check",
        );
        request.files.add(fileRequest);
      }


      if (userMetaData != null) {
        request.fields["username1"] = userMetaData!.username;
        request.fields["key"] = "profilePhotoId";
      }


      final response = await request.send();


      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        final data = jsonDecode(responseBody.body);
        userMetaData?.profilePhotoUrl = data["photoId"];
        notifyListeners();

        UserDataProvider().basicUserData.photoUrl = data["photoId"];
        await UserDataProvider().updateData();
      } else {
        if (!context.mounted) return;
        showMessage(context);
      }
    } catch (error) {
      if (!context.mounted) return;
      showMessage(context);
      ErrorLogs.logError("profile_bio.dart", error.toString(), "updateImage");
    }
  }

  void updateData(String key, String value, BuildContext context) async {
    try {
      final baseUrl = "${Config.baseUrl}/updateData";
      Uri parseUrl = Uri.parse(baseUrl);

      final data = {
        "username1": userMetaData?.username,
        "key": key,
        "value": value,
      };

      final header = await RequestOperation.getHeader();

      final response = await http.post(
        parseUrl,
        headers: header,
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        if (!context.mounted) return;
        showMessage(context);
      }
    } catch (error) {
      if (!context.mounted) return;
      showMessage(context);
      ErrorLogs.logError("profile_bio.dart", error.toString(), "updateData");
    }
  }

  void bioEdit() {
    bioEditStatus = !bioEditStatus;
    notifyListeners();
    if (!bioEditStatus) {
      UserDataProvider().updateData();
    }
  }

  void usernameEdit() async {
    usernameEditStatus = !usernameEditStatus;
    notifyListeners();
    if (!usernameEditStatus) {
      await UserDataProvider().updateData();
    }
  }

  void switchTap(bool value) {
    muteSwitch = value;
    notifyListeners();
  }

  void selectImage(BuildContext context) async {
    file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      path = file!.path;
      notifyListeners();
      if (!context.mounted) return;
      updateImage(context);
    }
  }

  void fetchUserData() async {
    BasicUserData instance = UserDataProvider().basicUserData;

    userMetaData = UserMetaData(
      username: instance.username,
      email: instance.email,
      mobileNumber: instance.mobileNumber,
      profilePhotoUrl: instance.photoUrl,
      bio: instance.bio,
      displayName: instance.displayName,
    );

    notifyListeners();
  }

  void showMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Failed Request")));
  }
}
