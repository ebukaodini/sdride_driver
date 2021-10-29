import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sdride_driver/utils/functions.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: screen(context).height * 0.3,
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.car_detailed,
                    size: 100,
                    color: Colors.blue.shade50,
                  ),
                  Text(
                    'SD Ride',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue.shade50,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  // Text(
                  //   'Drivers',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     color: Colors.blue.shade50,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 20,
                  //   ),
                  // ),
                ],
              )),
          Positioned(
            // bottom: 60,
            top: screen(context).height * 0.7,
            child: SizedBox(
              width: screen(context).width * 0.8,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.blue.shade50),
                  foregroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                onPressed: () => Navigator.pushNamed(context, '/map'),
                child: Text('Continue'),
              ),
            ),
          ),
        ],
      ),
      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      // Text(
      //   'Welcome\nRider',
      //   textAlign: TextAlign.center,
      //   style: TextStyle(
      //     color: Colors.blue,
      //     // fontWeight: FontWeight.bold,
      //     fontSize: 40,
      //   ),
      // ),
      //       SizedBox(height: 30),

      //     ],
      //   ),
      // ),
    );
  }
}
