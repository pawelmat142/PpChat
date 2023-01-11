import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
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
    final isKeyCurrent = await HiveRsaPair.isKeyCurrent(get.publicKeyAsString);
    if (!isKeyCurrent) {
      final publicKeyAsString = await HiveRsaPair.generatePairAndSaveToHive();
      await _updateMyPublicKey(publicKeyAsString);
    }
    _myPrivateKey = (await HiveRsaPair.getMyPrivateKey())!;
  }

  _updateMyPublicKey(String publicKeyAsString) async {
    final conversationSettingsService = getIt.get<ConversationSettingsService>();
    final logService = getIt.get<LogService>();
    final deletedMessagesValue = await conversationSettingsService.deleteUnreadMessages();
    await set(get.copyWithNewPublicKey(publicKeyAsString));
    logService.log('$deletedMessagesValue messages deleted encrypted with old key');
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