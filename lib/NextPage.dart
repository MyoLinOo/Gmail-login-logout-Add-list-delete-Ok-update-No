import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model/todo.dart';

GoogleSignInAccount _currentUser;

class NextPage extends StatefulWidget {
  final String user;

  const NextPage({this.user});
  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Todo> _todoList;

  FirebaseDatabase _database = FirebaseDatabase.instance;

  final _textEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  @override
  void initState() {
    super.initState();
    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child('todo')
        .orderByChild('userId')
        .equalTo(widget.user);

    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Next Screem..."),
      ),
      body: showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddtodoDialog(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _todoList.length,
        itemBuilder: (BuildContext context, int index) {
          String todoId = _todoList[index].key;
          String subject = _todoList[index].subject; //////////////
          bool completed = _todoList[index].completed;

          return Dismissible(
            key: Key(todoId),
            background: Container(color: Colors.red),
            onDismissed: (direction) async => deleteTodo(todoId, index),
            child: ListTile(
              title: Text(
                subject,
                style: TextStyle(fontSize: 20),
              ),
              trailing: IconButton(
                icon: (completed)
                    ? Icon(Icons.done_outline, color: Colors.green)
                    : Icon(Icons.done, color: Colors.grey, size: 20),
                onPressed: () {
                  updateTodo(_todoList[index]);
                },
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          "Welcome.Your List is empty",
          style: TextStyle(fontSize: 30),
        ),
      );
    }
  }

  showAddtodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: 'Add new todo',
                ),
              ))
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            new FlatButton(
                onPressed: () {
                  addNewTodo(_textEditingController.text.toString());
                  Navigator.pop(context);
                },
                child: const Text("Save"))
          ],
        );
      },
    );
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child('todo').child(todoId).remove().then((value) {
      print('Delete $todoId successful');
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  updateTodo(Todo todo) {
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
    });
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
  }

  addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = new Todo(widget.user, todoItem.toString(), false);
      _database.reference().child('todo').push().set(todo.toJson());
    }
  }
}
