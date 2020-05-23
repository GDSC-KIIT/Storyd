import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NewPostField extends StatelessWidget {
  NewPostField({this.avatarUrl, this.currentUser, this.homeState});

  final FirebaseUser currentUser;
  final String avatarUrl;
  final homeState;
  final PageController _pageController = PageController();
  final TextEditingController _titleTextController = TextEditingController(),
      _bodyTextController = TextEditingController();
  final uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Icon(Icons.close, color: Colors.black, size: 30),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Create a post",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: "CircularStd",
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: 130,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Container(
                      height: 4,
                      color: Colors.indigo,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: 4,
                      color: Colors.yellow.shade700,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 4,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              if (_pageController.page == 0.0) {
                _pageController.animateToPage(1,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut);
              } else {
                var documentId = uuid.v1();
                var currentDate = DateTime.now();
                await Firestore.instance
                    .collection("story-collection")
                    .document(documentId)
                    .setData({
                  "author-uid": currentUser.uid,
                  "body": _bodyTextController.text,
                  "id": documentId,
                  "image-name": "",
                  "liked-by-people": [],
                  "title": _titleTextController.text,
                  "topics": [], // TODO: USE API that @NikhilCodes built.
                  "up-since": [
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                    currentDate.hour,
                    currentDate.minute,
                  ],
                });

                homeState.setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: 7),
              child: Center(
                child: Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        pageSnapping: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(left: 20, right: 20),
            children: <Widget>[
              SizedBox(height: 30),
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17.5),
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _titleTextController,
                      decoration: InputDecoration(
                        hintText: "Give a title to story",
                        hintStyle: TextStyle(
                          fontFamily: "Quicksand",
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade100,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 45),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: _bodyTextController,
                    maxLines: 20,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type your story here",
                      hintStyle: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade100,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17.5),
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Upload a pic",
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.blueGrey.shade300,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 45),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.photo_library,
                            color: Colors.yellow.shade700,
                            size: 28,
                          ),
                          SizedBox(width: 15),
                          Text(
                            "Upload from gallery",
                            style: TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.blueGrey.shade300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.add_a_photo,
                            color: Colors.blueAccent.shade700,
                            size: 28,
                          ),
                          SizedBox(width: 15),
                          Text(
                            "Take a pic",
                            style: TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.blueGrey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
