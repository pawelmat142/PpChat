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

      function isSender() {	return request.resource.data.documentId == request.auth.uid; }

      function isContact(contactUid) { return request.auth.uid in getContactsUids(contactUid); }

			allow create: if request.auth.uid == request.resource.data.uid;
      allow read: if logged();
      allow delete, update: if isOwner();


      match /CONTACTS/{UID} {
        allow read, write: if UID == request.auth.uid;
      }


      match /NOTIFICATIONS/{docId} {
      	allow read, write: if isOwner();
        allow create: if logged(); //send invitation
        allow update, delete: if isSender(); //accept, delete invitation, overwrite any notification
      }


      match /Messages/{messageDocId} {
      	allow read, write: if isOwner();
        allow create, delete: if isContact(UID);
      }


    }


  }
}