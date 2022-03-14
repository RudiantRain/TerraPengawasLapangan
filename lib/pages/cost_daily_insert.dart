import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'dart:convert';

class CostDailyInsert extends StatefulWidget {
  const CostDailyInsert({Key? key}) : super(key: key);

  @override
  _CostDailyInsertState createState() => _CostDailyInsertState();
}

class _CostDailyInsertState extends State<CostDailyInsert> {
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  TextEditingController nominalNote = TextEditingController();
  TextEditingController keteranganNote = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addTipeBiaya();
    // getCurrentLocation();
  }

  var imageKTP;
  final picker = ImagePicker();

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

  DateTime? dateTime;
  String getTextDate() {
    if (dateTime == null) {
      return 'Pilih Tanggal';
    } else {
      return DateFormat('MM/dd/yyyy HH:mm').format(dateTime!);
    }
  }

  Future pickDaily(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;

    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
      );
    });
  }

  Future<DateTime?> pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: dateTime ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return null;

    return newDate;
  }

  String? _stringIDpackage;
  List storedPackage = [];
  List arrayPackage = [];
  List biayaStream = [];
  Future addTipeBiaya() async {
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idUser,
      "target": 'user_korwil',
      "type_submit": 'getCostType'
    });
    var getPket = jsonDecode(response.body);
    List soMachine = List.from(getPket);
    soMachine.forEach((en) {
      storedPackage.add(en['id'] + "-" + en['nama']);
    });
    setState(() {
      arrayPackage = List.from(getPket);
    });
    print('arraypackage: $arrayPackage');
  }

  bool enabled = true;
  String loginText = 'Simpan';
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    var _onpressed;
    if (enabled) {
      _onpressed = () {
        checkerBiaya();
      };
    } else {
      _onpressed = null;
    }
    return Scaffold(
        appBar: const CustomAppBar(
          label: 'Input Biaya',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
          children: [
            Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(bottom: 5, top: 20),
                    width: 500,
                    child: const Text('Tanggal', textAlign: TextAlign.start)),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      pickDaily(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme == 'light'
                            ? const Color(0XFFEEEEEE)
                            : Colors.grey.shade700,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(getTextDate())),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    width: 500,
                    child: const Text('Kategori Biaya',
                        textAlign: TextAlign.start)),
                Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: theme == 'light'
                        ? const Color(0XFFEEEEEE)
                        : Colors.grey.shade700,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: DropdownButton(
                      hint: const Text(
                        "Pilih Biaya",
                      ),
                      value: _stringIDpackage,
                      items: storedPackage.map((value) {
                        return DropdownMenuItem(
                          child: SelectboxText(value),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (value) {
                        // filterPrice(value.toString());
                          
                        setState(() {
                          _stringIDpackage = value.toString();
                          print(_stringIDpackage);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            InputTextWhite(
              label: 'Nominal (Rp)',
              controller: nominalNote,
              obscuring: false,
              inputKeyboard: TextInputType.number,
            ),
            InputTextWhite(
              label: 'Keterangan',
              controller: keteranganNote,
              obscuring: false,
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 5, top: 10),
                width: 500,
                child: const Text('Foto', textAlign: TextAlign.start)),
            Container(
              padding: const EdgeInsets.only(top: 0),
              child: DefaultButton(
                  onPressed: chooseImage,
                  height: 40,
                  label: "Pilih Foto",
                  labelColor: Colors.white,
                  color: Colors.grey.shade600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: imageKTP == null
                  ? const Center(child: Text("Foto Belum Dipilih"))
                  // ignore: avoid_unnecessary_containers
                  : Container(
                      child: Image.file(
                      imageKTP,
                      scale: 2,
                    )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: DefaultButton(
                  onPressed: _onpressed,
                  height: 40,
                  label: loginText,
                  labelColor: Colors.white,
                  color: Colors.green),
            ),
          ],
        ));
  }

    bool enabledbutton = true;
  void checkerBiaya() async {
    if (nominalNote.text == '' ||
        _stringIDpackage == null ||
        dateTime == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi data.'),
        ),
      );
    } else {
      setState(() {
        loginText = 'Proses';
      });
      submitBiaya();
    }
  }

  Future submitBiaya() async {
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
        loginText = 'Simpan';
      });
    } else {
      var split = _stringIDpackage!.split("-");
      final uri = apiURI;
      var request = http.MultipartRequest('POST', uri);
      request.fields['id_korwil'] = cred['data']['id'];
      request.fields['id_tipe_biaya'] = split[0].toString();
      request.fields['tanggal'] = dateTime.toString();
      request.fields['nominal'] = nominalNote.text;
      request.fields['keterangan'] = keteranganNote.text;
      request.fields['target'] = 'user_korwil';
      request.fields['type_submit'] = 'addBiayaGlobal';
      var picKTP = await http.MultipartFile.fromPath("foto", goImage.path);
      request.files.add(picKTP);
      // log('REQ: $request');
      var response = await request.send();
      var rsptr = await http.Response.fromStream(response);
      // log('RES: ${rsptr.body}');
      var ghgh = jsonDecode(rsptr.body);

      if (ghgh['status'] == 'success') {
        //sukses
        // Navigator.popAndPushNamed(context, '/Dashboard');
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(
                tipe: 'success', label: 'Biaya dicatat');
          },
        );
        setState(() {
          loginText = 'Simpan';
        });
      } else {
        setState(() {
          loginText = 'Simpan';
        });
        //gagal
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(tipe: 'fail', label: 'Terjadi kesalahan');
          },
        );
      }
    }
  }
}
