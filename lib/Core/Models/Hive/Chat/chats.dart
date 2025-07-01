import 'package:hive/hive.dart';

part 'chats.g.dart';

@HiveType(typeId: 2)
class ChatsPageData extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String displayName;

  @HiveField(2)
  String message;

  @HiveField(3)
  String timeStamp;

  @HiveField(4)
  String? profilePhotoUrl;

  ChatsPageData({
    required this.username,
    required this.displayName,
    required this.message,
    required this.timeStamp,
    this.profilePhotoUrl,
  });
}

@HiveType(typeId: 3)
class ChatsData {
  @HiveField(1)
  String from;

  @HiveField(2)
  String message;

  @HiveField(3)
  String messageId;

  @HiveField(4)
  String timeStamp;

  @HiveField(5)
  int? seen;

  ChatsData({required this.from,required this.message, required this.messageId, required this.seen, required this.timeStamp});
}
