import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:storyd/data_models/posts_data/posts_data.dart';
import 'package:storyd/screens/create_post.dart';
import 'package:storyd/screens/special_widgets.dart';

PostData posts = PostData();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser user;
  int homePageIndex = 0;
  Firestore firestore = Firestore.instance;
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot lastDocumentFetchedOnScroll, lastDocumentFetchedOnRefresh;
  int documentLimit = 4;
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController();
  PanelController _panelController = PanelController();

  List<Widget> friendListWidgets = [];

  Future fetchPosts() async {
    if (!hasMore) {
      print("No more posts");
      return false;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (lastDocumentFetchedOnScroll == null) {
      querySnapshot = await firestore
          .collection('story-collection')
          .orderBy('up-since', descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection('story-collection')
          .orderBy('up-since', descending: true)
          .startAfterDocument(lastDocumentFetchedOnScroll)
          .limit(documentLimit)
          .getDocuments();
    }
    if (querySnapshot.documents.length < documentLimit) {
      hasMore = false;
    }

    lastDocumentFetchedOnScroll = querySnapshot.documents.length != 0
        ? querySnapshot.documents[querySnapshot.documents.length - 1]
        : lastDocumentFetchedOnScroll;
    lastDocumentFetchedOnRefresh = querySnapshot.documents.length != 0
        ? querySnapshot.documents[0]
        : lastDocumentFetchedOnRefresh;
    posts.addAllItems(querySnapshot.documents);
    setState(() {
      isLoading = false;
    });

    return true;
  }

  Future<void> onPostHomeRefresh() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (lastDocumentFetchedOnRefresh == null) {
      querySnapshot = await firestore
          .collection('story-collection')
          .orderBy('up-since', descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection('story-collection')
          .orderBy('up-since', descending: true)
          .endBeforeDocument(lastDocumentFetchedOnRefresh)
          .limit(documentLimit)
          .getDocuments();
    }

    lastDocumentFetchedOnRefresh = querySnapshot.documents.length != 0
        ? querySnapshot.documents[0]
        : lastDocumentFetchedOnRefresh;

    posts.insertAllItems(0, querySnapshot.documents);
    setState(() {
      isLoading = false;
    });
  }

  startUpJobs() async {
    fetchPosts();

    CollectionReference userDataCollection = firestore.collection("user-data");
    var myUserInfo = await userDataCollection.document(user.uid).get();
    List<Widget> _friendListWidgets = [];
    myUserInfo.data["friend-list"].forEach((id) async {
      var friendUserInfo = await userDataCollection.document(id).get();

      _friendListWidgets.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: friendUserInfo.data["avatar-url"] != ""
                      ? CachedNetworkImage(
                          imageUrl: friendUserInfo.data["avatar-url"],
                          fit: BoxFit.cover,
                        )
                      : Image.asset("assets/avatar.png"),
                ),
              ),
              SizedBox(width: 10),
              Text(friendUserInfo.data["name"]),
            ],
          ),
        ),
      );
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

    _scrollController.addListener(slideToHideListenerFunction);
    super.initState();
  }

  slideToHideListenerFunction() {
    double currentScroll = _scrollController.position.pixels;
    double deviceHeight = MediaQuery.of(context).size.height;
    double sensitivity = 2.0;

    double panelPosition = 1 - currentScroll / (deviceHeight / sensitivity);

    if (!(0.0 <= panelPosition && panelPosition <= 1.0)) {
      _panelController.close();
      return;
    }

    _panelController.panelPosition = panelPosition;
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
                SafeArea(
                  child: posts.length == 0
                      ? Center(
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Observer(
                          builder: (context) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height - 20,
                              child: SmartRefresher(
                                enablePullDown: true,
                                enablePullUp: true,
                                controller: _refreshController,
                                header: WaterDropMaterialHeader(
                                  distance: 60,
                                  backgroundColor: Colors.black,
                                ),
                                footer: CustomFooter(
                                  builder: (context, mode) {
                                    Widget body;
                                    if (mode == LoadStatus.idle) {
                                      body = Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.arrow_upward),
                                            SizedBox(width: 20),
                                            Text(
                                              "Pull up load!",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (mode == LoadStatus.loading) {
                                      body = Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            SizedBox(width: 20),
                                            Text(
                                              "Loading more posts...",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (mode == LoadStatus.failed) {
                                      body = Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.close),
                                            SizedBox(width: 20),
                                            Text(
                                              "Failed",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (mode == LoadStatus.canLoading) {
                                      body = Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.arrow_upward),
                                            SizedBox(width: 20),
                                            Text(
                                              "Pull up to load",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      body = Center(
                                        child: Text(
                                          "No more posts!",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }
                                    return body;
                                  },
                                ),
                                onRefresh: () async {
                                  await onPostHomeRefresh();
                                  print("Refresh Completed!");
                                  _refreshController.refreshCompleted();
                                },
                                onLoading: () async {
                                  bool status = await fetchPosts();
                                  if (status == true) {
                                    _refreshController.loadComplete();
                                  } else if (status == false) {
                                    _refreshController.loadNoData();
                                  } else {
                                    _refreshController.loadFailed();
                                  }
                                },
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    top: 20,
                                  ),
                                  cacheExtent:
                                      MediaQuery.of(context).size.height * 4,
                                  // Equivalent to 4 page caching
                                  itemCount: posts.length + 2,
                                  controller: _scrollController,
                                  // +2 for SearchBar and BottomEmptyBlock
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return HomePageSearchBar();
                                    } else if (index == posts.length + 1) {
                                      return SizedBox(height: 20);
                                    }
                                    return KeyedSubtree(
                                      child: StoryTile(
                                        data: posts.posts[index - 1].data,
                                        currentUser: user,
                                      ),
                                      key: Key(
                                          "${posts.posts[index - 1].documentID}"),
                                    );
                                  },
                                ),
                              ),
                            );
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
            panelController: _panelController,
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
      @required this.panelController,
      this.onBottomBarAction});

  final State homeState;
  final FirebaseUser currentUser;
  final PanelController panelController;
  final Function(int) onBottomBarAction;

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationBarState();
  }
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  String avatarUrl;
  int activeSelectionIndex = 0;
  double bottomNavigatorMaxHeight = 90;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.panelController.open();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: 25,
      maxHeight: bottomNavigatorMaxHeight,
      controller: widget.panelController,
      panel: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: bottomNavigatorMaxHeight,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30)]),
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.all(10),
                  height: 7,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Home
                  GestureDetector(
                    child: Icon(Icons.home,
                        size: 28,
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
                        size: 28,
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
                    onTap: () async {
                      var newPost = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewPostField(
                            avatarUrl: avatarUrl,
                            currentUser: widget.currentUser,
                            homeState: widget.homeState,
                          ),
                        ),
                      );

                      if (newPost != null) posts.insertItem(0, newPost);
                    },
                  ),
                  // Direct Messages
                  GestureDetector(
                    child: Icon(Icons.chat_bubble_outline,
                        size: 28,
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
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: activeSelectionIndex == 3
                            ? Colors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 26,
                          width: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              width: 2,
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
                                    child: avatarUrl != ""
                                        ? CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: avatarUrl,
                                          )
                                        : Image.asset("assets/avatar.png"),
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
            ],
          ),
        ),
      ),
    );
  }
}
