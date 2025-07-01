import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Models/Hive/Register/register.dart';
import 'package:tetris/Features/Auth/Register/state/register.dart';
import 'package:tetris/Core/Widgets/animation_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Timer? usernameTimer;
  Timer? emailTimer;
  Timer? mobileNumberTimer;

  bool listen = true;

  late AnimationController controller;
  late final ButtonAnimationController instance;

  Logger logger = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );

  void sumbit() async {
    UserMetaData userData = UserMetaData(
      username: _usernameController.text,
      password: _passwordController.text,
      email: _emailController.text,
      mobileNumber: _mobileController.text,
    );

    bool result = await context.read<RegisterPageModel>().register(
      _formKey,
      context,
      userData,
    );

    if (!mounted) return;

    if (result) {
      context.push("/email");
    }
  }

  void textChangeInUsername(String key, String value) {
    if (usernameTimer != null && usernameTimer!.isActive) {
      usernameTimer!.cancel();
    }

    usernameTimer = Timer(Duration(seconds: 2), () async {
      context.read<RegisterPageModel>().databaseInExists(key, value);
    });
  }

  void textChangeInEmail(String key, String value) {
    if (emailTimer != null && emailTimer!.isActive) {
      emailTimer!.cancel();
    }

    logger.i("Email request send");

    emailTimer = Timer(Duration(seconds: 2), () async {
      context.read<RegisterPageModel>().databaseInExists(key, value);
    });
  }

  void textChangeInMobileNumber(String key, String value) {
    if (mobileNumberTimer != null && mobileNumberTimer!.isActive) {
      mobileNumberTimer!.cancel();
    }

    mobileNumberTimer = Timer(Duration(seconds: 2), () async {
      context.read<RegisterPageModel>().databaseInExists(key, value);
    });
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    instance = ButtonAnimationController(controller);
  }

  @override
  void dispose() {
    usernameTimer?.cancel();
    emailTimer?.cancel();
    mobileNumberTimer?.cancel();

    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    controller.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isUsername = false,
    bool isEmail = false,
    bool isMobileNumber = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon:
          isPassword
              ? Consumer<RegisterPageModel>(
                builder: (context, instance, child) {
                  return IconButton(
                    icon: Icon(
                      instance.showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      instance.showIcon();
                    },
                  );
                },
              )
              : (isUsername || isEmail || isMobileNumber)
              ? Consumer<RegisterPageModel>(
                builder: (context, instance, child) {
                  final showStatus =
                      isUsername
                          ? instance.showStatus[Fields.username] ??
                              FieldsStatus.notStart
                          : isEmail
                          ? instance.showStatus[Fields.email] ??
                              FieldsStatus.notStart
                          : instance.showStatus[Fields.mobileNumber] ??
                              FieldsStatus.notStart;
                  switch (showStatus) {
                    case FieldsStatus.start:
                      return SizedBox(
                        height: 5,
                        width: 5,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 3,
                        ),
                      );
                    case FieldsStatus.notStart:
                      return SizedBox.shrink();
                    case FieldsStatus.valid:
                      return Icon(Icons.check);
                    case FieldsStatus.invalid:
                      return Icon(Icons.close);
                  }
                },
              )
              : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[100],
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 40),

                  TextFormField(
                    onChanged: (value) {
                      textChangeInUsername("username", value);
                    },
                    controller: _usernameController,
                    decoration: _buildInputDecoration(
                      'Username',
                      Icons.person,
                      isUsername: true,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your username";
                      }
                      if (value.contains(" ")) {
                        return "Please remove space from username";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  TextFormField(
                    onChanged: (value) {
                      textChangeInMobileNumber("mobileNumber", value);
                    },
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration(
                      'Mobile Number',
                      Icons.phone,
                      isMobileNumber: true,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter your mobile number'
                                : null,
                  ),
                  SizedBox(height: 30),

                  TextFormField(
                    onChanged: (value) {
                      textChangeInEmail("email", value);
                    },
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      'Email',
                      Icons.email,
                      isEmail: true,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 90,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText:
                          context.watch<RegisterPageModel>().showPassword,
                      decoration: _buildInputDecoration(
                        'Password',
                        Icons.lock,
                        isPassword: true,
                      ).copyWith(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 10,
                        ),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                    ),
                  ),
                  SizedBox(height: 50),

                  AnimatedBuilder(
                    animation: instance.animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: instance.animation.value,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTapDown: instance.onTapDown,
                      onTapUp: instance.onTapUp,
                      onTapCancel: instance.onTapCancal,
                      child: Consumer<RegisterPageModel>(
                        builder: (context, instance, child) {
                          return ElevatedButton(
                            onPressed: instance.registerStatus ? () {} : sumbit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                instance.registerStatus
                                    ? const SizedBox(
                                      height: 17,
                                      width: 17,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          context.go('/');
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
