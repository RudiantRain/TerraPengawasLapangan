import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/pages/plotting_list.dart';
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';

class TransaksiList extends StatefulWidget {
  const TransaksiList({ Key? key }) : super(key: key);

  @override
  _TransaksiListState createState() => _TransaksiListState();
}

class _TransaksiListState extends State<TransaksiList> {
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataTransaksi();
  }

  bool loadvisib = true;
  int totOrder = 0;
  Future<List> getDataTransaksi() async {
    var cred = await storageUser.getItem('data_user_login');
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': cred['data']['id'],
      'target': 'user_korwil',
      'type_submit': 'getTransaction'
    });
    var status = jsonDecode(response.body);
    var gOm = List.from(status);
    _streamController.add(status);
    log('$status');
    setState(() {
      totOrder = gOm.length;
      loadvisib = false;
    });
    return status;
  }

  _firstStepTransaction() {
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
                  builder: (BuildContext context) =>
                      const ListPokja(mode: 'pilih', route: 'transaksi',),
                ));
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0XFFF1F1F1),
      appBar: const CustomAppBar(
        label: 'Transaksi',
      ),
      body: ListView(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(25, 10, 0, 0),
              child: Column(
                children: [
                  Container(
                    width: 500,
                    child: Text(
                      'List Transaksi',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 500,
                    child: Text(
                      'Total : $totOrder Transaksi',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor),
                    ),
                  ),
                  Visibility(
                      visible: loadvisib,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 10,  right: 30),
                            child: SkeletonOrderCard(),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10,  right: 30),
                            child: SkeletonOrderCard(),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10,  right: 30),
                            child: SkeletonOrderCard(),
                          ),
                        ],
                      ))
                ],
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
                          TransaksiListCard(
                            scrollController: _scrollController,
                            list: snapshot.data ?? [],
                          ),
                          SizedBox(width: 10,),
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
    );
  }
}