import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:storyd/global_values.dart';
import 'package:storyd/screens/special_widgets.dart';

class UserConfigPage extends StatelessWidget {
  final PageController _pageController = PageController();
  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _interestEditController = TextEditingController();

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
                                fontSize: 35,
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
                            Wrap(
                              children: interestsCollection
                                  .map(
                                    (interest) => TextBubble(
                                  text: interest,
                                  color: Colors.yellow.shade700,
                                ),
                              )
                                  .toList(),
                            ),
                          ],
                        ),
                        RaisedButton(
                            color: Colors.orangeAccent,
                            onPressed: () {},
                            child:
                                Image.asset("assets/outline_arrow_right.png")),
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
