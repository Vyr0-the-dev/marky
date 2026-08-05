# Marky ProGuard Rules
# Generated for reflection-heavy libraries: Isar, Dio, Freezed

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Isar
-keep class * extends isar.IsarObject { *; }
-keep class * extends isar.IsarLink { *; }
-keep class * extends isar.IsarLinks { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @isar.* <fields>;
}
-keep class isar.** { *; }
-dontwarn isar.**

# Freezed / JSON Serializable
-keepclassmembers class * {
    *** fromJson(...);
    *** toJson();
}
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Dio / OkHttp / Okio
-keep class com.squareup.okhttp3.** { *; }
-keep interface com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# General reflection
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes *Annotation*

# R8: Missing class javax.xml.stream.XMLStreamException (Apache Tika metadata extraction)
-dontwarn javax.xml.stream.XMLStreamException
