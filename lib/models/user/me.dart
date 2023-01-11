import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/interfaces/fs_document_model.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:provider/provider.dart';

class Me extends FsDocumentModel<PpUser> {

  static Me get reference => Provider.of<Me>(NavigationService.context, listen: false);
  
  String get getUid => Uid.get!;

  String get uid => get.uid;
  String get nickname => get.nickname;

  late RSAPrivateKey _myPrivateKey;
  RSAPrivateKey get myPrivateKey => _myPrivateKey;

  initPrivateKey() async {
  //  TODO: get from hive or create
    _myPrivateKey = (await HiveRsaPair.getMyPrivateKey())!;
  }

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => firestore
      .collection(Collections.PpUser).doc(getUid);

  @override
  Map<String, dynamic> get stateAsMap => get.asMap;

  @override
  PpUser stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpUser.fromDB(documentSnapshot);
  }

}