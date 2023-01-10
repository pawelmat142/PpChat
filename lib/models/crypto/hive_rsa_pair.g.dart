// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_rsa_pair.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveRsaPairAdapter extends TypeAdapter<HiveRsaPair> {
  @override
  final int typeId = 3;

  @override
  HiveRsaPair read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveRsaPair(
      privateAsString: fields[0] as String,
      publicAsString: fields[1] as String,
      uid: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveRsaPair obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.privateAsString)
      ..writeByte(1)
      ..write(obj.publicAsString)
      ..writeByte(2)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveRsaPairAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
