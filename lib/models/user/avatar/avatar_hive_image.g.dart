// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_hive_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvatarHiveImageAdapter extends TypeAdapter<AvatarHiveImage> {
  @override
  final int typeId = 2;

  @override
  AvatarHiveImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AvatarHiveImage(
      uid: fields[0] as String,
      imageUrl: fields[1] as String,
      devicePath: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AvatarHiveImage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.devicePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarHiveImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
