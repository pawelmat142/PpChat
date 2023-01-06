rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
//    TODO: prepare rules
      allow read, write: if true;
    }
  }
}