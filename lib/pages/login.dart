// import 'dart:convert';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/imagepacks.dart';
import 'package:terra_korwil/theme/stateless.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LocalStorage storageUser = LocalStorage('terra_app');
  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool obscr = true;

  Widget loginText = const Text(
    'Masuk',
    style: TextStyle(color: Colors.white),
  );
  @override
  void initState() {
    super.initState();
    // log("${storageUser.getItem('data_user_login')}");
  }

  void cekLogin() async {
    var user = controllerUser.text;
    var pass = controllerPass.text;
    final http.Response response = await http.post(apiURI, body: {
      "username": user,
      "password": pass,
      "target": 'user_auth',
      "type_submit": 'loginKorwil'
    });
    log('${response.body}');

    if (response.statusCode == 200) {
      var status = jsonDecode(response.body);
      if (status['status'] == 'success') {
        storageUser.setItem('userpass', {"user": user, "pass": pass});

        setState(() {
          loginText = const Text(
            'Masuk',
            style: TextStyle(color: Colors.white),
          );
        });
        await Navigator.pushNamed(context, '/Dashboard');
      } else {
        setState(() {
          loginText = const Text(
            'Masuk',
            style: TextStyle(color: Colors.white),
          );
        });
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(tipe: 'fail', label: 'Login gagal');
          },
        );
      }
    } else {
      // print("${response.statusCode}");
      setState(() {
        loginText = const Text(
          'Masuk',
          style: TextStyle(color: Colors.white),
        );
      });
      showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const DialogStatus(tipe: 'fail', label: 'Terjadi kesalahan');
        },
      );
    }
  }

  Future<bool> _exitQuest() {
    bool val = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Anda akan menutup aplikasi?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Tidak"),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                  child: const Text("Ya"),
                  onPressed: () {
                    setState(() {
                      val = true;
                    });
                    SystemNavigator.pop();
                  }
                  // onPressed: () => Navigator.pop(context, true),
                  ),
            ],
          );
        });
    return Future.value(val);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _exitQuest,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   title: Text('Login Screen App'),
        // ),
        // ignore: avoid_unnecessary_containers
        backgroundColor: Colors.white,
        body: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Column(
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 0),
                          height: MediaQuery.of(context).size.height * 0.45,
                          decoration: const BoxDecoration(
                            color: Color(0xFF088378),
                            // gradient: LinearGradient(
                            //   colors: [Color(0xFF088378), Color(0xFF088378)],
                            //   end: Alignment.topLeft,
                            //   begin: Alignment.bottomRight,
                            // ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 0),
                          height: MediaQuery.of(context).size.height * 0.45,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(100)),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/logo_TERRA_full_color.png",
                                scale: 1.8,
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Center(
                                  child: loginImage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.50,
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(100)),
                          color: Color(0xFF088378),
                        ),
                        child: Column(children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.fromLTRB(50, 50, 50, 10),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20),
                              )),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                            child: TextFormField(
                              controller: controllerUser,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white30,
                                labelText: "Email / No.Hp",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent)),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                            child: TextFormField(
                              obscureText: obscr,
                              controller: controllerPass,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white30,
                                labelText: "Kata sandi",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white)),
                                suffixIcon: IconButton(
                                    icon: const Icon(Icons.remove_red_eye,
                                        color: Colors.white),
                                    onPressed: () {
                                      if (obscr == true) {
                                        setState(() {
                                          obscr = false;
                                        });
                                      } else {
                                        setState(() {
                                          obscr = true;
                                        });
                                      }
                                    }),
                              ),
                            ),
                          ),
                          Container(
                            height: 80,
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                child: loginText,
                                color: Color(0XFFD92121),
                                onPressed: () {
                                  setState(() {
                                    loginText = const Center(
                                        child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ));
                                  });
                                  cekLogin();
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  // ignore: avoid_unnecessary_containers
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
