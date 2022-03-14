import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/imagepacks.dart';
import 'package:terra_korwil/theme/pallete.dart';
import 'package:terra_korwil/theme/stateless.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: use_key_in_widget_constructors
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // FirebaseMessaging fm = FirebaseMessaging();
  static LocalStorage storageUser = LocalStorage('terra_app');
  @override
  void initState() {
    // fm.getToken().then((value) => print('Token : $value'));
    super.initState();
    // log("${storageUser.getItem('userpass')}");
    Timer(const Duration(milliseconds: 500), () {
      // Navigator.of(context).pop();
      decision();
      setThemeValue();
    });
  }

  bool internetOK = false;

  void setThemeValue() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    await storageUser.ready.then((value){
      if(storageUser.getItem('theme_config') == null){
        storageUser.setItem('theme_config', {'value' : 'light'});
        provider.toggleTheme(false);
      }else{
        if(storageUser.getItem('theme_config')['value'] == 'light'){
          provider.toggleTheme(false);
        }else{         
          provider.toggleTheme(true);
        }
      }
    });
  }

  void decision() async {
    internetOK = await InternetConnectionChecker().hasConnection;
    await storageUser.ready.then((value) {
      if (storageUser.getItem('userpass') == null) {
        Navigator.pushNamed(context, '/Login');
      } else {
        if (internetOK == true) {
          cekVersion();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mohon periksa koneksi internet anda.")));
        }
      }
    });
  }

  Future cekVersion() async {
    final http.Response response = await http.post(
        Uri.parse("https://api.terra-id.com/public"),
        body: {"target": 'apps', "type_submit": 'getVersion', "id": '3'});

    var status = jsonDecode(response.body);
    // log('$status');
    if (status[0]['code'] == versionCode) {
      cekLogin();
    } else {
      updateQuest();
    }
    return status;
  }

  Future updateQuest() async {
    const String _url = 'https://play.google.com/store/apps/details?id=com.terra.plapangan';
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pemberitahuan'),
            content: const Text("Tersedia aplikasi versi terbaru"),
            actions: <Widget>[
              TextButton(
                  child: const Text("Nanti saja"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    cekLogin();
                  }),
              TextButton(
                  child: const Text("Perbarui"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    launch(_url);
                      // throw 'Tidak dapat menjangkau $_url';
                  }),
            ],
          );
        });
  }

  void cekLogin() async {
    var cred = await storageUser.getItem('userpass');
    var user = cred['user'];
    var pass = cred['pass'];
    final http.Response response =
        await http.post(apiURI, body: {
      "username": user,
      "password": pass,
      "target": 'user_auth',
      "type_submit": 'loginKorwil'
    });
    // print('Response: ${response.body}');
    if (response.statusCode == 200) {
      var status = jsonDecode(response.body);
      if (status['status'] == 'success') {
        Navigator.pushNamed(context, '/Dashboard');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Dialogmodal(
              vartitle: "GAGAL",
              varcontent: "Email, No Hp, atau Password Salah",
            );
          },
        );
      }
    } else {
      // print("${response.statusCode}");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialogmodal(
            vartitle: "Mohon Maaf",
            varcontent: "Terjadi kesalahan",
          );
        },
      );
      Navigator.pushNamed(context, '/Login');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/patern.png"),
                fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Image.asset("assets/logo_TERRA_putih.png"),
              ),
            ],
          )),
    );
  }
}
