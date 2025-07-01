import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Core/Models/Hive/Register/register.dart';
import 'package:tetris/Core/Models/DTO/basic_user_data.dart';
import 'package:tetris/Core/Services/logger.dart';

class UserDataProvider {
  String fileName = "user_data_provider.dart";

  static final UserDataProvider instance = UserDataProvider.internal();
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));

  UserDataProvider.internal() {
    logs.i("Private constructor called");
  }

  factory UserDataProvider() => instance;

  BasicUserData basicUserData = BasicUserData();
  String userboxName = LocalData.userDataboxName;

  void loadDataManually(UserMetaData data) {
    basicUserData.username = data.username;
    basicUserData.mobileNumber = data.mobileNumber;
    basicUserData.email = data.email;

    basicUserData.photoUrl = data.profilePhotoUrl;
    basicUserData.bio = data.bio;
    basicUserData.displayName = data.displayName;
  }

  Future<void> loadDataThroughStorage() async {
    updateBoxFromUsername();

    logs.i("loadData through storage call");
    try {
      Box box =
          Hive.isBoxOpen(userboxName)
              ? Hive.box<UserMetaData>(userboxName)
              : await Hive.openBox<UserMetaData>(userboxName);

      UserMetaData? userMetaData = await box.get("userMetaData");

      if (userMetaData != null) {
        loadDataManually(userMetaData);
      } else {
        logs.e("No data present in local storage");
      }
    } catch (error) {
      ErrorLogs.logError(fileName, error.toString(), "loadData");
    }
  }

  Future<void> updateData() async {
    updateBoxFromUsername();

    try {
      Box box =
          Hive.isBoxOpen(userboxName)
              ? Hive.box<UserMetaData>(userboxName)
              : await Hive.openBox<UserMetaData>(userboxName);

      UserMetaData instance = UserMetaData(
        username: basicUserData.username,
        email: basicUserData.email,
        mobileNumber: basicUserData.mobileNumber,
        profilePhotoUrl: basicUserData.photoUrl ?? "default.png",
        bio: basicUserData.bio ?? "hey i am using this app",
        displayName: basicUserData.displayName ?? "user",
      );

      await box.put("userMetaData", instance);
    } catch (error) {
      ErrorLogs.logError(fileName, error.toString(), "updateData");
    }
  }

  void clearData() async {
    Box box =
        Hive.isBoxOpen(userboxName)
            ? Hive.box(userboxName)
            : await Hive.openBox(userboxName);

    box.clear();
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
    userboxName = LocalData.userDataboxName;
    
  }
}
