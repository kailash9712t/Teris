import 'package:flutter/foundation.dart';

class BasicUserData extends ChangeNotifier{
  String username = '';
  String email = '';
  String mobileNumber = '';

  String? photoUrl;
  String? displayName;
  String? bio;
}
