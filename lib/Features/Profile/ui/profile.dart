import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Features/Profile/state/profile.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';
import 'package:tetris/Core/Services/socket.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _bio = '';

  void _submit() async {
    String currentUsername = UserDataProvider().basicUserData.username;

    bool? response = await context.read<ProfilePageModel>().completeProfile(_name, _bio, currentUsername);

    if (!mounted) return;

    if (response) {
      context.read<SocketOperation>().initialize();
      context.go('/home');
    }
  }

  @override
  void initState() {
    UserDataProvider().loadDataThroughStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<ProfilePageModel>(
                builder: (context, instance, child) {
                  return CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        instance.path == null
                            ? AssetImage("assets/image/default_user.png")
                            : FileImage(File(instance.path!)),
                  );
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    Provider.of<ProfilePageModel>(
                      context,
                      listen: true,
                    ).selectImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Choose Profile Image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 40),

              TextFormField(
                onChanged: (value) => {_name = value},
                decoration: InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                onChanged: (value) => {_bio = value},
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),

              Consumer<ProfilePageModel>(
                builder: (context, instance, child) {
                  return ElevatedButton(
                    onPressed: instance.statusBio ? () {} : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        instance.statusBio
                            ? const SizedBox(
                              height: 17,
                              width: 17,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
