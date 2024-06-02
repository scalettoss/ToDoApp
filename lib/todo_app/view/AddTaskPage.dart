

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_final/todo_app/model/task_model.dart';

class AddTask extends StatefulWidget {
  final String? docId;
  AddTask({Key? key, required this.docId}) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController txtTaskName = TextEditingController();
  TextEditingController txtDateTimeController  = TextEditingController();
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm nhiệm vụ"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            width: MediaQuery.of(context).size.width,
            height:100,
            child: TextFormField(
              controller: txtTaskName,
              decoration: InputDecoration(
                labelText: "Nhập công việc cần làm",
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue
                )

              ),
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Vui long nhap nhiem vu';
                }
                return null;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: TextFormField(
              controller: txtDateTimeController,
              decoration: InputDecoration(
                labelText: "Thời gian đáo hạn",
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              onTap: () {
                _selectDateTime();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập nhiệm vụ';
                }
                return null;
              },
            ),
          ),
          Expanded(
              child: StreamBuilder<List<TaskSnapShot>>(
                stream: TaskSnapShot.getAll(widget.docId!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error Data"),);
                  }
                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return Align(alignment: Alignment.center,child: Text("Bạn chưa tạo công việc!"));
                  }
                  List<TaskSnapShot> list = snapshot.data!;

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      var item = list[index];
                      return Dismissible(
                          key: Key(item.toDoTask.taskName!),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            await item.xoa();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa 1 nhiệm vụ'),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            trailing: Checkbox(
                              value: item.toDoTask.isCompleted!,
                              onChanged: (value) async {
                                setState(() {
                                  item.toDoTask.isCompleted = value;
                                });
                                await item.updateTaskStatus(item.ref, value!);
                              },
                            ),
                            title: Text(item.toDoTask.taskName!,
                              style: TextStyle(
                                decoration: item.toDoTask.isCompleted! ? TextDecoration.lineThrough : TextDecoration.none,
                              ),),
                            subtitle: Text('Đến hạn: ${DateFormat('dd/MM/yy HH:mm').format(item.toDoTask.dueTime!.toDate())}'),
                          ));
                    },
                  );
                },
              )
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  if(txtTaskName.text.isNotEmpty && txtDateTimeController.text.isNotEmpty){
                    FirebaseFirestore.instance
                        .collection("ToDoDB")
                        .doc(widget.docId)
                        .collection("SubTopic")
                        .add({
                      'taskName': txtTaskName.text,
                      'isCompleted': false,
                      'dueTime': Timestamp.fromDate(selectedDateTime!),
                    });
                    txtTaskName.clear();
                    txtDateTimeController.clear();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _selectDateTime() async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          txtDateTimeController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!);
        });
      }
    }
  }

  @override
  void dispose() {
    txtDateTimeController.dispose();
    super.dispose();
  }
}
