import 'package:hive/hive.dart';

part 'register.g.dart';

@HiveType(typeId: 0)
class UserMetaData extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String? password;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? displayName;

  @HiveField(4)
  String? bio;

  @HiveField(5)
  Map<String, bool>? authProvider;

  @HiveField(6)
  String mobileNumber;

  @HiveField(7)
  String? profilePhotoUrl;

  UserMetaData({
    required this.username,
    this.password,
    required this.email,
    this.displayName = "user",
    this.bio = "hey i am using this app",
    this.authProvider,
    required this.mobileNumber,
    this.profilePhotoUrl = "default.png",
  });
}
