import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TagTextBubble extends StatefulWidget {
  TagTextBubble({this.text, this.color, this.tagPool, this.parent});

  final String text;
  final Color color;
  final tagPool;
  final parent;

  @override
  State<StatefulWidget> createState() {
    return _TagTextBubbleState();
  }
}

class _TagTextBubbleState extends State<TagTextBubble>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedContainer(
        height: 30,
        width: (14 * widget.text.length).toDouble(),
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        duration: Duration(milliseconds: 200),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Quicksand",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      onTap: () {
        widget.parent.setState(() {
          widget.tagPool.remove(widget.text);
        });
      },
    );
  }
}

class HomePageSearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageSearchBarState();
  }
}

class _HomePageSearchBarState extends State<HomePageSearchBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Explore",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: "CircularStd",
                fontSize: 38,
              ),
            ),
            SizedBox(
              height: 55,
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "Quicksand",
                  fontSize: 25,
                ),
                showCursor: true,
                cursorWidth: 1,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(2),
                  hintText: "Search",
                  filled: true,
                  fillColor: Color.fromRGBO(140, 140, 200, 0.13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      color: Colors.transparent,
                      style: BorderStyle.none,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      color: Colors.transparent,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryTile extends StatefulWidget {
  StoryTile({this.data});

  final data;

  @override
  State<StatefulWidget> createState() {
    return _StoryTileState();
  }
}

class _StoryTileState extends State<StoryTile> {
  String authorUid = "",
      author = "",
      title = "",
      body = "",
      timeSince = "",
      avatarUrl = "",
      imageUrl = "";

  @override
  void initState() {
    authorUid = widget.data["author-uid"];
    title = widget.data["title"];
    body = widget.data["body"];
    List activeSince = widget.data["up_since"];
    DateTime timeNow = DateTime.now();
    DateTime activeSinceDT = DateTime(activeSince[0], activeSince[1],
        activeSince[2], activeSince[3], activeSince[4]);
    Duration timeDiff = timeNow.difference(activeSinceDT);
    if (timeDiff.inDays >= 365) {
      if (timeDiff.inDays ~/ 365 == 1) {
        timeSince = "A year ago";
      } else {
        timeSince = "${timeDiff.inDays ~/ 365} years ago";
      }
    } else if (timeDiff.inDays >= 30) {
      if (timeDiff.inDays ~/ 30 == 1) {
        timeSince = "A month ago";
      } else {
        timeSince = "${timeDiff.inDays ~/ 30} months ago";
      }
    } else if (timeDiff.inDays >= 1) {
      if (timeDiff.inDays == 1) {
        timeSince = "A day ago";
      } else {
        timeSince = "${timeDiff.inDays} days ago";
      }
    } else if (timeDiff.inHours >= 1) {
      if (timeDiff.inHours == 1) {
        timeSince = "An hour ago";
      } else {
        timeSince = "${timeDiff.inHours} hours ago";
      }
    } else if (timeDiff.inMinutes >= 0) {
      if (timeDiff.inMinutes <= 15) {
        timeSince = "Just Now";
      } else {
        timeSince = "Few minutes ago";
      }
    }

    Firestore.instance
        .collection("user-data")
        .document(authorUid)
        .get()
        .then((DocumentSnapshot ds) {
      setState(() {
        author = ds.data["name"];
        avatarUrl = ds.data["avatar-url"];
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: avatarUrl != ""
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          placeholder: (context, url) =>
                              SizedBox(
                                height: 20,
                                width: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                        )
                      : Container(),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    author,
                    style: TextStyle(
                      fontFamily: "Quicksand",
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    timeSince,
                    style: TextStyle(
                      fontFamily: "Quicksand",
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          (imageUrl != "") ? Image.network(imageUrl) : Container(),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Quicksand",
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          (imageUrl == "")
              ? Text(
                  body,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  style: TextStyle(
                      fontFamily: "CircularStd",
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade700),
                )
              : Container(),
        ],
      ),
    );
  }
}
