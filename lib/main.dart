import 'dart:async';
import 'dart:convert';

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_preload_videos/provider/preload_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:blogit/Utils/app_theme.dart';
import 'package:blogit/Utils/app_util.dart';
import 'package:blogit/Utils/blank_util.dart';
import 'package:blogit/Utils/route_util.dart';
import 'package:blogit/controller/shorts_controller.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/lang.dart';
import 'package:blogit/model/settings.dart';

import 'Utils/color_util.dart';
import 'Utils/urls.dart';
import 'controller/app_provider.dart';
import 'controller/repository.dart';
import 'model/blog.dart';

SharedPreferences? prefs;
GlobalKey<NavigatorState> navkey = GlobalKey<NavigatorState>();
bool flexibleUpdateAvailable = false;
Upgrader? upgrader;

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

bool isFlutterLocalNotificationsInitialized = false;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<Blog> blogDetail(String id) async {
  var url = "${Urls.baseUrl}blog-detail/$id";
  var result = await http.get(
    Uri.parse(url),
  );
  Map data = await json.decode(result.body);
  final list = Blog.fromJson(data['data'], isNotification: true);
  return list;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification!.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "channel.id",
          "channel.name",
          channelDescription: "channel.description",
          icon: 'launch_background',
        ),
      ),
    );
  }
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await setupFlutterNotifications();
  showFlutterNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(true);
  OneSignal.consentGiven(true);

  // configureInjection(Environment.prod);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  OneSignal.initialize('3dd92183-3eee-4446-8748-7e74c9b0cf61');
  await MobileAds.instance.initialize();
  await Upgrader.clearSavedSettings();
  FirebaseMessaging.instance.requestPermission();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  EasyAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
      iOSAdvertiserTrackingEnabled: true //default false
      );

  try {
    prefs = await SharedPreferences.getInstance();
    await getDataFromSharedPrefs();
    await getMessageAndSetting();
    await getCurrentUser();
    prefs!.setString('url', "1");
    prefs!.setInt('id', 1);
    
  } catch (e) {
    prefs = await SharedPreferences.getInstance();
    await getCurrentUser();
    await getDataFromSharedPrefs();
    await getMessageAndSetting();
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(false);
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AppProvider()),
    ChangeNotifierProvider(create: (context) {
          return PreloadProvider();
     }),
  ], child:  const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  UserProvider userProvider = UserProvider();
  late DateTime startTime;
  DateTime? endTime;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer!.cancel();
    super.dispose();
  }

  Timer? timer;

  void _fetchData() {
    var provider = Provider.of<AppProvider>(context, listen: false);
    provider.getAnalyticData();
    //  debugPrint(store.toString());
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await setupFlutterNotifications();
    showFlutterNotification(message);
  }

  @override
  void initState() {
    OneSignal.Notifications.addPermissionObserver((accepted) async {
      final status = OneSignal.User.pushSubscription.id;
      final String? osUserID = status;
      if (osUserID != null) {
        currentUser.value.playerId = osUserID.toString();
        updateToken(currentUser.value, status ?? "");
      }
    });
    
      upgrader = Upgrader(
      debugLogging: true, durationUntilAlertAgain:  
      Duration(days: prefs!.containsKey('update_duration') ? 
      prefs!.getInt('update_duration') as int : 0));

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              // _resolved = true;
              // initialMessage = value!.data.toString();
            },
          ),
        );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   Navigator.pushNamed(
    //     navkey.currentState!.context,
    //     '/ForgotPage',
    //   );
    // });
    // ------------------ app Id --------------------
    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt.
    //We recommend removing the following code and instead using an In-App Message to prompt for notification permission

    OneSignal.User.pushSubscription.addObserver((accepted) async {
      final status = OneSignal.User.pushSubscription.id;
      final String? osUserID = status;
      if (osUserID != null) {
        currentUser.value.playerId = osUserID.toString();
        updateToken(currentUser.value, status ?? "");
      }
    });

    OneSignal.Notifications.addClickListener(listener);

    userProvider.checkSettingUpdate();
    adView();
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
    });
    WidgetsBinding.instance.addPostFrameCallback((e) async {
      // var provider = Provider.of<PreloadProvider>(context, listen: false);
      
        await ShortsApi().fetchShorts().then((e) async{
          // if(e != null && e.isNotEmpty){
          //   provider.urls = e;
          //   provider.initialize();
          //     // shortslikesIds.forEach((e){
          //     //   provider.setLike()
          //     // });
          //   log(e.toString());
          // }
         setState(() {   });
      });
    });
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  void listener(OSNotificationClickEvent result) async {
    result.preventDefault();
    result.notification.display();
    await notificationClick(result);
  }

  Future<void> notificationClick(OSNotificationClickEvent result) async {

    final blog =json.decode(result.notification.rawPayload!['custom'].toString())['a']['blog'];
    final action = result.notification.rawPayload!['actionId'];

    try {
  
      if (prefs!.containsKey('url')) {
        setState(() {});

        prefs!.setString('url', '2');

        Navigator.push(
            navkey.currentState!.context,
            MaterialPageRoute(
                builder: (context) => Loader(
                    blog: Blog(id: int.parse(blog.toString())),
                    action: action)));
 
      } else {
        Navigator.push(
            navkey.currentState!.context,
            MaterialPageRoute(
                builder: (context) => Loader(
                    blog: Blog(id: int.parse(blog.toString())),
                    action: action)));
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle the lifecycle state change
    switch (state) {
      case AppLifecycleState.resumed:
        timer = Timer.periodic(const Duration(minutes: 10), (timer) {
          if (WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) {
            _fetchData();
          }
        });
        break;

      case AppLifecycleState.paused:
        timer?.cancel();
        _fetchData();
        setState(() {});

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        endTime = DateTime.now();
        prefs!.remove('isBookmark');
        _fetchData();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  // final NavigationService _navigationService = getIt<NavigationService>();

  @override
  Widget build(BuildContext context) {
  
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return  ValueListenableBuilder<SettingModel>(
                valueListenable: allSettings,
                builder: (context, val2, child) {
                  return ValueListenableBuilder<AppModel>(
                      valueListenable: appThemeModel,
                      builder: (context, val, child) {
                        return AnnotatedRegion<SystemUiOverlayStyle>(
                          value: SystemUiOverlayStyle(
                            systemNavigationBarIconBrightness:
                                appThemeModel.value.isDarkModeEnabled.value
                                    ? Brightness.light
                                    : Brightness.dark,
                            statusBarIconBrightness:
                                appThemeModel.value.isDarkModeEnabled.value
                                    ? Brightness.light
                                    : Brightness.dark,
                            systemNavigationBarColor:
                                appThemeModel.value.isDarkModeEnabled.value
                                    ? ColorUtil.white
                                    : Colors.black,
                          ),
                          child: ValueListenableBuilder<Language>(
                              valueListenable: languageCode,
                              builder: (context, value, child) {
                                return UpgradeAlert(
                                  navigatorKey: navkey,
                                  upgrader: prefs!.containsKey('update_duration') && upgrader != null ? upgrader : null,
                                  onIgnore: (){
                                    prefs!.setInt('update_duration', 1000);
                                    launchUrl(Uri.parse('/'));
                                    return true;
                                  },
                                   onLater: (){
                                    prefs!.setInt('update_duration', 3);
                                    launchUrl(Uri.parse('/'));
                                    return true;
                                  },
                                  shouldPopScope: () => allSettings.value.isAppForceUpdate != '1',
                                  showIgnore:allSettings.value.isAppForceUpdate != '1',
                                  showLater: allSettings.value.isAppForceUpdate != '1',
                                  child: MaterialApp(
                                    // key: _navigationService.navigationKey,
                                    navigatorKey: navkey,
                                    builder: (context, child) {
                                      child = Directionality(
                                        textDirection:
                                            languageCode.value.pos == 'rtl'
                                                ? TextDirection.rtl
                                                : TextDirection.ltr,
                                        child: child as Widget,
                                      );
                                      return child;
                                    },
                                    localizationsDelegates: const [
                                      GlobalMaterialLocalizations.delegate,
                                      GlobalCupertinoLocalizations.delegate,
                                      GlobalWidgetsLocalizations.delegate,
                                    ],
                                    debugShowCheckedModeBanner: false,
                                    title: allSettings.value.appName ?? "",
                                    initialRoute: "/",
                                    onGenerateRoute:
                                        RouteGenerator.generateRoute,
                                    theme: val.isDarkModeEnabled.value == true
                                        ? AppTheme.darkThemeData(
                                            hexToRgb(val2.primaryColor))
                                        : AppTheme.lightTheme(
                                            hexToRgb(val2.secondaryColor)),
                                    themeMode:
                                        val.isDarkModeEnabled.value == true
                                            ? ThemeMode.dark
                                            : ThemeMode.light,
                                  ),
                                );
                              }),
                        );
                      });
                });
        });
  }
}