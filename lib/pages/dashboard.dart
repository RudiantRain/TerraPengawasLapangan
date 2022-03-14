import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:terra_korwil/pages/customer_list.dart';
import 'package:terra_korwil/pages/plotting_list.dart';
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateful.dart';
import 'package:terra_korwil/theme/stateless.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  LocalStorage storageUser = LocalStorage('terra_app');
  ScrollController _scrollController = ScrollController();
  final StreamController<List> _streamController = StreamController();
  final StreamController<List> _streamMachine = StreamController();

  int _counter = 0;

  @override
  void initState() {
    super.initState();

    getUserData().then((value) => getSummary()
        .then((value) => getMachine().then((value) => getDataTargets())));
  }

  int totMesin = 0;
  int totOrder = 0;
  String totTrans = '0';
  String totPokja = '0';
  String totCust = '0';
  String totPlot = '0';
  Future getMachine() async {
    var idkorwil = storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idkorwil,
      "target": 'user_korwil',
      "type_submit": 'getUnit'
    });

    var status = jsonDecode(response.body);
    List soMachine = List.from(status);
    print("getMachine: $status");

    setState(() {
      if (soMachine.isNotEmpty) {
        totMesin = soMachine.length;
        _streamMachine.add(status);
      }
    });

    return status;
  }

  Future getSummary() async {
    var idkorwil = storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idkorwil,
      "target": 'user_korwil',
      "type_submit": 'summary'
    });

    var status = jsonDecode(response.body);
    List soMachine = List.from(status);
    print("summary: $status");
    setState(() {
      totPlot = status[0]['total_lahan'].toString();
      totTrans = status[0]['total_transaction'].toString();
      totPokja = status[0]['total_pokja'].toString();
      totCust = status[0]['total_customer'].toString();
      // totMesin = soMachine.length;
    });
    return status;
  }

  Future<List> getDataTargets() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy');
    final String formatted = formatter.format(now).toString();
    var cred = await storageUser.getItem('data_user_login');
    final http.Response response = await http.post(apiURI, body: {
      'tahun': formatted,
      'id_korwil': cred['data']['id'],
      'target': 'user_korwil',
      'type_submit': 'getTargetKerja'
    });
    var status = jsonDecode(response.body);
    List gOm = List.from(status);
    // List gOm = [];
    _streamController.add(status);
    log('$status');
    setState(() {
      // totOrder = gOm.length;
      // loadvisib = false;
    });
    return status;
  }

  String? tema;
  String? textnama;
  Future getUserData() async {
    // var userName = await storageUser.getItem('username');
    var cred = await storageUser.getItem('userpass');
    // log("${cred['user']}");
    final http.Response response = await http.post(apiURI, body: {
      "username": cred['user'],
      "password": cred['pass'],
      "target": 'user_auth',
      "type_submit": 'loginKorwil'
    });
    var status = jsonDecode(response.body);
    log("$status");
    setState(() {
      tema = storageUser.getItem('theme_config')['value'];
      textnama = status['data']['nama'];
    });
    storageUser.setItem('data_user_login', status);

    return status;
  }

  Future<bool> _logoutQuest() {
    var idUser = storageUser.getItem('data_user_login')['data']['id'];
    bool val = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogYesNo(
              vartitle: 'Keluar Aplikasi',
              varcontent: 'Apakah anda yakin?',
              textYes: 'Ya',
              textNo: 'Tidak',
              funYes: () {
                storageUser
                    .deleteItem('data_user_login')
                    .then((value) => storageUser.setItem('data_user_login', {
                          "status": "success",
                          "data": {"id": idUser}
                        }))
                    .then((value) =>
                        storageUser.deleteItem('userpass').then((value) {
                          Navigator.pushNamed(context, '/Login');
                          setState(() {
                            val = true;
                          });
                        }));
              },
              funNo: () => Navigator.pop(context, false));
        });
    return Future.value(val);
  }

  _firstStepOrder() {
    if (totMesin == 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(
                tipe: "fail", label: "Mesin belum tersedia");
          });
    } else {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            const ListPokja(mode: 'pilih', route: 'order'),
      ));
    }
  }

  _firstStepTransaction() {
    if (totMesin == 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogStatus(tipe: "fail", label: "Mesin belum tersedia");
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogYesNo(
                vartitle: 'Membuat Transaksi Manual',
                varcontent: 'Apakah sudah ada plotting lahan?',
                textYes: 'Sudah',
                textNo: 'Belum',
                funYes: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const PlottingList(mode: 'pilih', route: 'transaksi'),
                  ));
                },
                funNo: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const ListPokja(
                      mode: 'pilih',
                      route: 'transaksi',
                    ),
                  ));
                });
          });
    }
  }

  List timeList = [
    '0-Semua',
    '1-Selanjutnya',
    '2-Dikerjakan',
    '3-Selesai',
  ];
  String timeChoosen = '0-Semua';
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return WillPopScope(
      onWillPop: _logoutQuest,
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
                backgroundColor:
                    theme == 'light' ? Color(0XFFF3F3F3) : Colors.grey.shade800,
                leading: Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: Image.asset(
                      "assets/no_user.png",
                      height: 50,
                      width: 50,
                    )),
                title: Container(
                    child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Text(
                            // ignore: prefer_adjacent_string_concatenation
                            textnama == null ? '' : "Hai, " + "$textnama",
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                          width: 200,
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            "Pengawas Lapangan",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
                expandedHeight: MediaQuery.of(context).size.height * 0.09,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                  ),
                ),
                actions: [
                  ThemeSwitcher(),
                  IconButton(
                      onPressed: () => _logoutQuest(),
                      icon: Icon(
                        Icons.exit_to_app_rounded,
                        color: Theme.of(context).secondaryHeaderColor,
                      )),
                ]),
            SliverList(
                delegate: SliverChildListDelegate(<Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/banner_dash_korwil.png',
                    scale: 0.9,
                    fit: BoxFit.cover,
                  ),
                ),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: MediaQuery.of(context).size.height * 0.2,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/ListOrder');
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        width: 150,
                        // height: 200,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Total Order : ' + totOrder.toString())
                              ],
                            ),
                            const SizedBox(height: 10),
                            Image.asset('assets/order_card_dash.png',
                                height: 80)
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: theme == 'light'
                              ? Color(0XFFFFFFFF)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/ListTransaksi');
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        width: 150,
                        // height: 200,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Total Transaksi : ' + totTrans),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Image.asset(
                              'assets/transaksi_card_dash.png',
                              height: 80,
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: theme == 'light'
                              ? Color(0XFFFFFFFF)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const ListPokja(mode: 'lihat', route: 'none'),
                        ));
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        width: 150,
                        // height: 200,
                        child: Column(
                          children: [
                            Row(
                              children: [Text('Daftar Pokja : ' + totPokja)],
                            ),
                            const SizedBox(height: 10),
                            Image.asset('assets/pokja_card_dash.png',
                                height: 80)
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: theme == 'light'
                              ? Color(0XFFFFFFFF)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => const CustomerList(
                            mode: 'lihat',
                            route: 'none',
                            idPokja: '0',
                          ),
                        ));
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        width: 150,
                        // height: 200,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Customer : ' + totPokja),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Image.asset('assets/lahan_card_dash.png',
                                height: 80)
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: theme == 'light'
                              ? Color(0XFFFFFFFF)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //       builder: (BuildContext context) =>
                    //           const PlottingList(mode: 'lihat', route: 'order'),
                    //     ));
                    //   },
                    //   child: Container(
                    //     padding:
                    //         EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    //     width: 150,
                    //     // height: 200,
                    //     child: Column(
                    //       children: [
                    //         Row(
                    //           children: [Text('Plotting lahan : ' + totPlot)],
                    //         ),
                    //         const SizedBox(height: 10),
                    //         Image.asset('assets/lahan_card_dash.png',
                    //             height: 80)
                    //       ],
                    //     ),
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.all(Radius.circular(10)),
                    //       color: theme == 'light'
                    //           ? Color(0XFFFFFFFF)
                    //           : Colors.grey.shade700,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(width: 20),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    bottom: 5, top: 5, left: 20, right: 20),
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totMesin.toString() + ' Mesin Pengawas',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    // DropdownButton(
                    //   hint: Text(
                    //     "Semua",
                    //   ),
                    //   value: timeChoosen,
                    //   items: timeList.map((value) {
                    //     return DropdownMenuItem(
                    //       child: SelectboxText(value),
                    //       value: value,
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       timeChoosen = value.toString();
                    //       // print("$value");
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: StreamBuilder<List>(
                  stream: _streamMachine.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    return snapshot.hasData
                        ? MachineCard(
                            controller: _scrollController,
                            list: snapshot.data ?? [],
                          )
                        : Container(
                            child: const Center(
                                child:
                                    Text('Belum ada mesin yang tersedia')),
                            padding: const EdgeInsets.symmetric(
                                vertical: 40, horizontal: 50),
                          );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pencapaian Target',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    // DropdownButton(
                    //   hint: Text(
                    //     "Semua",
                    //   ),
                    //   value: timeChoosen,
                    //   items: timeList.map((value) {
                    //     return DropdownMenuItem(
                    //       child: SelectboxText(value),
                    //       value: value,
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       timeChoosen = value.toString();
                    //       // print("$value");
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: StreamBuilder<List>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    return snapshot.hasData
                        ? TargetGrid(
                            scrollController: _scrollController,
                            list: snapshot.data ?? [],
                          )
                        : Container(
                            child: const Center(
                                child: Text('Belum ada yang ditampilkan')),
                            padding: const EdgeInsets.symmetric(
                                vertical: 40, horizontal: 50),
                          );
                  },
                ),
              ),
              const SizedBox(
                height: 50,
              ),
            ]))
          ],
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: Colors.green,
          animatedIcon: AnimatedIcons.menu_home,
          foregroundColor:
              theme == 'light' ? Color(0XFFFFFFFF) : Colors.grey.shade700,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.account_balance_wallet),
              label: "Rekapitulasi Biaya",
              onTap: () => Navigator.pushNamed(context, '/CostDaily'),
            ),
            // SpeedDialChild(
            //   child: const Icon(Icons.add_box),
            //   label: "Transaksi Manual",
            //   onTap: () => _firstStepTransaction(),
            // ),
            SpeedDialChild(
              child: const Icon(Icons.event_available),
              label: "Jadwalkan Order",
              onTap: () {
                _firstStepOrder();
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.person_add_alt),
              label: "Tambah Customer",
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const ListPokja(
                    mode: 'pilih',
                    route: 'customer',
                  ),
                ));
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.person_add_rounded),
              label: "Tambah Pokja",
              onTap: () => Navigator.pushNamed(context, '/FormPokja'),
            ),
            // SpeedDialChild(
            //   child: const Icon(Icons.list_rounded),
            //   label: "Jadwal Kerja",
            //   onTap: () => Navigator.pushNamed(context, '/ListOrder'),
            // ),
          ],
        ),
      ),
    );
  }
}
