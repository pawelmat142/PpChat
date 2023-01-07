
class AvatarModel {
  String color;
  String txt;
  String imageUrl;

  AvatarModel({
    required this.color,
    required this.txt,
    required this.imageUrl,
  });

  bool get hasImage => imageUrl != '';

  get asMap => {
    AvatarModelFields.color: color,
    AvatarModelFields.txt: txt,
    AvatarModelFields.imageUrl: imageUrl
  };

  static AvatarModel fromMap(Map<String, dynamic> avatarMap) {
    AvatarModelFields.validate(avatarMap);
    return AvatarModel(
      color: avatarMap[AvatarModelFields.color],
      txt: avatarMap[AvatarModelFields.txt],
      imageUrl: avatarMap[AvatarModelFields.imageUrl],
    );
  }

  static AvatarModel copy(AvatarModel input) {
    return AvatarModel(
        color: input.color,
        txt: input.txt,
        imageUrl: input.imageUrl
    );
  }

}

abstract class AvatarModelFields {
  static const String color = 'color';
  static const String txt = 'txt';
  static const String imageUrl = 'imageUrl';

  static validate(Map<String, dynamic>? avatarMap) {
    if (
        avatarMap!.keys.contains(color)
        && avatarMap[color] is String

        && avatarMap.keys.contains(txt)
        && avatarMap[txt] is String

        && avatarMap.keys.contains(imageUrl)
        && avatarMap[imageUrl] is String

    ) {return;} else {
      throw Exception(["PpUser MAP ERROR"]);
    }
  }

}