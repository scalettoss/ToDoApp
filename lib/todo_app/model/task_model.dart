
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String name;
  bool isCompleted;
  Task({required this.name, this.isCompleted = false});
}

class ToDoTask{
  String? taskName;
  bool? isCompleted;
  Timestamp? dueTime;

  ToDoTask({
    required this.taskName,
    required this.isCompleted,
    required this.dueTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskName': this.taskName,
      'isCompleted': this.isCompleted,
      'dueTime': this.dueTime,
    };
  }

  factory ToDoTask.fromJson(Map<String, dynamic> map) {
    return ToDoTask(
      taskName: map['taskName'] as String,
      isCompleted: map['isCompleted'] as bool,
      dueTime: map['dueTime'] as Timestamp,
    );
  }
}
class TaskSnapShot{
  ToDoTask toDoTask;
  DocumentReference ref;

  TaskSnapShot({
    required this.toDoTask,
    required this.ref,
  });

  Map<String, dynamic> toMap() {
    return {
      'toDoTask': this.toDoTask,
      'ref': this.ref,
    };
  }

  factory TaskSnapShot.fromMap(DocumentSnapshot docSnap){
    return TaskSnapShot(toDoTask: ToDoTask.fromJson(docSnap.data() as Map<String, dynamic>), ref: docSnap.reference);
  }
  Future<void> xoa(){
    return ref.delete();
  }
  static Stream<List<TaskSnapShot>> getAll(String docId) {
    Stream<QuerySnapshot> sqs = FirebaseFirestore.instance
        .collection("ToDoDB")
        .doc(docId)
        .collection("SubTopic")
        .snapshots();
    return sqs.map((qs) => qs.docs.map((docSnap) => TaskSnapShot.fromMap(docSnap)).toList());
  }
   Future<void> updateTaskStatus(DocumentReference ref, bool isCompleted) async {
    await ref.update({'isCompleted': isCompleted});
  }
}
