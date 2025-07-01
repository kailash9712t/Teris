// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserChatModelAdapter extends TypeAdapter<UserChatModel> {
  @override
  final int typeId = 1;

  @override
  UserChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserChatModel(
      unreadMessage: fields[4] as int?,
      profilePhotoUrl: fields[0] as String,
      displayName: fields[2] as String,
      lastMessage: fields[3] as String,
      timeStamp: fields[5] as String,
      username: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserChatModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.profilePhotoUrl)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.unreadMessage)
      ..writeByte(5)
      ..write(obj.timeStamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
