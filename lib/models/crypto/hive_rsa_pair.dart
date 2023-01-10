import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

part 'hive_rsa_pair.g.dart';

@HiveType(typeId: 3)
class HiveRsaPair extends HiveObject {

  @HiveField(0)
  final String privateAsString;

  @HiveField(1)
  final String publicAsString;

  @HiveField(2)
  final String uid;

  HiveRsaPair({
    required this.privateAsString,
    required this.publicAsString,
    required this.uid,
  });

  static saveMyKeyPair(String privateKeyAsString, String publicKeyAsString) async {
    final box = await _openOrCreate();
    final uid = Uid.get!;
    final hivePair = HiveRsaPair(
        privateAsString: privateKeyAsString,
        publicAsString: publicKeyAsString,
        uid: uid
    );
    await box.put(uid, hivePair);
  }

  static Future<bool> isKeyCurrent(String otherPublicKeyAsString) async {
    final box = await _openOrCreate();
    final hiveRsaPair = box.get(Uid.get);
    return hiveRsaPair == null ? false :
      otherPublicKeyAsString == hiveRsaPair.publicAsString;
  }

  static Future<RSAPrivateKey?> getMyPrivateKey() async {
    final box = await _openOrCreate();
    final hiveRsaPair = box.get(Uid.get);
    return hiveRsaPair == null ? null :
    RsaKeyHelper().parsePrivateKeyFromPem(hiveRsaPair.privateAsString);
  }

  static Future<RSAPublicKey?> getMyPublicKey() async {
    final box = await _openOrCreate();
    final hiveRsaPair = box.get(Uid.get);
    return hiveRsaPair == null ? null :
    RsaKeyHelper().parsePublicKeyFromPem(hiveRsaPair.publicAsString);
  }

  static const String _privateKeysBoxKey = 'VcYhetyVYcMZngDxBih7CCSK2pG3';

  static Future<Box<HiveRsaPair>> _openOrCreate() async {
    return Hive.isBoxOpen(_privateKeysBoxKey)
        ? Hive.box<HiveRsaPair>(_privateKeysBoxKey)
        : await Hive.openBox<HiveRsaPair>(_privateKeysBoxKey);
  }

}