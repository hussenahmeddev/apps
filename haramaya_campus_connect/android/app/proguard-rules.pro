# Flutter-specific ProGuard rules

# Keep Flutter engine and plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep Google Sign-In & Play Services
-keep class com.google.android.gms.** { *; }

# Play Core split-install classes referenced by Flutter engine
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Suppress warnings for common dependencies
-dontwarn com.google.errorprone.**
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.crypto.tink.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
