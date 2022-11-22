rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

  	function logged() { return request.auth != null; }

  	match /User/{nickname} {

      function owner() {
      	return get(/databases/$(database)/documents/User/$(nickname)/PRIVATE/$(nickname)).data.uid == request.auth.uid;
      }

      allow create: if logged();
      allow get: if logged();
      allow update, delete: if owner();

      match /PRIVATE/{nickname} {
      	allow create: if request.resource.data.uid == request.auth.uid;
        allow delete: if resource.data.uid == request.auth.uid;
        allow write: if request.resource.data.uid == request.auth.uid;
      }

      match /NOTIFICATIONS/{from} {
      	allow create, delete: if logged();
        allow read, delete, update: if (owner());
      }
    }


    match /DELETED_ACCOUNTS/{nickname} {
    	allow create: if request.resource.data.uid == request.auth.uid
    }

  }
}