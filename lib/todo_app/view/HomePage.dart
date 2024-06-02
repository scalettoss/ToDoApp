import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_final/Firebase/firebase_auth.dart';
import 'package:project_final/todo_app/model/topic_model.dart';
import 'package:project_final/todo_app/view/AddTaskPage.dart';
import 'package:project_final/todo_app/view/LoginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

Widget _changeTopicName(var item) {
  String name = item.topic.topicName;
  return TextField(
      decoration: const InputDecoration(label: Text("Nhập tên todo")),
      onSubmitted: (value) {
        item.topic.topicName = value;
      });
}

class _HomePageState extends State<HomePage> {
  TextEditingController txtTopic = TextEditingController();
  String? userName;
  String? userPhotoUrl;
  String? userId;
  String? documentId;
  bool _isEditing = false;
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
          IconButton(
              onPressed: () {
                _showAddTopicDialog(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: StreamBuilder<List<TopicSnapshot>>(
                  stream: TopicSnapshot.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error Data"),
                      );
                    }
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Align(
                          alignment: Alignment.center,
                          child: Text("Bạn chưa tạo công việc!"));
                    }
                    List<TopicSnapshot> list = snapshot.data!;
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        var item = list[index];
                        if (item.topic.topicName != null) {
                          return Card(
                            child: ListTile(
                              title: _isEditing
                                  ? TextField(
                                      controller: TextEditingController(
                                          text: item.topic.topicName),
                                      onSubmitted: (value) {
                                        setState(() async {
                                          item.topic.topicName = value;
                                          _isEditing = !_isEditing;
                                          await item.updateTopicName(value);
                                        });
                                      },
                                    )
                                  : Text(item.topic.topicName ?? "Chưa có tên"),
                              subtitle: Text(
                                  'Tạo lúc: ${DateFormat('dd/MM/yy HH:mm').format(item.topic.createdAt!.toDate())}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = !_isEditing;
                                      });
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddTask(
                                              docId: item.ref.id,
                                            )));
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                )),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: userPhotoUrl != null
                        ? NetworkImage(userPhotoUrl!)
                        : null,
                    radius: 45,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    userName ?? "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
          title: const Text("Nhập Todo"),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: txtTopic,
                  decoration: const InputDecoration(
                    labelText: "Tên Todo",
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
                newDocumentRef =
                    await FirebaseFirestore.instance.collection("ToDoDB").add({
                  'topicName': txtTopic.text,
                  'createdAt': DateTime.now(),
                  'createdBy': userId,
                });
                txtTopic.clear();
              },
              child: const Text('Thêm'),
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
