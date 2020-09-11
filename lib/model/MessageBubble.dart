import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Firestore _firestore;

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {@required GoogleSignInAccount currentUser, this.text, this.updatText})
      : _currentUser = currentUser;

  final GoogleSignInAccount _currentUser;
  final String updatText;
  final String text;

  @override
  Widget build(BuildContext context) {
    String updateText;
    return new Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: MaterialButton(
        minWidth: 300,
        height: 70,
        color: Colors.blue,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                Dialog(
                  child: Container(
                    color: Colors.brown,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        TextFormField(
                          onChanged: (value) {
                            updateText = value;
                          },
                          cursorColor: Theme.of(context).cursorColor,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'MMK',
                            labelStyle: TextStyle(),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        RaisedButton(
                          child: Text("Update"),
                          onPressed: updateData(updateText),
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: ListTile(
          leading: GoogleUserCircleAvatar(
            identity: _currentUser,
          ),
          title: Text(
            "${text}" ?? '',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  // Future<bool> updateDialog(BuildContext context, String updateText) async {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text(
  //             "Data",
  //             style: TextStyle(fontSize: 15),
  //           ),
  //           content: Column(
  //             children: <Widget>[
  //               TextField(
  //                 decoration:
  //                     InputDecoration(hintText: "Enter your update data"),
  //                 onChanged: (value) {
  //                   updateText = value;
  //                 },
  //               )
  //             ],
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text("update"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }

  updateData(String updateT) async {
    CollectionReference collectionReference =
        Firestore.instance.collection('${_currentUser.email}');
    QuerySnapshot querySnapshot = await collectionReference.getDocuments();
    querySnapshot.docs[0].reference.update({'text': "a", "text": "$updateT"});
  }

  deleteData() async {
    CollectionReference collectionReference =
        Firestore.instance.collection('${_currentUser.email}');
    QuerySnapshot querySnapshot = await collectionReference.getDocuments();
    querySnapshot.docs[0].reference.delete();
  }
}
