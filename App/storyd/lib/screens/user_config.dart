import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyd/global_values.dart';
import 'package:storyd/screens/home.dart';
import 'package:storyd/screens/special_widgets.dart';

class InterestPool {
  List<String> interests = [];

  void remove(String interest) {
    interests.removeWhere((element) => element == interest);
  }

  void add(String interest) {
    interests.insert(0, interest);
  }
}

class UserConfigPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserConfigPageState();
  }
}

class UserConfigPageState extends State<UserConfigPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _interestEditController = TextEditingController();
  final interestPool = InterestPool();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  var avatarImage;
  bool savingConfigData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startUpJobs());
  }

  startUpJobs() async {
    user = await _auth.currentUser();
    setState(() {
      _nameEditController.text = user.displayName;
    });
  }

  void addToInterestPool() {
    setState(() {
      if (interestPool.interests
          .contains(_interestEditController.text.toLowerCase())) {
        return;
      }
      interestPool.add(_interestEditController.text.toLowerCase());
      _interestEditController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text(
              "Storyd",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 35,
                fontFamily: "CircularStd",
                letterSpacing: 2,
              ),
            ),
            Expanded(
              child: PageView(
                pageSnapping: true,
                physics: BouncingScrollPhysics(),
                controller: _pageController,
                children: <Widget>[
                  // Page 1
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Tell us your",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontSize: 35,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "name",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontSize: 35,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _nameEditController,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Your Name",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: Colors.orangeAccent,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 800),
                              curve: Curves.easeOutExpo,
                            );
                          },
                          child: Icon(
                            Icons.trending_flat,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Page 2
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Add an",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontSize: 35,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "avatar",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontSize: 35,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              height: 180,
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      height: 130,
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(20),
                                      color: Colors.black.withOpacity(0.03),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          "A picture helps the community to know you more.",
                                          style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 110,
                                    width: 110,
                                    margin: EdgeInsets.only(left: 20),
                                    child: Stack(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: avatarImage == null
                                                ? Image.asset(
                                                    "assets/avatar.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    avatarImage,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: GestureDetector(
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              child: Center(
                                                  child: Icon(Icons.add_a_photo,
                                                      color: Colors.white)),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(22.5),
                                              ),
                                            ),
                                            onTap: () async {
                                              var image =
                                                  await ImagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              setState(() {
                                                avatarImage = image;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                child: Transform.rotate(
                                  angle: pi,
                                  child: Icon(
                                    Icons.trending_flat,
                                    color: Colors.black,
                                    size: 35,
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _pageController.animateToPage(
                                    0,
                                    duration: Duration(milliseconds: 800),
                                    curve: Curves.easeOutExpo,
                                  );
                                },
                              ),
                            ),
                            RaisedButton(
                              color: Colors.orangeAccent,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _pageController.animateToPage(
                                  2,
                                  duration: Duration(milliseconds: 800),
                                  curve: Curves.easeOutExpo,
                                );
                              },
                              child: Icon(
                                Icons.trending_flat,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Page 3
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Tell us about your",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontSize: 30,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "interests",
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontSize: 35,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              onSubmitted: (_) => addToInterestPool(),
                              onChanged: (value) {
                                if (value.endsWith(' ') ||
                                    value.endsWith(',')) {
                                  setState(() {
                                    _interestEditController.text =
                                        value.substring(0, value.length - 1);
                                    addToInterestPool();
                                  });
                                }
                              },
                              controller: _interestEditController,
                              style: TextStyle(
                                fontFamily: "Quicksand",
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "e.g. music, sports, ...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                ),
                                suffixIcon: GestureDetector(
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 30,
                                  ),
                                  onTap: addToInterestPool,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 7),
                            Wrap(
                              children: interestPool.interests
                                  .map(
                                    (interest) => TagTextBubble(
                                      text: interest,
                                      color: Colors.yellow.shade700,
                                      tagPool: interestPool,
                                      parent: this,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                child: Transform.rotate(
                                  angle: pi,
                                  child: Icon(
                                    Icons.trending_flat,
                                    color: Colors.black,
                                    size: 35,
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _pageController.animateToPage(
                                    1,
                                    duration: Duration(milliseconds: 800),
                                    curve: Curves.easeOutExpo,
                                  );
                                },
                              ),
                            ),
                            RaisedButton(
                              color: Colors.orangeAccent,
                              child: Icon(
                                Icons.trending_flat,
                                color: Colors.white,
                                size: 35,
                              ),
                              onPressed: () async {
                                // Check if name is provided
                                if (_nameEditController.text.trim() == '') {
                                  _pageController.animateToPage(
                                    0,
                                    duration: Duration(milliseconds: 800),
                                    curve: Curves.easeOutExpo,
                                  );
                                  return;
                                }
                                //

                                setState(() {
                                  savingConfigData = true;
                                });
                                DocumentReference userRef = Firestore.instance
                                    .collection("user-data")
                                    .document(user.uid);

                                var avatarUrl = "";
                                if (avatarImage != null) {
                                  String avatarImageFileName =
                                      "avatar_${user.uid}.${avatarImage.path.split('.').last}";
                                  StorageReference reference =
                                      FirebaseStorage.instance.ref().child(
                                          "user-avatars/$avatarImageFileName");

                                  StorageUploadTask uploadTask =
                                      reference.putFile(avatarImage);
                                  StorageTaskSnapshot taskSnapshot =
                                      await uploadTask.onComplete;
                                  avatarUrl =
                                      await taskSnapshot.ref.getDownloadURL();
                                }
                                Firestore.instance
                                    .runTransaction((transaction) async {
                                  await transaction
                                      .set(userRef, <String, dynamic>{
                                    'preferredTopics': interestPool.interests,
                                    'name': _nameEditController.text,
                                    'avatar-url': avatarUrl,
                                  });
                                });

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool(isLoggedInPrefKey, true);

                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => MyHomePage(),
                                ));
                              },
                            ),
                            SizedBox(width: 20),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: savingConfigData
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.black),
                                    )
                                  : Container(),
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
      ),
    );
  }
}
