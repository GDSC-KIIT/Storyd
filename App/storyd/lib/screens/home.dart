import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storyd/screens/special_widgets.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser user;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        user = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24),
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('story-collection')
                  .orderBy("up_since", descending: true)
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
          BottomNavigationBar(currentUser: user),
        ],
      ),
    );
  }
}

class BottomNavigationBar extends StatefulWidget {
  BottomNavigationBar({this.currentUser});

  final FirebaseUser currentUser;

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationBarState();
  }
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  String avatarUrl;

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
            Icon(Icons.home),
            Icon(Icons.people_outline),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Color.fromRGBO(100, 190, 255, 1),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 0.2,
                  ),
                ],
                border: Border.all(
                  width: 5,
                  color: Colors.white,
                ),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 33,),
            ),
            Icon(Icons.chat_bubble_outline),
            SizedBox(
              height: 25,
              width: 25,
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
          ],
        ),
      ),
    );
  }
}
