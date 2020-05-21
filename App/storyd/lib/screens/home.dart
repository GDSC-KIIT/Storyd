import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
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
      user = value;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                  itemCount: snapshot.data.documents.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return HomePageSearchBar();
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
    );
  }
}

class BottomNavigationBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationBarState();
  }
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[],
        ),
      ),
    );
  }
}
