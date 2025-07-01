import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Services/firebase_operations.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Consumer<FirebaseOperation>(
                builder: (context, instance, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          instance.verificatioProcess
                              ? Colors.blue[200]
                              : Colors.blue,
                    ),
                    onPressed:
                        instance.verificatioProcess
                            ? () {}
                            : () async {
                              logs.i("Reverify");
                              instance.verification(context);
                            },
                    child: Text(
                      "Resend Email",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Consumer<FirebaseOperation>(
                builder: (context, instance, child) {
                  return Text("Resend in ${instance.verificationTimeDuration}");
                },
              ),
              SizedBox(height: 20),
              Text(
                'After verification, you will be redirect to next page',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
