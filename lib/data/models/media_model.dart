class MediaModel {
  String? sid;
  String? title;
  String? thumbnail;
  String? source;
  bool? error;
  List<Medias>? medias;

  MediaModel({
    this.sid,
    this.title,
    this.thumbnail,
    this.source,
    this.error,
    this.medias,
  });

  MediaModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: converting potential ints/doubles to String
    sid = json['sid']?.toString();
    title = json['title']?.toString();
    thumbnail = json['thumbnail']?.toString();
    source = json['source']?.toString();
    error = json['error'] == true; // Ensure boolean check

    if (json['medias'] != null) {
      medias = <Medias>[];
      json['medias'].forEach((v) {
        medias!.add(Medias.fromJson(v));
      });
    }
  }
}

class Medias {
  String? url;
  String? quality;
  String? extension;
  String? formattedSize;
  bool? videoAvailable;
  bool? audioAvailable;

  Medias({
    this.url,
    this.quality,
    this.extension,
    this.formattedSize,
    this.videoAvailable,
    this.audioAvailable,
  });

  Medias.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    quality = json['quality']?.toString();
    extension = json['extension']?.toString();
    formattedSize = json['formattedSize']?.toString();

    // Casting to bool safely
    videoAvailable = json['videoAvailable'] == true;
    audioAvailable = json['audioAvailable'] == true;
  }
}
