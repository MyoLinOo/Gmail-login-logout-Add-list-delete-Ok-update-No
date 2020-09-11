import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignInAccount _currentUser;

class Todo {
  String key;
  String userId;
  String subject;
  bool completed;

  Todo(this.userId, this.subject, this.completed);

  Todo.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        userId = snapshot.value['userId'],
        subject = snapshot.value["subject"],
        completed = snapshot.value["completed"];

  toJson() {
    return {
      'userId': userId,
      "subject": subject,
      "completed": completed,
    };
  }
}
