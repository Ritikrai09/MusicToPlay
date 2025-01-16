-keep class ** { *; }

-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int w(...);
    public static int e(...);
    public static int d(...);
    public static int i(...);
}