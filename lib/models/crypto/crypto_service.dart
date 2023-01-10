import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';


class CryptoService {

  static generatePairAndSave() async {

    final helper = RsaKeyHelper();
    final keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());

    final privateKey = keyPair.privateKey as RSAPrivateKey;
    final publicKey = keyPair.publicKey as RSAPublicKey;

    final privateKeyAsString = helper.encodePrivateKeyToPemPKCS1(privateKey);
    final publicKeyAsString = helper.encodePublicKeyToPemPKCS1(publicKey);
    HiveRsaPair.saveMyKeyPair(privateKeyAsString, publicKeyAsString);

    return privateKey;
  }

  static isKeyCurrent(String publicKey) async {
    final publicKey = await HiveRsaPair.getMyPublicKey();

  }




}
