import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storyd/global_values.dart';

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
      height: MediaQuery.of(context).size.height * 0.30,
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
  StoryTile({this.data, this.currentUser});

  final data;
  final FirebaseUser currentUser;

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
      imageName = "",
      imageUrl = "",
      documentId = "";

  List likedByPeople = [];

  bool isLiked;

  @override
  void initState() {
    authorUid = widget.data["author-uid"];
    title = widget.data["title"];
    body = widget.data["body"];
    imageName = widget.data["image-name"];
    likedByPeople = widget.data["liked-by-people"];
    documentId = widget.data["id"];
    isLiked = likedByPeople.contains(widget.currentUser.uid);
    List activeSince = widget.data["up-since"];
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

    if (imageName != "") {
      FirebaseStorage.instance
          .ref()
          .child("story-images/$imageName")
          .getDownloadURL()
          .then((value) {
        setState(() {
          imageUrl = value;
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
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
                            fit: BoxFit.cover,
                            placeholder: (context, url) => SizedBox(
                              height: 20,
                              width: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          )
                        : Image.asset("assets/avatar.png"),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      author,
                      style: TextStyle(
                        fontFamily: "CircularStd",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
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
            (imageUrl != "")
                ? Hero(
                    tag: storyImageHeroTag + imageUrl,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        progressIndicatorBuilder: (context, url, progress) =>
                            SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Center(
                            child: CircularProgressIndicator(
                                value: progress.progress),
                          ),
                        ),
                      ),
                    ),
                  )
                : imageName != ""
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                      )
                    : Container(),
            SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                fontFamily: "Quicksand",
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 7),
            (imageName == "")
                ? Text(
                    body,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(
                      fontFamily: "CircularStd",
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade700,
                    ),
                  )
                : Container(),
            SizedBox(height: 13),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Image.asset(
                      isLiked ? "assets/like_fill.png" : "assets/like.png",
                      width: 25,
                      height: 25,
                    ),
                    onTap: () async {
                      DocumentReference postRef = Firestore.instance
                          .collection("story-collection")
                          .document(documentId);

                      if (likedByPeople.contains(widget.currentUser.uid)) {
                        setState(() {
                          isLiked = false;
                        });
                        likedByPeople =
                            (await postRef.get()).data["liked-by-people"];

                        setState(() {
                          likedByPeople.remove(widget.currentUser.uid);
                        });
                      } else {
                        setState(() {
                          isLiked = true;
                        });
                        likedByPeople =
                            (await postRef.get()).data["liked-by-people"];
                        setState(() {
                          likedByPeople.add(widget.currentUser.uid);
                        });
                      }
                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.update(postRef, {
                          "liked-by-people": likedByPeople,
                        });
                      });
                    },
                  ),
                  GestureDetector(
                    child: Image.asset("assets/comment.png",
                        width: 25, height: 25),
                    onTap: () {
                      // TODO: Adding comment section.
                    },
                  ),
                  GestureDetector(
                    child:
                        Image.asset("assets/share.png", width: 25, height: 25),
                    onTap: () {
                      // TODO: After friend section is done, sharing feature will be added.
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 7),
            Text("${likedByPeople.length} likes"),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StoryTileExpanded(
            avatarUrl: avatarUrl,
            authorName: author,
            upSince: timeSince,
            title: title,
            imageUrl: imageUrl,
            body: body,
            documentId: documentId,
            currentUser: widget.currentUser,
            isLiked: isLiked,
            likedByPeople: likedByPeople,
          ),
        ));
      },
    );
  }
}

class StoryTileExpanded extends StatefulWidget {
  StoryTileExpanded(
      {this.avatarUrl,
      this.authorName,
      this.upSince,
      this.title,
      this.body,
      this.imageUrl,
      this.documentId,
      this.isLiked,
      this.likedByPeople,
      this.currentUser});

  final String avatarUrl,
      authorName,
      upSince,
      title,
      body,
      documentId,
      imageUrl;
  final List likedByPeople;
  final bool isLiked;
  final FirebaseUser currentUser;

  @override
  State<StatefulWidget> createState() {
    return _StoryTileExpandedState();
  }
}

class _StoryTileExpandedState extends State<StoryTileExpanded> {
  List likedByPeople;
  String documentId;
  bool isLiked;

  @override
  void initState() {
    likedByPeople = widget.likedByPeople;
    documentId = widget.documentId;
    isLiked = widget.isLiked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 44,
              width: 44,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: widget.avatarUrl != ""
                    ? CachedNetworkImage(
                        imageUrl: widget.avatarUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.authorName,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "CircularStd",
                    fontSize: 20,
                  ),
                ),
                Text(
                  widget.upSince,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(left: 20, right: 20, top: 30),
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: "Quicksand",
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 40),
              (widget.imageUrl != "")
                  ? Hero(
                      tag: storyImageHeroTag + widget.imageUrl,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          progressIndicatorBuilder: (context, url, progress) =>
                              SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Center(
                              child: CircularProgressIndicator(
                                  value: progress.progress),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              widget.imageUrl != "" ? SizedBox(height: 30) : Container(),
              Text(
                widget.body,
                style: TextStyle(
                  fontFamily: "Quicksand",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 70,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.shade200,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        child: Image.asset(
                          isLiked ? "assets/like_fill.png" : "assets/like.png",
                          width: 25,
                          height: 25,
                        ),
                        onTap: () async {
                          DocumentReference postRef = Firestore.instance
                              .collection("story-collection")
                              .document(documentId);

                          if (likedByPeople.contains(widget.currentUser.uid)) {
                            setState(() {
                              isLiked = false;
                            });
                            likedByPeople =
                                (await postRef.get()).data["liked-by-people"];

                            setState(() {
                              likedByPeople.remove(widget.currentUser.uid);
                            });
                          } else {
                            setState(() {
                              isLiked = true;
                            });
                            likedByPeople =
                                (await postRef.get()).data["liked-by-people"];
                            setState(() {
                              likedByPeople.add(widget.currentUser.uid);
                            });
                          }
                          Firestore.instance
                              .runTransaction((transaction) async {
                            await transaction.update(postRef, {
                              "liked-by-people": likedByPeople,
                            });
                          });
                        },
                      ),
                      GestureDetector(
                        child: Image.asset("assets/comment.png",
                            width: 25, height: 25),
                        onTap: () {
                          // TODO: Adding comment section.
                        },
                      ),
                      GestureDetector(
                        child: Image.asset("assets/share.png",
                            width: 25, height: 25),
                        onTap: () {
                          // TODO: After friend section is done, sharing feature will be added.
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
