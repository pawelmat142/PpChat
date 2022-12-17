rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

  	match /logs/{logs} {
    	allow create: if true;
    }

  	function logged() { return request.auth != null; }

  	match /PpUser/{nickname} {

      function owner() {
      	return get(/databases/$(database)/documents/PpUser/$(nickname)/PRIVATE/$(nickname)).data.uid == request.auth.uid;
      }

      allow create: if logged();
      allow read, write: if logged();
      // TODO: ifisincontacts rule
      allow update, delete: if owner();

      match /PRIVATE/{nickname} {
      	allow create: if request.resource.data.uid == request.auth.uid;
        allow delete: if resource.data.uid == request.auth.uid;
        allow write: if request.resource.data.uid == request.auth.uid;
      }

      match /NOTIFICATIONS/{nickname} {
      // TODO: some more rules to lock notifications only for sender/receiver
      	allow read, write: if logged();
      }

      match /CONTACTS/{nickname} {
        allow write, read: if owner();
      }

      match /Messages/{msgDocId} {
       //TODO: make some rules to lock messages only for receiver and allow send for senders
        allow write, read: if logged();
      }
    }


    match /DELETED_ACCOUNTS/{nickname} {
    	allow create: if request.resource.data.uid == request.auth.uid
    }

  }
}