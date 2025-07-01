import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:tetris/Core/Services/logger.dart';

class FirebaseOperation extends ChangeNotifier {
  late FirebaseAuth firebaseAuth;
  final Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));
  Timer? time;
  bool verificatioProcess = false;
  User? user;
  int verificationTimeDuration = 60;
  final String currentFileName = "firebase_operations.dart";

  FirebaseOperation() {
    firebaseAuth = FirebaseAuth.instance;
  }

  Future<void> signIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (firebaseAuth.currentUser != null) {
        user = firebaseAuth.currentUser;
        logs.i("new user assign : - $user");
      }
    } catch (error) {
      ErrorLogs.logError("login.dart", error.toString(), "signIn");
    }
  }

  Future<void> signUp(
    String email,
    String password,
    BuildContext context,
  ) async {
    verificatioProcess = true;
    notifyListeners();

    try {
      UserCredential response = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (!context.mounted) return;

      if (response.user != null) {
        user = response.user;
        verification(context);
      } else {
        logs.w("User not present");
      }
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "signUp");
    }
  }

  void verification(BuildContext context) async {
    logs.i("Email verification start");
    if (time != null || user == null) {
      return;
    }

    verificatioProcess = true;
    notifyListeners();

    logs.w("user : - $user");

    try {
      await user!.sendEmailVerification();

      logs.i("email send");

      time = Timer.periodic(Duration(seconds: 1), (time) async {
        logs.w(user!);
        user!.reload();
        user = firebaseAuth.currentUser;
        if (verificationTimeDuration == 0) {
          if (context.mounted) cancal(context);
          return;
        } else if (user!.emailVerified) {
          if (context.mounted) cancal(context);
          if (context.mounted) context.push("/profile");
          return;
        }

        verificationTimeDuration--;
        notifyListeners();
      });
    } catch (error) {
      ErrorLogs.logError(currentFileName, error.toString(), "verification");
    }
  }

  void signOut() {
    firebaseAuth.signOut();
  }

  void cancal(BuildContext context) {
    verificationTimeDuration = 60;
    verificatioProcess = false;
    time!.cancel();
    time = null;
    notifyListeners();
  }
}
