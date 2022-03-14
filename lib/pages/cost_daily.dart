import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/imagepacks.dart';
import 'package:terra_korwil/theme/stateful.dart';
import 'package:terra_korwil/theme/stateless.dart';

class CostDaily extends StatefulWidget {
  const CostDaily({Key? key}) : super(key: key);

  @override
  _CostDailyState createState() => _CostDailyState();
}

class _CostDailyState extends State<CostDaily> {
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllBiaya();
  }

  // String tanggalText =
  //     (DateFormat('MM/dd/yyyy').format(DateTime.now())).toString();
  String tanggalText = 'Semua';

  bool loadvisib = true;
  double totbiaya = 0;
  Future<List> getAllBiaya() async {
    var cred = await storageUser.getItem('data_user_login');
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': cred['data']['id'],
      'target': 'user_korwil',
      'type_submit': 'getBiaya'
    });
    var status = jsonDecode(response.body);
    var gOm = List.from(status);
    _streamController.add(status);
    gOm.forEach((v) {
      totbiaya += double.parse(v['nominal']);
    });
    log('$status');

    setState(() {
      loadvisib = false;
    });
    return status;
  }

  Future filterTanggal() async {
    print('ANJAKDJKAJDKAD');
    var cred = await storageUser.getItem('data_user_login');
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': cred['data']['id'],
      'target': 'user_korwil',
      'type_submit': 'getBiaya'
    });
    var status = jsonDecode(response.body);
    var gOm = List.from(status);
    gOm.forEach((v) {
      if (DateTime.parse(v['tanggal'].toString())
                  .isBefore(dateTime!) ||
              DateTime.parse(v['tanggal'].toString())
                  .isAfter(dateTime2!)) {
            // GAK NGAPA2IN
            print("MASUK SANA");
          }else{
            totbiaya += double.parse(v['nominal']);
            // _streamController.add(v);
            print("MASUK SINI");
          }
    });
    // return status;
  }

   // TIME PICKERR CONFIG
  DateTime? dateTime;
  DateTime? dateTime2;
  String getTextDate() {
    if (dateTime == null) {
      return 'Pilih Tanggal';
    } else {
      return DateFormat('MM/dd/yyyy HH:mm').format(dateTime!);
    }
  }

  String getTextDate2() {
    if (dateTime2 == null) {
      return 'Pilih Tanggal';
    } else {
      return DateFormat('MM/dd/yyyy HH:mm').format(dateTime2!);
    }
  }

  Future pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;

    final time = await pickTime(context);
    if (time == null) return;

    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future pickDateTime2(BuildContext context) async {
    final date = await pickDate(context);
    if (date == null) return;

    final time = await pickTime(context);
    if (time == null) return;

    setState(() {
      dateTime2 = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
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

  Future<TimeOfDay?> pickTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialTime: dateTime != null
          ? TimeOfDay(hour: dateTime!.hour, minute: dateTime!.minute)
          : initialTime,
    );

    if (newTime == null) return null;

    return newTime;
  }
  // TIME PICKERR CONFIG END

  @override
  Widget build(BuildContext context) {
    Uint8List bytesx = base64Decode(basebt);
    return Scaffold(
      // backgroundColor: const Color(0XFFF1F1F1),
      appBar: CustomAppBar(
        label: 'Rekapitulasi Biaya',
        actionlist: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, '/CostDailyInsert'),
              icon: const Icon(
                Icons.add_box,
                color: Colors.green,
              )),
          const SizedBox(width: 15),
        ],
      ),
      body: ListView(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(25, 10, 0, 0),
              child: Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total biaya',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Text(
                            'Rp ' + formatter.format(totbiaya).toString(),
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal :',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: DefaultButton(
                              height: 20,
                              label: tanggalText,
                              labelColor: Colors.white,
                              onPressed: () {filterList();},
                            )),
                      ],
                    ),
                    Visibility(
                        visible: loadvisib,
                        child: Column(
                          children: [
                            // Image.memory(bytesx, scale: 1)
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 30),
                              child: SkeletonOrderCard(),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 30),
                              child: SkeletonOrderCard(),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 30),
                              child: SkeletonOrderCard(),
                            ),
                          ],
                        ))
                  ],
                ),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder<List>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? Column(
                        children: [
                          BiayaCard(
                              list: snapshot.data ?? [],
                              scrollController: _scrollController)
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 50),
                      );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your onPressed code here!
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.filter_alt),
      // ),
    );
  }

  Future filterList() async {
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
                              padding:
                                  const EdgeInsets.only(bottom: 5, top: 10),
                              width: 500,
                              child: const Text('Pilih Tanggal',
                                  textAlign: TextAlign.start)),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                pickDateTime(context).then((value) => Navigator.of(context).pop());
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme == 'light'
                                      ? const Color(0XFFEEEEEE)
                                      : Colors.grey.shade700,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
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
                          Container(
                              padding:
                                  const EdgeInsets.only(bottom: 5, top: 20),
                              width: 500,
                              child: const Text('Sampai',
                                  textAlign: TextAlign.start)),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                pickDateTime2(context).then((value) => Navigator.of(context).pop());
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme == 'light'
                                      ? const Color(0XFFEEEEEE)
                                      : Colors.grey.shade700,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(getTextDate2())),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                child: Row(
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    const Icon(
                                      Icons.library_add_check,
                                      size: 14,
                                    ),
                                    const Text(' Pilih'),
                                  ],
                                ),
                                onPressed: () {
                                  
                                  filterTanggal();
                                  Navigator.pop(context);
                                }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
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
                          ),
                        ],
                      ),
                    ],
                  )),
            );
          });
        });
  }
}
