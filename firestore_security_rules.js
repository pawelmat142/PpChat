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

      function isContact() {
      // TODO: update
      	return true;
      }

      function isSender() {
      	// TODO: update
        return true;
      }

      function owner() {
      	return get(/databases/$(database)/documents/PpUser/$(nickname)/PRIVATE/$(nickname)).data.uid == request.auth.uid;
      }

			allow create: if request.auth.uid == request.resource.data.uid;
      allow read: if logged();
      allow delete, update: if isOwner();

      match /CONTACTS/{UID} {
        allow write, read: if isOwner();
      }

      match /NOTIFICATIONS/{docId} {
      	allow read, write: if isOwner();
        allow create, delete: if isSender();
      // TODO: some more rules to lock notifications only for sender/receiver
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