import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tetris/Core/Models/Hive/Chat/chats.dart';
import 'package:tetris/Core/Models/Hive/Home/user_chat_model.dart';
import 'package:tetris/Core/Models/Hive/Register/register.dart';
import 'package:tetris/Core/Models/DTO/basic_user_data.dart';
import 'package:tetris/Core/Routes/route.dart';
import 'package:tetris/Features/Chat/state/chat.dart';
import 'package:tetris/Features/Auth/Email/state/email.dart';
import 'package:tetris/Features/Home/state/home.dart';
import 'package:tetris/Features/Auth/Login/state/login.dart';
import 'package:tetris/Features/Profile/state/profile.dart';
import 'package:tetris/Features/Auth/Profile_Setup/state/profile_setup.dart';
import 'package:tetris/Features/Auth/Register/state/register.dart';
import 'package:tetris/Features/Search/state/search.dart';
import 'package:tetris/Core/Services/firebase_operations.dart';
import 'package:tetris/Core/Services/socket.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final getAppDocument = await getApplicationSupportDirectory();

  Hive.init(getAppDocument.path);

  Hive.registerAdapter(UserMetaDataAdapter());
  Hive.registerAdapter(UserChatModelAdapter());
  Hive.registerAdapter(ChatsDataAdapter());

  Provider.debugCheckInvalidValueType = null;

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://1922e506d4b768bc884c4e9e9e4776ff@o4509473535557632.ingest.us.sentry.io/4509473547681792';
      options.sendDefaultPii = true;
    },
    appRunner:
        () => runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => ProfilePageModel()),
              ChangeNotifierProvider(create: (context) => EmailPageModel()),
              ChangeNotifierProvider(create: (context) => LoginPageModel()),
              ChangeNotifierProvider(create: (context) => RegisterPageModel()),
              ChangeNotifierProvider(
                create: (context) => ProfileBioPageModel(),
              ),
              ChangeNotifierProvider(create: (context) => FirebaseOperation()),
              ChangeNotifierProvider(create: (context) => HomePageModel()),
              ChangeNotifierProvider(create: (context) => SocketOperation()),
              ChangeNotifierProvider(create: (context) => SearchPageModel()),
              ChangeNotifierProvider(create: (context) => ChatPageModel()),
              ChangeNotifierProvider(create: (context) => BasicUserData()),
            ],
            child: MyApp(),
          ),
        ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}
