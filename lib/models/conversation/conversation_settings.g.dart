// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationSettingsAdapter extends TypeAdapter<ConversationSettings> {
  @override
  final int typeId = 1;

  @override
  ConversationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationSettings(
      contactUid: fields[0] as String,
      timeToLiveInMinutes: fields[1] as int,
      timeToLiveAfterReadInMinutes: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.contactUid)
      ..writeByte(1)
      ..write(obj.timeToLiveInMinutes)
      ..writeByte(2)
      ..write(obj.timeToLiveAfterReadInMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
