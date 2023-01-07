import 'package:hive_flutter/adapters.dart';

part 'avatar_hive_image.g.dart';

@HiveType(typeId: 2)
class AvatarHiveImage extends HiveObject {

  AvatarHiveImage({required this.uid, required this.imageUrl, required this.devicePath});

  @HiveField(0)
  String uid;

  @HiveField(1)
  String imageUrl;

  @HiveField(2)
  String devicePath;

  static const String avatarsBoxKey = 'avatars';

  Future<void> saveIt() async {
    final box = await _getOpenBox();
    await box.put(uid, this);
  }

  static Future<AvatarHiveImage?> getByUid({required String uid}) async {
    final box = await _getOpenBox();
    return box.get(uid);
  }


  static Future<Box<AvatarHiveImage>> _getOpenBox() async {
    if (await Hive.boxExists(avatarsBoxKey)) {
      if (Hive.isBoxOpen(avatarsBoxKey)) {
        return Hive.box<AvatarHiveImage>(avatarsBoxKey);
      }
    }
    return await Hive.openBox<AvatarHiveImage>(avatarsBoxKey);
  }

  static Future<bool> exists({required String uid}) async {
    final box = await _getOpenBox();
    return box.containsKey(uid);
  }

  static Future<void> deletePath({required String uid}) async {
    final box = await _getOpenBox();
    await box.delete(uid);
    box.compact();
  }

  static Future<void> cleanBox() async {
    final box = await _getOpenBox();
    await box.clear();
  }

}