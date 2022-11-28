// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pp_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PpMessageAdapter extends TypeAdapter<PpMessage> {
  @override
  final int typeId = 0;

  @override
  PpMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PpMessage(
      sender: fields[0] as String,
      receiver: fields[1] as String,
      message: fields[2] as String,
      timestamp: fields[3] as DateTime,
      timeToLive: fields[4] as int,
      isRead: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PpMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sender)
      ..writeByte(1)
      ..write(obj.receiver)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.timeToLive)
      ..writeByte(5)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PpMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
