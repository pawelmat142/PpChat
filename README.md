# ppChat

## 1. Introduction 

The chat application is a simple demonstration project built with Flutter and Firebase. 
The motivation behind creating this app is to: 


- <strong>Learn the Flutter Framework and Dart:</strong> Gain hands-on experience with Flutter and deepen my knowledge of Dart by building a cross-platform application.
- <strong>Integrate Firebase Services:</strong> Understand and utilize Firebase tools for backend functionality, such as authentication and real-time database, to build a functional and scalable application.
- <strong>Create a Simple Chat App: </strong> Develop a lightweight, serverless chat application to explore how Flutter interacts with Firebase for real-time communication.


### 1.1. User Experience 
The layout of the project is built using the default Material Design framework, ensuring a consistent and visually appealing user interface aligned with modern design standards.

</br>

## 2. Features

Application offers the following functionalities:

- User registration and login using <strong>Firebase Authentication</strong>.
- Sending and receiving real-time messages via <strong>Firebase Firestore</strong>.
- Editing avatar, or uploading images using <strong>Firebase Storage</strong>.
- Messages are encrypted using the <strong>RSA algorithm</strong>, private key.
- Messages are decrypted upon being read, deleted from Firestore for privacy, and stored locally on the device using Hive to preserve chat history.
- The user can clear chat history and set an auto-delete timer.
- RSA private key is stored in local storage using <strong>Hive</strong> package.
- Logging into the same account from another device generates a new key pair and publishes a new public key.

</br>

## 3. Setup

### 3.1. Run localy - Android Studio + AVD

Ensure you have the following installed:

- Android Studio
- AVD (Android Virtual Device)
- Flutter SDK (project is created with SDK Android 14, API Level 34)
- Java (openjdk 17)

To run the app locally using AVD follow these steps:

- create project directory, open it with console and run: 
```
git clone https://github.com/pawelmat142/ppChat.git ./
```
- open project with Android Studio and run in terminal:
```
flutter pub get
```
- open Device Manager
- start Virtual Device (for example Pixel Api 33)
- run in terminal:
```
flutter run
```

</br>

### 3.2. Mobile device

#### 3.2.1. Android 

To install app on Android device download and install `.apk` file from [here](https://drive.google.com/drive/folders/1KJUvu4on77YObjU1Zx1S0USbiPTxdg0V?usp=sharing)

#### 3.2.2. iOS  

This project does not include a generated `.ipa` file for iOS because Apple requires a paid Developer Account to create and distribute `.ipa` files. As this is a personal portfolio project, I have chosen not to pay for this service. However, the project can still be run locally on iOS devices using Xcode with a free Apple ID. To run app on an iOS device using Xcode, follow these steps:

- create project directory, open it with console and run: 
```
git clone https://github.com/pawelmat142/ppChat.git ./
flutter pub get
flutter build ios
```
- open the iOS project in Xcode:
```
open ios/Runner.xcworkspace
```
- plug in your iOS device to your Mac using a USB cable,
- on your iOS device, go to <strong>Settings > General > Device Management,</strong> 
- in Xcode, choose your connected device from the target device dropdown,
- Click the <strong>Run</strong> button in Xcode to build and install the app.

### 3.3. Write to me 

- Create account with nickname and password
- Find contact `pawelmat142` and send me invitation :)


</br>

## 4. Security

The app is not secured, and the firebase api keys are public:

`./lib/firebase_options.dart` 

This is intentional as the applications are developed for educational and portfolio purposes. This approach helps with maintaining and presenting the projects with minimal configuration required.
To create your own instance of the project, simply replace the API keys with those generated in your own Firebase console.