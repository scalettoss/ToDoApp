import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_final/Firebase/firebase_auth.dart';
import 'package:project_final/todo_app/model/topic_model.dart';
import 'package:project_final/todo_app/view/AddTaskPage.dart';
import 'package:project_final/todo_app/view/LoginPage.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController txtTopic = TextEditingController();
  String? userName;
  String? userPhotoUrl;
  String? userId;
  String? documentId;
  @override
  void initState() {
    super.initState();
    userName = AuthController.userName;
    userPhotoUrl = AuthController.userUrl;
    userId = AuthController.userId;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(onPressed: () {
            _showAddTopicDialog(context);
          }, icon: Icon(Icons.add))
        ],
      ),
      body: Expanded(
          child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: StreamBuilder<List<TopicSnapshot>>(
            stream: TopicSnapshot.getAll(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error Data"),);
              }
              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return Align(alignment: Alignment.center,child: Text("Bạn chưa tạo công việc!"));
              }
              List<TopicSnapshot> list = snapshot.data!;
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  var item = list[index];
                  if(item.topic.topicName != null)
                  {
                    return Card(
                      child: ListTile(
                        title: Text(item.topic.topicName ?? ""),
                        subtitle: Text('Created at: ${DateFormat('dd/MM/yy HH:mm').format(item.topic.createdAt!.toDate())}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await item.xoa();
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute
                            (builder: (context) => AddTask(docId: item.ref.id,)));
                        },
                      ),
                    );
                  }
                },
              );
            },
          )
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                    radius: 45,
                  ),
                  SizedBox(height: 10,),
                  Text(userName ?? "", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            ListTile(
              title: const Text('Đăng xuất'),
              onTap: () async {
                await AuthController.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showAddTopicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nhập chủ đề"),
          content: Container(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: txtTopic,
                  decoration: InputDecoration(
                    labelText: "Tên chủ đề",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                DocumentReference newDocumentRef;
                Navigator.of(context).pop();
                if(txtTopic != null){
                  newDocumentRef = await FirebaseFirestore.instance.collection("ToDoDB").add({
                    'topicName' : txtTopic.text,
                    'createdAt' : DateTime.now(),
                    'createdBy' : userId,
                  });
                  txtTopic.clear();
                }
              },
              child: Text('Thêm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng AlertDialog
                txtTopic.clear();
              },
              child: Text('Hủy'),

            ),
          ],
        );
      },
    );
  }
}