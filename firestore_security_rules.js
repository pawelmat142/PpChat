rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

  	match /logs/{logs} {
    	allow create: if true;
    }

  	function logged() { return request.auth != null; }

  	match /PpUser/{UID} {

    	function isOwner() {
      	return UID == request.auth.uid;
      }

      function isSender() {
      	return request.resource.data.documentId == request.auth.uid && logged();
      }

      function isContact() {
      // TODO: update
      	return true;
      }


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

      match /Messages/{msgDocId} {
      	allow read, write: if isOwner();
        allow create, delete: if isSender();
       //TODO: make some rules to lock messages only for receiver and allow send for senders
      }
    }


    match /DELETED_ACCOUNTS/{nickname} {
    	allow create: if request.resource.data.uid == request.auth.uid
    }

  }
}