import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyd/screens/create_post.dart';
import 'package:storyd/screens/special_widgets.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser user;
  int homePageIndex = 0;
  List<Widget> friendListWidgets = [];

  startUpJobs() async {
    CollectionReference userDataCollection =
        Firestore.instance.collection("user-data");
    var myUserInfo = await userDataCollection.document(user.uid).get();
    List<Widget> _friendListWidgets = [];
    myUserInfo.data["friend-list"].forEach((id) async {
      var friendUserInfo = await userDataCollection.document(id).get();

      _friendListWidgets.add(Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: friendUserInfo.data["avatar-url"] != "" ? CachedNetworkImage(
                  imageUrl: friendUserInfo.data["avatar-url"],
                  fit: BoxFit.cover,
                ) : Image.asset("assets/avatar.png"),
              ),
            ),
            SizedBox(width: 10),
            Text(friendUserInfo.data["name"]),
          ],
        ),
      ));
    });

    setState(() {
      friendListWidgets = _friendListWidgets;
    });

  }

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        user = value;
      });

      WidgetsBinding.instance
          .addPostFrameCallback((timeStamp) => startUpJobs());
    });

    super.initState();
  }

  void changeHomePageSlot(int index) {
    setState(() {
      homePageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: IndexedStack(
              key: ValueKey<int>(homePageIndex),
              index: homePageIndex,
              children: [
                // Home - 0
                Padding(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('story-collection')
                        .orderBy("up-since", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (user == null) {
                        return Center(
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Center(
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        default:
                          return ListView.builder(
                            cacheExtent: MediaQuery.of(context).size.height *
                                4, // Equivalent to 4 page caching/
                            physics: BouncingScrollPhysics(),
                            itemCount: snapshot.data.documents.length + 2,
                            // +2 for SearchBar and BottomEmptyBlock
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return HomePageSearchBar();
                              } else if (index ==
                                  snapshot.data.documents.length + 1) {
                                return SizedBox(height: 70);
                              }

                              return StoryTile(
                                data: snapshot.data.documents[index - 1],
                                currentUser: user,
                              );
                            },
                          );
                      }
                    },
                  ),
                ),
                // Friends - 1
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextField(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: friendListWidgets,
                        ),
                      ),
                    ],
                  ),
                ),
                // Direct Messages - 2
                Center(
                  child: Text("Direct Messages"),
                ),
                // Profile - 3
                Center(
                  child: Text("Profile"),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            currentUser: user,
            homeState: this,
            onBottomBarAction: (int pageIndex) {
              changeHomePageSlot(pageIndex);
            },
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBar extends StatefulWidget {
  BottomNavigationBar(
      {@required this.currentUser,
      @required this.homeState,
      this.onBottomBarAction});

  final State homeState;
  final FirebaseUser currentUser;
  final Function(int) onBottomBarAction;

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationBarState();
  }
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  String avatarUrl;
  int activeSelectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Home
            GestureDetector(
              child: Icon(Icons.home,
                  color: activeSelectionIndex == 0
                      ? Colors.black
                      : Colors.blueGrey.shade300),
              onTap: () {
                setState(() {
                  activeSelectionIndex = 0;
                });
                widget.onBottomBarAction(0);
              },
            ),
            // Friends
            GestureDetector(
              child: Icon(Icons.people_outline,
                  color: activeSelectionIndex == 1
                      ? Colors.black
                      : Colors.blueGrey.shade300),
              onTap: () {
                setState(() {
                  activeSelectionIndex = 1;
                });
                widget.onBottomBarAction(1);
              },
            ),
            // Add post
            GestureDetector(
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(100, 190, 255, 1),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      blurRadius: 33,
                      spreadRadius: 0.1,
                    ),
                  ],
                  border: Border.all(
                    width: 5,
                    color: Colors.white,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 33,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewPostField(
                      avatarUrl: avatarUrl,
                      currentUser: widget.currentUser,
                      homeState: widget.homeState,
                    ),
                  ),
                );
              },
            ),
            // Direct Messages
            GestureDetector(
              child: Icon(Icons.chat_bubble_outline,
                  color: activeSelectionIndex == 2
                      ? Colors.black
                      : Colors.blueGrey.shade300),
              onTap: () {
                setState(() {
                  activeSelectionIndex = 2;
                });
                widget.onBottomBarAction(2);
              },
            ),
            // Profile
            GestureDetector(
              child: Container(
                height: 33,
                width: 33,
                decoration: BoxDecoration(
                  color: activeSelectionIndex == 3
                      ? Colors.black
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 3,
                        color: Colors.white,
                      ),
                    ),
                    child: Builder(builder: (context) {
                      if (widget.currentUser == null) {
                        return Container();
                      }
                      Firestore.instance
                          .collection("user-data")
                          .document(widget.currentUser.uid)
                          .get()
                          .then((ds) {
                        setState(() {
                          avatarUrl = ds.data["avatar-url"];
                        });
                      });

                      return avatarUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.5),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: avatarUrl,
                              ),
                            )
                          : Container();
                    }),
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  activeSelectionIndex = 3;
                });
                widget.onBottomBarAction(3);
              },
            ),
          ],
        ),
      ),
    );
  }
}
