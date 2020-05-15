import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount account = await googleSignIn.signIn();

    if (account == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await account.authentication;

    // get the credentials to (access / id token)
    // to sign in via Firebase Authentication
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    print("Name: ${user.displayName}");
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: "storyd-splash",
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Material(
                    child: Text(
                      "Storyd",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 35,
                        fontFamily: "CircularStd",
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.13,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Image.asset("assets/storyd-splash.png"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome back",
                  style: TextStyle(
                    fontFamily: "CircularStd",
                    fontSize: 40,
                    color: Colors.orangeAccent,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "to ",
                      style: TextStyle(
                        fontFamily: "CircularStd",
                        fontSize: 40,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    Text(
                      "Storyd",
                      style: TextStyle(
                        fontFamily: "CircularStd",
                        fontSize: 40,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
            Expanded(
              child: Center(
                child: ButtonTheme(
                  height: 50,
                  minWidth: 220,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  buttonColor: Colors.black12,
                  child: RaisedButton(
                    elevation: 0,
                    highlightElevation: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset("assets/googleLogo.png"),
                        ),
                        SizedBox(width: 7),
                        Text(
                          "Connect with Google",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "CircularStd",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    onPressed: _handleSignIn,
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
