import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';

class FormPokja extends StatefulWidget {
  const FormPokja({Key? key}) : super(key: key);

  @override
  _FormPokjaState createState() => _FormPokjaState();
}

class _FormPokjaState extends State<FormPokja> {
  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerAlamat = TextEditingController();
  TextEditingController controllerHp = TextEditingController();
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final LocalStorage storageUser = LocalStorage('terra_app');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var imageKTP;
  final picker = ImagePicker();
  Widget loginText = const Text(
    'Registrasi',
    style: TextStyle(color: Colors.white),
  );

  Future chooseImage() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
    } else {
      setState(() {
        imageKTP = File(pickedImage.path);
        goImage = File(pickedImage.path);
      });
    }
  }

  late File goImage;

  Future submitRegistrasi() async {
    var cred = await storageUser.getItem('data_user_login');
    if (imageKTP == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialogmodal(
            vartitle: "Gagal",
            varcontent: "Foto wajib ada",
          );
        },
      );
      setState(() {
        loginText = const Text(
          'Registrasi',
          style: TextStyle(color: Colors.white),
        );
      });
    } else {
      final uri = apiURI;
      var request = http.MultipartRequest('POST', uri);
      request.fields['nama'] = controllerUser.text;
      request.fields['id_korwil'] = cred['data']['id'];
      request.fields['alamat'] = controllerAlamat.text;
      request.fields['nohp'] = controllerHp.text;
      request.fields['email'] = controllerMail.text;
      request.fields['target'] = 'user_korwil';
      request.fields['type_submit'] = 'addPokja';
      var picKTP = await http.MultipartFile.fromPath("foto", goImage.path);
      request.files.add(picKTP);
      log('REQ: $request');
      var response = await request.send();
      var rsptr = await http.Response.fromStream(response);
      log('RES: ${rsptr.body}');
      var ghgh = jsonDecode(rsptr.body);

      if (ghgh['status'] == 'success') {
        //sukses
        // Navigator.popAndPushNamed(context, '/Dashboard');
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(
                tipe: 'success', label: 'Registrasi berhasil');
          },
        );
        setState(() {
          loginText = const Text(
            'Registrasi',
            style: TextStyle(color: Colors.white),
          );
        });
      } else {
        setState(() {
          loginText = const Text(
            'Registrasi',
            style: TextStyle(color: Colors.white),
          );
        });
        //gagal
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(tipe: 'fail', label: 'Registrasi gagal');
          },
        );
      }
    }
  }
  Future<bool> backtoDashboard() {
    Navigator.pushNamed(context, '/Dashboard');
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    var _onpressed;
    if (enabledbutton) {
      _onpressed = () {
        checkerPokja();
      };
    } else {
      _onpressed = null;
    }
    return WillPopScope(
      onWillPop: backtoDashboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CustomAppBar(
          label: 'Tambah Pokja / Operator',
        ),
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: ListView(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
            children: <Widget>[
              Center(
                child: Image.asset(
                  "assets/register_pokja.png",
                  scale: 1,
                ),
              ),
              const SizedBox(height: 20),
              InputTextWhite(
                  controller: controllerUser, label: "Nama", obscuring: false),
              InputTextWhite(
                  controller: controllerAlamat,
                  label: "Alamat",
                  obscuring: false),
              InputTextWhite(
                  controller: controllerMail, label: "Email", obscuring: false),
              InputTextWhite(
                  controller: controllerHp,
                  label: "Nomor handphone",
                  obscuring: false,
                  inputKeyboard: TextInputType.number),
              Container(
                  padding: const EdgeInsets.only(bottom: 5, top: 10),
                  width: 500,
                  child: const Text('Foto', textAlign: TextAlign.start)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: theme == 'light'
                      ? const Color(0XFFEEEEEE)
                      : Colors.grey.shade700,
                ),
                child: Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 2, right: 10),
                    ),
                    OutlinedButton(
                      onPressed: chooseImage,
                      child: const Text('Pilih Foto'),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      // ignore: unnecessary_null_comparison
                      child: imageKTP == null
                          ? const Text("Foto Belum Dipilih")
                          // ignore: avoid_unnecessary_containers
                          : Container(
                              child: Image.file(
                              imageKTP,
                              scale: 50,
                            )),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 35),
                child: DefaultButtonWidget(
                    onPressed: _onpressed,
                    height: 40,
                    label: loginText,
                    labelColor: Colors.white,
                    color: Colors.green),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(vertical: 35),
              //   child: DefaultButtonWidget(
              //       onPressed: () {
              //         showDialog(
              //           barrierDismissible: false,
              //           context: context,
              //           builder: (BuildContext context) {
              //             return const DialogStatus(
              //               tipe: 'fail',
              //               label: 'Gagal'
              //             );
              //           },
              //         );
              //       },
              //       height: 40,
              //       label: const Text('TEST dialog'),
              //       labelColor: Colors.white,
              //       color: Colors.green),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  bool enabledbutton = true;
  void checkerPokja() async {
    if (controllerUser.text == '' ||
        controllerAlamat.text == '' ||
        controllerMail.text == '' ||
        controllerHp.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi data.'),
        ),
      );
    } else {
      setState(() {
        loginText = const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ));
      });
      submitRegistrasi();
    }
  }
}
