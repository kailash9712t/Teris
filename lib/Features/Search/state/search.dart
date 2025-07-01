import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:http/http.dart' as http;
import 'package:tetris/Core/Models/DTO/search.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/add_header.dart';

class SearchPageModel extends ChangeNotifier {
  List<Map<String, dynamic>> localUsers = [];
  List<FetchedContactModel> resultUsers = [];
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));

  Future<void> backCall(String searchQuery) async {
    try {
      final baseUrl = "${Config.baseUrl}/FetchContact";
      Uri parseUrl = Uri.parse(baseUrl);

      String adminUsername = UserDataProvider().basicUserData.username;

      logs.e("current username : - $adminUsername");

      final data = {
        "searchQuery": searchQuery,
        "ListOfUsers": localUsers,
        "adminUsername": adminUsername,
      };

      final getHeader = await RequestOperation.getHeader();
      final response = await http.post(
        parseUrl,
        headers: getHeader,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        mapToList(jsonDecode(response.body));
        logs.i(response.body);
      } else {
        logs.w("Failed");
      }
    } catch (error) {
      logs.w("Error at search : - $error");
    }
  }

  void mapToList(List users) {
    for (List data in users) {
      final user = data[1];
      FetchedContactModel model = FetchedContactModel(
        mobileNumber: user["mobileNumber"],
        profilePhotoId: user["profilePhotoId"],
        displayName: user["displayName"],
        username: user["username"],
      );
      resultUsers.add(model);
    }
    notifyListeners();
  }

  Future<void> fetchContect(String searchQuery) async {
    localUsers.clear();
    resultUsers.clear();

    PermissionStatus status = await Permission.contacts.status;

    if (status.isDenied) {
      await FlutterContacts.requestPermission();
    }
    status = await Permission.contacts.status;
    if (status.isGranted) {
      logs.i("Permission granted");
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      for (Contact data in contacts) {
        if (data.displayName.contains(searchQuery)) {
          logs.i(data.displayName);
          localUsers.add({
            "mobileNumber": int.parse(data.phones[0].number.split(" ")[1]),
          });
        }
      }
    } else {
      logs.i("permission not granted");
    }

    logs.i(localUsers);

    backCall(searchQuery);
  }
}
