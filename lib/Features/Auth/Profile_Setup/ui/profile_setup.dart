import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Models/DTO/basic_user_data.dart';
import 'package:tetris/Features/Auth/Profile_Setup/state/profile_setup.dart';
import 'package:tetris/Core/Services/user_data_provider.dart';

class ProfileBioPage extends StatefulWidget {
  const ProfileBioPage({super.key});

  @override
  State<ProfileBioPage> createState() => _ProfileBioPageState();
}

class _ProfileBioPageState extends State<ProfileBioPage> {
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _displayName = TextEditingController();

  @override
  void initState() {
    UserDataProvider().loadDataThroughStorage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBioPageModel>().fetchUserData();
    });

    super.initState();
  }

  @override
  void dispose() {
    _bio.dispose();
    _displayName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal[800],
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.teal[800],
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    Consumer<ProfileBioPageModel>(
                      builder: (context, instace, child) {
                        return InkWell(
                          onTap: () {},
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                (instace.userMetaData?.profilePhotoUrl ==
                                            "default.png" ||
                                        instace.userMetaData?.profilePhotoUrl ==
                                            null)
                                    ? AssetImage(
                                      'assets/image/default_user.png',
                                    )
                                    : NetworkImage(
                                      instace.userMetaData!.profilePhotoUrl!,
                                    ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap:
                            () => Provider.of<ProfileBioPageModel>(
                              context,
                              listen: false,
                            ).selectImage(context),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.blue[500],
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Consumer<ProfileBioPageModel>(
                  builder: (context, instance, child) {
                    return Column(
                      children: [
                        Text(
                          "${instance.userMetaData?.username}",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "+91 ${instance.userMetaData?.mobileNumber}",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ListTile(
          //   leading: const Icon(Icons.info_outline),
          //   title: const Text("About"),
          //   subtitle: const Text("Busy 🚫"),
          //   trailing: Icon(Icons.edit),
          // ),
          Consumer<ProfileBioPageModel>(
            builder: (context, instance, child) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child:
                              instance.usernameEditStatus
                                  ? TextFormField(
                                    controller: _displayName,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: 'Display Name',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    maxLines: null,
                                  )
                                  : ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.person),
                                    title: const Text("Display Name"),
                                    subtitle: Text(
                                      "${instance.userMetaData?.displayName}",
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          instance.usernameEditStatus
                              ? Icons.check
                              : Icons.edit,
                        ),
                        onPressed:
                            instance.usernameEditStatus
                                ? () {
                                  instance.userMetaData?.displayName =
                                      _displayName.text;

                                  BasicUserData().displayName =
                                      _displayName.text;

                                  instance.usernameEdit();

                                  instance.updateData(
                                    "displayName",
                                    _displayName.text,
                                    context,
                                  );
                                }
                                : () {
                                  instance.usernameEdit();
                                },
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child:
                              instance.bioEditStatus
                                  ? TextFormField(
                                    controller: _bio,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: 'About',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    maxLines: null,
                                  )
                                  : ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.info_outline),
                                    title: const Text("About"),
                                    subtitle: Text(
                                      "${instance.userMetaData?.bio}",
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          instance.bioEditStatus ? Icons.check : Icons.edit,
                        ),
                        onPressed:
                            instance.bioEditStatus
                                ? () {
                                  instance.userMetaData?.bio = _bio.text;
                                  BasicUserData().bio = _bio.text;

                                  instance.bioEdit();
                                  instance.updateData(
                                    "bio",
                                    _bio.text,
                                    context,
                                  );
                                }
                                : () {
                                  instance.bioEdit();
                                },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Media, Links, and Docs"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.notifications_off_outlined),
            title: const Text("Mute Notifications"),
            trailing: Consumer<ProfileBioPageModel>(
              builder: (context, instance, child) {
                return Switch(
                  value: instance.muteSwitch,
                  onChanged: (val) {
                    instance.switchTap(val);
                  },
                );
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text("Custom Notifications"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Encryption"),
            subtitle: const Text("Messages and calls are end-to-end encrypted"),
          ),
        ],
      ),
    );
  }
}
