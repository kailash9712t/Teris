import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tetris/Features/Search/state/search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchQuery = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchPageModel>(
        context,
        listen: false,
      ).fetchContect(_searchQuery.text);
    });
  }

  void search(BuildContext context, String value) {
    if (timer != null && timer!.isActive) timer?.cancel();

    timer = Timer(Duration(seconds: 3), () {
      Provider.of<SearchPageModel>(context, listen: false).fetchContect(value);
    });
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _searchQuery,
                onChanged: (value) {
                  if (value.isNotEmpty && value != "") search(context, value);
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Consumer<SearchPageModel>(
                  builder: (context, instance, child) {
                    return ListView.builder(
                      itemCount: instance.resultUsers.length,
                      itemBuilder: (context, index) {
                        final user = instance.resultUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                (user.profilePhotoId?.isEmpty ?? true)
                                    ? AssetImage(
                                      "assets/image/default_user.png",
                                    )
                                    : NetworkImage(user.profilePhotoId!),
                          ),
                          title: Text(user.displayName),
                          subtitle: Text(user.username),
                          isThreeLine: true,
                          onTap: () {
                            context.push(
                              "/chat?username=${user.username}&userImage=${user.profilePhotoId}&displayName=${user.displayName}",
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
