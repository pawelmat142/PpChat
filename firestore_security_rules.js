rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

  	match /logs/{logs} {
    	allow create: if true;
    }

  	function logged() { return request.auth != null; }

    function getContactsUids(contactUid) { return
    	get(/databases/$(database)/documents/PpUser/$(contactUid)/CONTACTS/$(contactUid))
        .data.contactUids;
    }

  	match /PpUser/{UID} {

    	function isOwner() { return UID == request.auth.uid; }

      function isSender() { return
      	request.auth.uid == resource.data.documentId
            || request.auth.uid == request.data.documentId
            || request.auth.uid == request.resource.data.documentId;
      }

      function isContact(contactUid) { return request.auth.uid in getContactsUids(contactUid); }

      function isInvitationAccepted(contactUid) {
      	return get(/databases/$(database)/documents/PpUser/$(contactUid)/NOTIFICATIONS/$(request.auth.uid))
        	.data.type == "invitationAcceptance";
      }

      allow create: if request.auth.uid == request.resource.data.uid;
      allow read: if logged();
      allow delete, update: if isOwner();


      match /CONTACTS/{UID} {
        allow read, write: if UID == request.auth.uid;
      }


      match /NOTIFICATIONS/{docId} {
      	allow read, write: if isOwner() || isSender();
      }


      match /Messages/{messageDocId} {
      	allow read, write: if isOwner() || isContact(UID) || isInvitationAccepted(UID);
      }

    }

    match /DELETED_ACCOUNTS/{nickname} {
    	allow write: if true;
    }

  }
}