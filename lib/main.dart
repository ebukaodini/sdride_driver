import 'package:flutter/material.dart';
import 'package:sdride_driver/pages/map.dart';
import 'package:sdride_driver/pages/welcome.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sdride_driver/providers/Driver.dart';
import 'package:sdride_driver/providers/Order.dart';
import 'package:sdride_driver/providers/Rider.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Driver()),
        ChangeNotifierProvider(create: (context) => Rider()),
        ChangeNotifierProvider(create: (context) => Order()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SD Ride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: Colors.black45,
            fontSize: 16,
          ),
        ),
        primaryColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            textStyle: MaterialStateProperty.all(
              TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/welcome': (BuildContext context) => new WelcomePage(),
        '/map': (BuildContext context) => new MapPage()
      },
      initialRoute: '/welcome',
    );
  }
}
