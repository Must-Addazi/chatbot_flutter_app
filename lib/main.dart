import 'package:chat_boot_app/chat_boot_page.dart';
import 'package:flutter/material.dart';
//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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
        indicatorColor: Colors.blue,
      ),
      routes: {"/chat": (context) => ChatBootPage()},
      home: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login page",
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: 500,
          width: 400,
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("images/logo.jfif")),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: loginController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.visibility),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        String username = loginController.text;
                        String password = passwordController.text;
                        if (username == "admin" && password == "1234") {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, "/chat");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        "Login In",
                        style: TextStyle(
                          color: Theme.of(context).indicatorColor,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
