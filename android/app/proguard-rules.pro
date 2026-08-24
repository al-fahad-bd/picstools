# Flutter & Android Engine Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods and JNI bindings
-keepclasseswithmembernames class * {
    native <methods>;
}

# ONNX Runtime rules (Crucial for release builds)
-keep class ai.onnxruntime.** { *; }
-keep class com.flutter_onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**
-keepattributes *Annotation*,EnclosingMethod,Signature,InnerClasses

# Google Play Core & Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# In-App Purchase & Firebase
-keep class com.android.billingclient.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.android.billingclient.**

# AndroidX Startup, WorkManager & Room Database
-keep class androidx.startup.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**

# Google Mobile Ads & Play Services
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.ads.**

