// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadTaskModelAdapter extends TypeAdapter<DownloadTaskModel> {
  @override
  final int typeId = 1;

  @override
  DownloadTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadTaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      url: fields[3] as String,
      extension: fields[4] as String,
      videoQuality: fields[5] as String?,
      progress: fields[6] as double,
      status: fields[7] as DownloadStatus,
      savedPath: fields[8] as String,
      totalSize: fields[9] as String,
      downloadedSize: fields[10] as String,
      thumbnailPath: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadTaskModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.extension)
      ..writeByte(5)
      ..write(obj.videoQuality)
      ..writeByte(6)
      ..write(obj.progress)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.savedPath)
      ..writeByte(9)
      ..write(obj.totalSize)
      ..writeByte(10)
      ..write(obj.downloadedSize)
      ..writeByte(11)
      ..write(obj.thumbnailPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final int typeId = 0;

  @override
  DownloadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadStatus.pending;
      case 1:
        return DownloadStatus.downloading;
      case 2:
        return DownloadStatus.paused;
      case 3:
        return DownloadStatus.completed;
      case 4:
        return DownloadStatus.failed;
      default:
        return DownloadStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    switch (obj) {
      case DownloadStatus.pending:
        writer.writeByte(0);
        break;
      case DownloadStatus.downloading:
        writer.writeByte(1);
        break;
      case DownloadStatus.paused:
        writer.writeByte(2);
        break;
      case DownloadStatus.completed:
        writer.writeByte(3);
        break;
      case DownloadStatus.failed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
