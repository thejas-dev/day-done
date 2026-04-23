# Keep generic signatures and annotations used by Gson type tokens.
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Keep plugin notification classes that are serialized/deserialized.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep Gson internals used by plugin deserialization.
-keep class com.google.gson.** { *; }
