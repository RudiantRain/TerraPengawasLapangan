import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';

class PokjaEdit extends StatefulWidget {
  final String idPokja;
  final String nama;
  final String nohp;
  final String alamat;
  final String email;
  final String foto;
  const PokjaEdit(
      {Key? key,
      required this.idPokja,
      required this.nama,
      required this.nohp,
      required this.alamat,
      required this.email,
      required this.foto})
      : super(key: key);

  @override
  _PokjaEditState createState() => _PokjaEditState();
}

class _PokjaEditState extends State<PokjaEdit> {
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
    getData();
  }

  var midUser;
  Future getData() async {
    var cred = await storageUser.getItem('data_user_login');
    setState(() {
      controllerUser.text = widget.nama;
      controllerHp.text = widget.nohp;
      controllerMail.text = widget.email;
      controllerAlamat.text = widget.alamat;
    });

    return cred;
  }

  var imageKTP;
  final picker = ImagePicker();
  Widget loginText = const Text(
    'Update',
    style: TextStyle(color: Colors.white),
  );

  late File goImage;
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

  Future editPokja() async {
    var cred = await storageUser.getItem('data_user_login');
    final uri = apiURI;
    var request = http.MultipartRequest('POST', uri);
    request.fields['id_pokja'] = widget.idPokja;
    request.fields['nama'] = controllerUser.text;
    request.fields['id_korwil'] = cred['data']['id'];
    request.fields['alamat'] = controllerAlamat.text;
    request.fields['nohp'] = controllerHp.text;
    request.fields['email'] = controllerMail.text;
    request.fields['target'] = 'user_korwil';
    request.fields['type_submit'] = 'editPokja';
    if (imageKTP != null) {
      var picKTP = await http.MultipartFile.fromPath("foto", goImage.path);
      request.files.add(picKTP);
    }
    log('REQ: $request');
    var response = await request.send();
    var rsptr = await http.Response.fromStream(response);
    var ghgh = jsonDecode(rsptr.body);
    log('REQ: $ghgh');
    if (ghgh['status'] == 'success') {
      //sukses
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const DialogStatus(
              tipe: 'success', label: 'Update data berhasil');
        },
      );
      setState(() {
        loginText = const Text(
          'Update',
          style: TextStyle(color: Colors.white),
        );
      });
    } else {
      setState(() {
        loginText = const Text(
          'Update',
          style: TextStyle(color: Colors.white),
        );
      });
      //gagal
      showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const DialogStatus(
              tipe: 'fail', label: 'Update data gagal');
        },
      );
    }
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(
        label: 'Edit Pokja / Customer',
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
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
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
                obscuring: false),
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
          ],
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
      editPokja();
    }
  }
}
