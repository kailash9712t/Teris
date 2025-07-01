import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Core/Config/env.dart';
import 'package:tetris/Features/Home/state/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Logger logs = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(methodCount: 1, colors: true),
  );

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomePageModel>().updateBoxFromUsername();
      logs.i("updated home box name ${LocalData.homePageBoxName}");
      logs.i("updated user box name ${LocalData.userDataboxName}");
      context.read<HomePageModel>().fetchData();
      context.read<HomePageModel>().listen(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tetris"),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 16),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profileBioPage');
                  break;
                case 'setting':
                  break;
                case 'sign out':
                  Provider.of<HomePageModel>(
                    context,
                    listen: false,
                  ).signOut(context);
                  context.go("/login");
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'profile', child: Text("Profile")),
                PopupMenuItem(value: 'setting', child: Text("Setting")),
                PopupMenuItem(value: 'sign out', child: Text("Sign out")),
              ];
            },
          ),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Chats"),
            Tab(text: "Status"),
            Tab(text: "Calls"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatsTab(), _buildStatusTab(), _buildCallsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/search');
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildChatsTab() {
    return Consumer<HomePageModel>(
      builder: (context, instance, child) {
        logs.i("List reloaded!");
        return instance.listOfUsers.isEmpty
            ? _blankView()
            : Column(
              children:
                  instance.listOfUsers.entries
                      .map((entry) {
                        String timeStamp = entry.value.timeStamp;
                        DateTime time = DateTime.parse(timeStamp);
                        String hour =
                            "${time.hour.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}";
                        return ListTile(
                          onTap:
                              () => context.push(
                                '/chat?username=${entry.value.username}&userImage=${entry.value.profilePhotoUrl}&displayName=${entry.value.displayName}',
                              ),
                          leading: CircleAvatar(
                            backgroundImage:
                                entry.value.profilePhotoUrl == "default.png"
                                    ? AssetImage(
                                      "assets/image/default_user.png",
                                    )
                                    : NetworkImage(entry.value.profilePhotoUrl),
                          ),
                          title: Text(entry.value.displayName),
                          subtitle: Text(
                            entry.value.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(hour),
                        );
                      })
                      .toList()
                      .reversed
                      .toList(),
            );
      },
    );
  }

  Widget _buildStatusTab() {
    return const Center(child: Text("Status updates here"));
  }

  Widget _buildCallsTab() {
    return const Center(child: Text("Call logs here"));
  }

  Widget _blankView() {
    return const Center(child: Text("No messsage found"));
  }
}
