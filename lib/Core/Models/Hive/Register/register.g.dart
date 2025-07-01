// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserMetaDataAdapter extends TypeAdapter<UserMetaData> {
  @override
  final int typeId = 0;

  @override
  UserMetaData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMetaData(
      username: fields[0] as String,
      password: fields[1] as String?,
      email: fields[2] as String,
      displayName: fields[3] as String?,
      bio: fields[4] as String?,
      authProvider: (fields[5] as Map?)?.cast<String, bool>(),
      mobileNumber: fields[6] as String,
      profilePhotoUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserMetaData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.authProvider)
      ..writeByte(6)
      ..write(obj.mobileNumber)
      ..writeByte(7)
      ..write(obj.profilePhotoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetaDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
