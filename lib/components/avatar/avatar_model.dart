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
}