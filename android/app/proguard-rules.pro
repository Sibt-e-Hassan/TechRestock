#############################################
#
# Flutter app ProGuard rules
#
#############################################

# Keep Flutter-related classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep the main activity - CRITICAL
-keep public class com.solsapps.marketdekho.market_dekho.MainActivity {
    public <init>();
    public <methods>;
}

# Keep all app classes
-keep class com.solsapps.marketdekho.** { *; }
-keep class com.solsapps.** { *; }

# Keep Android framework classes
-keep public class android.** { public *; }
-keep public class androidx.** { public *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep custom application classes and activities
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.Fragment
-keep public class * extends androidx.fragment.app.Fragment

# Keep custom application classes
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Preserve line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*

# Preserve method names (for debugging and reflection)
-keepattributes Exceptions,InnerClasses

# Optimization
-optimizationpasses 5
-verbose

# Don't warn about missing classes
-dontwarn android.**
-dontwarn androidx.**
-dontwarn com.google.**
-dontwarn java.lang.invoke.**
