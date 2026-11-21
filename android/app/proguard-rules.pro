# Marky ProGuard / R8 Rules

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

# Transitive Apache Tika (via file_picker) references desktop StAX API absent on Android
-dontwarn javax.xml.stream.XMLStreamException

# General reflection attributes
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
