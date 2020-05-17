import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
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
        padding: EdgeInsets.all(20),
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
                            child:
                                Image.asset("assets/outline_arrow_right.png")),
                      ],
                    ),
                  ),
                  // Page 2
                  ListView(
                    physics: BouncingScrollPhysics(),
                    itemExtent: MediaQuery.of(context).size.height * 0.7,
                    padding: EdgeInsets.only(left: 30, top: 15),
                    children: <Widget>[
                      Column(
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
                          RaisedButton(
                            color: Colors.orangeAccent,
                            child:
                                Image.asset("assets/outline_arrow_right.png"),
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

                              DocumentReference userRef = Firestore.instance
                                  .collection("user-data")
                                  .document(user.uid);
                              Firestore.instance
                                  .runTransaction((transaction) async {
                                await transaction
                                    .set(userRef, <String, dynamic>{
                                  'preferredTopics': interestPool.interests,
                                  'name': _nameEditController.text,
                                  'history': [],
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
                        ],
                      ),
                    ],
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
