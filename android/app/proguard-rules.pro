## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

## AndroidX Media (lock screen controls)
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }

## Dart/Flutter specific
-dontwarn io.flutter.embedding.**
