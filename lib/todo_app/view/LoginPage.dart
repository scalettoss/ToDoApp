import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_final/Firebase/firebase_auth.dart';
import 'package:project_final/todo_app/view/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("WELCOME",style: TextStyle(
              color: Colors.red,
              fontSize: 25,
              fontWeight: FontWeight.bold
            ),),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset("images/loginbanner.jpg"),
            ),
            SignInButton(
              buttonType: ButtonType.google,
              buttonSize: ButtonSize.large,
              onPressed: () async {
                await AuthController.signInWithGoogle();
                if(AuthController.userName == null){
                  showMySnackBar(context, "Ối", "Đăng nhập thất bại", ContentType.failure);
                }
                else {
                  showMySnackBar(context, "Xin chào ${AuthController.userName}!", "Thêm công việc mà bạn muốn hoàn thành", ContentType.success);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
showMySnackBar(BuildContext context, String title, String message, ContentType type){
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: type),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,

        duration: Duration(seconds: 2),
      )
  );
}
