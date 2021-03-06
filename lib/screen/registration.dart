import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_password_login/model/user_model.dart';
import 'package:email_password_login/screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_password_login/screen/login.dart';

class Reg extends StatefulWidget {
  @override
  _RegState createState() => _RegState();
}

class _RegState extends State<Reg> {
  final _formkey = GlobalKey<FormState>();

  final usernameController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool _secure = false;
  bool _passshow = true;

  showhide() {
    setState(() {
      _secure = !_secure;
      _passshow = !_passshow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Container(
                    child: Image.asset('images/logo.png'),
                    height: 100,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameController,
                          onSaved: (value) {
                            usernameController.text = value!;
                          },
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{3,}$');
                            if (value!.isEmpty) {
                              return ("Name cannot be empty");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Enter a valid name(min 3 characters)");
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.teal,
                          ),
                          cursorColor: Colors.teal,
                          cursorHeight: 22.0,
                          autofocus: false,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.teal,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.teal)),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: emailController,
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please enter your email");
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please enter a valid email");
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.teal,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.teal,
                          cursorHeight: 22.0,
                          autofocus: false,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.teal,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.teal)),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: passwordController,
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return ("Password is required for login");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Enter valid password(min 6 characters)");
                            }
                          },
                          style: TextStyle(color: Colors.teal),
                          cursorColor: Colors.teal,
                          cursorHeight: 22.0,
                          autofocus: false,
                          obscureText: _passshow,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            prefixIcon: Icon(
                              Icons.vpn_key,
                              color: Colors.teal,
                            ),
                            suffixIcon: IconButton(
                              onPressed: showhide,
                              icon: Icon(
                                _secure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.teal,
                              ),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        elevation: 15.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        signup(emailController.text, passwordController.text);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          'SignUp',
                          style: TextStyle(
                              color: Colors.lime[200],
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.teal),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Text(
                          ' LogIn',
                          style: TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signup(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postdetails()})
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

  postdetails() async {
    FirebaseFirestore firebasefirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel usermodel = UserModel();

    usermodel.email = user!.email;
    usermodel.uid = user.uid;
    usermodel.username = usernameController.text;

    await firebasefirestore
        .collection('users')
        .doc(user.uid)
        .set(usermodel.toMap());
    Fluttertoast.showToast(msg: "Account created successfully");

    Navigator.pushAndRemoveUntil((context),
        MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }
}
