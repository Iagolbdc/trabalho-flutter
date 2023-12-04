import 'dart:convert';

import 'package:app_trabalho/src/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:velocity_x/velocity_x.dart';
import '../config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String _errors = "";

  bool _isNotValidate = false;

  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        usernameController.text.isNotEmpty) {
      var body = {
        "email": emailController.text,
        "username": usernameController.text,
        "password": passwordController.text,
      };

      var response = await http.post(
        Uri.parse(registration),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode(body),
      );

      var jsonResponse = jsonDecode(response.body);

      print("####");
      print(jsonResponse);
      print("####");

      if (jsonResponse['message'] == "success") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        _displayTextInputDialog(context);
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  HeightBox(10),
                  "Criar nova conta".text.size(22).black.make(),
                  HeightBox(50),
                  TextField(
                    controller: usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.black),
                        errorText:
                            _isNotValidate ? "Preencha este campo" : null,
                        hintText: "Username",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.black),
                        errorText:
                            _isNotValidate ? "Preencha este campo" : null,
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            final data =
                                ClipboardData(text: passwordController.text);
                            Clipboard.setData(data);
                          },
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.password),
                          onPressed: () {
                            String passGen = "generatePassword";
                            passwordController.text = passGen;
                            setState(() {});
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.black),
                        errorText:
                            _isNotValidate ? "Preencha este campo" : null,
                        hintText: "Password",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  HStack([
                    GestureDetector(
                      onTap: () => {registerUser()},
                      child: VxBox(
                              child: "Register".text.white.makeCentered().p16())
                          .green600
                          .roundedLg
                          .make()
                          .px16()
                          .py16(),
                    ),
                  ]),
                  GestureDetector(
                    onTap: () {
                      print("Sign In");
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: HStack([
                      "Já tem conta?".text.make(),
                      " Entre".text.black.make()
                    ]).centered(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Deu erro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("exit"))
            ],
          ),
        );
      },
    );
  }
}
