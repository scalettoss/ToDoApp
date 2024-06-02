import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_final/Firebase/widget_connect_firebase.dart';
import 'package:project_final/todo_app/controller/task_controller.dart';
import 'package:project_final/todo_app/view/HomePage.dart';
import 'package:project_final/todo_app/view/LoginPage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskController()),
      ],
      child: MaterialApp(
        title: 'Home Todo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyFirebaseConnect(
          errorMessage: "Kết nối không thành công",
          connectingMessage: "Đang kết nối",
          builder: (context) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return HomePage();
                }
                else return LoginPage();
              },
            );
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}