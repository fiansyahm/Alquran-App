# mobbb_ads

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Setting:
flutter sdk: 17 Oracle OpenJDK 17.0.12

build.grandle android
buildscript {
repositories {
google()
mavenCentral()
}
dependencies {
classpath 'com.android.tools.build:gradle:8.1.1'
classpath 'com.google.gms:google-services:4.3.15'  // Menambahkan plugin Google Services
}
}

build.grandle android/app:
defaultConfig {
applicationId = "com.example.mobbb_ads"
minSdkVersion = 21
targetSdkVersion = 33
versionCode = 1
versionName = "1.0"
}
buildTypes {
....
}
flutter {
source = "../.."
}
dependencies {
//    implementation 'com.google.android.gms:play-services:12.0.1'
implementation 'com.google.android.gms:play-services-ads:23.6.0'
//    implementation 'com.google.android.gms:play-services-ads:22.4.0'
}