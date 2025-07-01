import 'package:hive/hive.dart';

part 'user_chat_model.g.dart';

@HiveType(typeId: 1)
class UserChatModel extends HiveObject {
  @HiveField(0)
  String profilePhotoUrl;

  @HiveField(1)
  String username;

  @HiveField(2)
  String displayName;

  @HiveField(3)
  String lastMessage;

  @HiveField(4)
  int? unreadMessage;

  @HiveField(5)
  String timeStamp;

  UserChatModel({
    this.unreadMessage,
    required this.profilePhotoUrl,
    required this.displayName,
    required this.lastMessage,
    required this.timeStamp,
    required this.username,
  });
}
