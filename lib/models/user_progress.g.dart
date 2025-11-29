// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      totalStudyTime: fields[0] as int,
      currentStreak: fields[1] as int,
      longestStreak: fields[2] as int,
      lastStudyDate: fields[3] as DateTime?,
      dailyGoal: fields[4] as int,
      surahProgress: (fields[5] as Map?)?.cast<String, int>(),
      completedTajweedLessons: (fields[6] as List?)?.cast<String>(),
      memorizedVerses: (fields[7] as Map?)?.cast<String, int>(),
      bookmarkedVerses: (fields[8] as List?)?.cast<String>(),
      achievements: (fields[9] as List?)?.cast<Achievement>(),
      createdAt: fields[10] as DateTime?,
      dhikrCompletions: (fields[11] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.totalStudyTime)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.longestStreak)
      ..writeByte(3)
      ..write(obj.lastStudyDate)
      ..writeByte(4)
      ..write(obj.dailyGoal)
      ..writeByte(5)
      ..write(obj.surahProgress)
      ..writeByte(6)
      ..write(obj.completedTajweedLessons)
      ..writeByte(7)
      ..write(obj.memorizedVerses)
      ..writeByte(8)
      ..write(obj.bookmarkedVerses)
      ..writeByte(9)
      ..write(obj.achievements)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.dhikrCompletions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 1;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      iconName: fields[3] as String,
      unlockedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.unlockedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
