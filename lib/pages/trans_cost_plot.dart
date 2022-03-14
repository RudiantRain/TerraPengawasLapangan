import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'dart:convert';

class TransCostPlot extends StatefulWidget {
  final String idUser;
  final String idPokja;
  final String idPaket;
  final String idCustomer;
  final String namaPaket;
  final String waktuMulai;
  final String waktuSelesai;
  final String polygon;
  final String idMesin;
  final String luasArea;
  final String harga;
  final String idLahan;
  final String namaLahan;
  final String alamatLahan;
  const TransCostPlot(
      {Key? key,
      required this.idUser,
      required this.idPokja,
      required this.idPaket,
      required this.idCustomer,
      required this.namaPaket,
      required this.waktuMulai,
      required this.waktuSelesai,
      required this.polygon,
      required this.idMesin,
      required this.luasArea,
      required this.harga,
      required this.idLahan,
      required this.namaLahan,
      required this.alamatLahan})
      : super(key: key);

  @override
  _TransCostPlotState createState() => _TransCostPlotState();
}

class _TransCostPlotState extends State<TransCostPlot> {
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  TextEditingController nominalNote = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<bool> backtoDashboard() {
    Navigator.pushNamed(context, '/Dashboard');
    return Future.value(true);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addTipeBiaya();
  }

  bool enabled = true;
  bool visibButton = false;

  String? _stringIDpackage;
  List storedPackage = [];
  List arrayPackage = [];
  List biayaStream = [];
  Future addTipeBiaya() async {
    // var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": widget.idUser,
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

  @override
  Widget build(BuildContext context) {
    var _onpressed;
    if (enabled) {
      _onpressed = () {
        simpanTransaksi();
      };
    } else {
      _onpressed = null;
    }
    var theme = storageUser.getItem('theme_config')['value'];
    return WillPopScope(
      onWillPop: backtoDashboard,
      child: Scaffold(
        appBar: CustomAppBar(
          label: 'Transaksi Manual ${widget.namaLahan}',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
          children: [
            Container(
                padding: const EdgeInsets.only(bottom: 5, top: 20),
                width: 500,
                child:
                    const Text('Paket Pekerjaan', textAlign: TextAlign.start)),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 50,
              decoration: BoxDecoration(
                color: theme == 'light'
                    ? const Color(0XFFEEEEEE)
                    : Colors.grey.shade700,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.namaPaket),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 5, top: 20),
                width: 500,
                child: const Text('Waktu Mulai', textAlign: TextAlign.start)),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 50,
              decoration: BoxDecoration(
                color: theme == 'light'
                    ? const Color(0XFFEEEEEE)
                    : Colors.grey.shade700,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.waktuMulai),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 5, top: 20),
                width: 500,
                child: const Text('Waktu Selesai', textAlign: TextAlign.start)),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 50,
              decoration: BoxDecoration(
                color: theme == 'light'
                    ? const Color(0XFFEEEEEE)
                    : Colors.grey.shade700,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.waktuSelesai),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 5, top: 20),
                width: 500,
                child:
                    const Text('Luas Kerja (m2)', textAlign: TextAlign.start)),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 50,
              decoration: BoxDecoration(
                color: theme == 'light'
                    ? const Color(0XFFEEEEEE)
                    : Colors.grey.shade700,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.luasArea),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 5, top: 20),
                width: 500,
                child: const Text('Harga', textAlign: TextAlign.start)),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 50,
              decoration: BoxDecoration(
                color: theme == 'light'
                    ? const Color(0XFFEEEEEE)
                    : Colors.grey.shade700,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                    alignment: Alignment.centerLeft, child: Text(widget.harga)),
              ),
            ),
            Container(
              // padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
              width: 500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Biaya Rp ' + totBiaya.toStringAsFixed(0),
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 15),
                    child: DefaultButton(
                        onPressed: addCost2,
                        height: 40,
                        label: '+ Tambahkan biaya',
                        labelColor: Colors.white,
                        color: Colors.orange),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.zero,
              width: MediaQuery.of(context).size.width * 0.8,
              child: StreamBuilder<List>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? Column(
                          children: [
                            BiayaList(
                              scrollController: _scrollController,
                              list: snapshot.data ?? [],
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        );
                },
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: visibButton,
              child: Container(
                padding: const EdgeInsets.only(top: 15),
                child: DefaultButton(
                    onPressed: deleteBiaya,
                    height: 40,
                    label: 'Hapus Biaya',
                    labelColor: Colors.white,
                    color: Colors.red),
              ),
            ),
            const SizedBox(height: 10),
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
        ),
      ),
    );
  }

  String loginText = 'Simpan Transaksi';
  double totBiaya = 0;
  List biayaToSend = [];
  Future insertStream() async {
    if (_stringIDpackage == null) {
    } else {
      var split = _stringIDpackage!.split('-');
      biayaToSend.add({split[1],nominalNote.text});
      biayaStream.add({"nama_biaya": split[1], "nominal": nominalNote.text});
      setState(() {
        visibButton = true;
        totBiaya += double.parse(nominalNote.text);
        _streamController.add(biayaStream);
      });
      print('${biayaStream.toString()}');
    }
  }

  Future deleteBiaya() async {
    biayaStream.clear();
    setState(() {
      visibButton = false;
      totBiaya = 0;
      _streamController.add(biayaStream);
    });
  }

  Future addCost2() async {
    var theme = storageUser.getItem('theme_config')['value'];

    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Container(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.only(bottom: 5),
                              width: 500,
                              child: const Text('Biaya',
                                  textAlign: TextAlign.start)),
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: theme == 'light'
                                  ? const Color(0XFFEEEEEE)
                                  : Colors.grey.shade700,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: DropdownButton(
                                hint: const Text(
                                  "Tipe Biaya",
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
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      InputTextWhite(
                        label: 'Nominal (Rp)',
                        controller: nominalNote,
                        obscuring: false,
                        inputKeyboard: TextInputType.number,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              child: Row(
                                // ignore: prefer_const_literals_to_create_immutables
                                children: [
                                  const Icon(
                                    Icons.library_add_check,
                                    size: 14,
                                  ),
                                  const Text(' Simpan'),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                insertStream();
                              }),
                          ElevatedButton(
                              child: Row(
                                // ignore: prefer_const_literals_to_create_immutables
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    size: 14,
                                  ),
                                  const Text(' Batal'),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                    ],
                  )),
            );
          });
        });
  }

  Future simpanTransaksi() async {
    setState(() {
      loginText = 'Proses';
      print('POLYCOOR: ${widget.idPokja}');
    });

    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": widget.idUser,
      "id_pokja": widget.idPokja,
      "id_paket": widget.idPaket,
      "id_customer" :widget.idCustomer,
      "waktu_mulai": widget.waktuMulai,
      "waktu_selesai": widget.waktuSelesai,
      "polygon": widget.polygon,
      "id_mesin": widget.idMesin,
      "luas_area": widget.luasArea,
      "harga": widget.harga,
      "biaya": biayaToSend.toString(),
      "id_lahan": widget.idLahan,
      "address": widget.alamatLahan,
      "nama_lahan": widget.namaLahan,
      "target": "user_korwil",
      "type_submit": "addtransactionManual"
    });

    print("${response.body}");
    if (response.statusCode == 200) {
      var status = jsonDecode(response.body);
      if (status['status'] == 'success') {
        setState(() {
          loginText = 'Jadikan Transaksi';
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return const DialogStatus(
                  tipe: 'success', label: 'Transaksi berhasil dibuat');
            },
          );
          // Navigator.pushNamed(context, '/Dashboard');
        });
      } else {
        setState(() {
          loginText = 'Jadikan Transaksi';
        });
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(
                tipe: 'fail', label: 'Gagal membuat transaksi');
          },
        );
      }
    } else {
      // print("${response.statusCode}");
      setState(() {
        loginText = 'Jadikan Transaksi';
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
}
