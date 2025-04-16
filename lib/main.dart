import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ghp_society_management/constants/export.dart';
import 'package:ghp_society_management/firebase_services.dart';
import 'dart:async';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalStorage.init();
  await Firebase.initializeApp();
  FirebaseNotificationService.showNotification(message);
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings =
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("User Denied Notification Permission");
  } else {
    print("Notification Permission Granted");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  await requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseNotificationService.initialize2();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FirebaseNotificationService.initialize();
    FirebaseNotificationService.initializeNotificationHandler();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders.providers,
      child: ScreenUtilInit(
        designSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true,appBarTheme: AppBarTheme(backgroundColor: AppTheme.blueColor)),
            home: SplashScreen(),
            navigatorKey: navigatorKey,
            // navigatorObservers: [analyticsObserver],
          );
        },
      ),
    );
  }
}