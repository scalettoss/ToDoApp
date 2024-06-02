
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_final/Firebase/firebase_auth.dart';

class Topic{
  String? topicName, createdBy;
  Timestamp? createdAt;

  Topic({
    required this.topicName,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJSon() {
    return {
      'topicName': this.topicName,
      'createdBy': this.createdBy,
      'createdAt': this.createdAt,
    };
  }

  factory Topic.fromJson(Map<String, dynamic> map) {
    return Topic(
      topicName: map['topicName'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}
class TopicSnapshot{
  Topic topic;
  DocumentReference ref;
  TopicSnapshot({
    required this.topic,
    required this.ref,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': this.topic,
      'ref': this.ref,
    };
  }
  factory TopicSnapshot.fromMap(DocumentSnapshot docSnap){
    return TopicSnapshot(topic: Topic.fromJson(docSnap.data() as Map<String, dynamic>), ref: docSnap.reference);
  }
  Future<void> xoa(){
    return ref.delete();
  }
  Future<void> updateTopicName(String newTopicName, DocumentReference ref) {
    return ref.update({'topicName': newTopicName});
  }
  static Stream<List<TopicSnapshot>> getAll(){
    Stream<QuerySnapshot> sqs = FirebaseFirestore.instance.collection("ToDoDB").where("createdBy", isEqualTo: AuthController.userId).snapshots();
    return sqs.map((qs) => qs.docs.map((docSnap) => TopicSnapshot.fromMap(docSnap)).toList());
  }
}