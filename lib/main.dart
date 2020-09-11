import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmail_only_login2/BaseAuth.dart';
import 'package:gmail_only_login2/model/MessageBubble.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'NextPage.dart';

GoogleSignInAccount _currentUser;
GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: "Google Sign in",
      home: GoogleSignpage(),
    ),
  );
}

class GoogleSignpage extends StatefulWidget {
  @override
  _GoogleSignpageState createState() => _GoogleSignpageState();
}

class _GoogleSignpageState extends State<GoogleSignpage> {
  final BaseAuth baseAuth = BaseAuth();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  bool showSpinner = false;
  FirebaseUser logginUser;
  String _userId = '';

  String message;
  final _messagecontroller = TextEditingController();

  @override
  void dispose() {
    _messagecontroller?.dispose();
  }

  void getcurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        setState(() {
          logginUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    messagesStream();
    getcurrentUser();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
  }

  void messagesStream() async {
    await for (var snapshop
        in _firestore.collection('$_currentUser').snapshots()) {}
  }

  // void getMessage() async {
  //   final querySnapshot = await _firestore.collection('data').getDocuments();
  //   for (var message in querySnapshot.docs) {
  //     print(message.data());
  //   }
  // }

  // Map data;
  // addData() {
  //   Map<String, dynamic> downdata = {
  //     "name": "$message",
  //     'motto': "${_currentUser.email}",
  //   };

  //   CollectionReference collectionReference =
  //       Firestore.instance.collection('data');
  //   collectionReference.add(downdata);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  // void messageStrem() async {
  //   await for (var snapshot in _firestore.collection('data').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data);
  //     }
  //   }
  // }

  Widget buildBody() {
    if (_currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentUser.email ?? ''),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await _handleSignOut();
              },
              icon: Icon(Icons.error),
            )
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: GoogleUserCircleAvatar(
                  identity: _currentUser,
                ),
                title: Text(_currentUser.displayName ?? ''),
                subtitle: Text(_currentUser.email ?? ''),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  controller: _messagecontroller,
                  onChanged: (value) {
                    message = value;
                  },
                  cursorColor: Theme.of(context).cursorColor,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: 'MMK',
                    labelStyle: TextStyle(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (message.trim() != '') {
                    _messagecontroller.clear();
                    _firestore.collection('${_currentUser.email}').add({
                      'text': message.trim(),
                      'sender': _currentUser.email,
                      'created': FieldValue.serverTimestamp(),
                    });
                  }
                },
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              FlatButton(
                onPressed: () {
                  messagesStream();
                },
                child: Text(
                  "Icons",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NextPage(user: _currentUser.email.toString()),
                      ));
                },
                child: Text("Next"),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('${_currentUser.email}')
                    .orderBy('created', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.blue),
                    );
                  }
                  final messages = snapshot.data.docs;

                  List<Widget> messageWidget = [];
                  for (var message in messages) {
                    final text = message.get('text');
                    final sender = message.get('sender');

                    final widget = MessageBubble(
                      currentUser: _currentUser,
                      text: text,
                    ); ////Text('$messageText from $sender')
                    messageWidget.add(widget);
                  }
                  return Column(
                    children: messageWidget,
                  );
                },
              ),
            ],
          ),
        ),

        //  showTodoList(),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     showAddTodoDialog();
        //   },
        //   tooltip: 'Increment',
        //   child: Icon(Icons.add),
        // ),
      );
    } else {
      return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("You are not Sign in...."),
              RaisedButton(
                onPressed: () async {
                  await _login();
                },
                child: Text("Sign In"),
              ),
            ],
          ),
        ),
      );
    }
  }
}

Future<void> _handleSingIn() async {
  try {
    await _googleSignIn.signInSilently();
  } catch (e) {
    print(e);
  }
}

_login() async {
  try {
    await _googleSignIn.signIn();
  } catch (e) {
    print(e);
  }
}

Future<void> _handleSignOut() async {
  try {
    await _googleSignIn.signOut();
  } catch (e) {
    print(e);
  }
}

showTodoList() {
  //  if (_todoList.length > 0) {}
}

showAddTodoDialog() {}
