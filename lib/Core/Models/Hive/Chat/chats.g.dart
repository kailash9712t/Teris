// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatsPageDataAdapter extends TypeAdapter<ChatsPageData> {
  @override
  final int typeId = 2;

  @override
  ChatsPageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatsPageData(
      username: fields[0] as String,
      displayName: fields[1] as String,
      message: fields[2] as String,
      timeStamp: fields[3] as String,
      profilePhotoUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatsPageData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.timeStamp)
      ..writeByte(4)
      ..write(obj.profilePhotoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatsPageDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatsDataAdapter extends TypeAdapter<ChatsData> {
  @override
  final int typeId = 3;

  @override
  ChatsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatsData(
      from: fields[1] as String,
      message: fields[2] as String,
      messageId: fields[3] as String,
      seen: fields[5] as int?,
      timeStamp: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatsData obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.messageId)
      ..writeByte(4)
      ..write(obj.timeStamp)
      ..writeByte(5)
      ..write(obj.seen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
