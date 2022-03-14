import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateful.dart';
import 'package:terra_korwil/theme/stateless.dart';

class PlottingList extends StatefulWidget {
  final String route;
  final String mode;
  const PlottingList({ Key? key, required this.mode, required this.route}) : super(key: key);

  @override
  _PlottingListState createState() => _PlottingListState();
}

class _PlottingListState extends State<PlottingList> {
  @override
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPokjaArea();
  }

  bool loadvisib = true;
  int totOrder = 0;
  Future<List> getPokjaArea() async {
    var cred = await storageUser.getItem('data_user_login');
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': cred['data']['id'],
      'target': 'user_korwil',
      'type_submit': 'getArea'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0XFFF1F1F1),
      appBar: CustomAppBar(
        label: widget.mode == 'pilih'? 'Pilih Plotting Lahan' : 'Daftar Plotting Lahan',
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
                      'List Plotting Lahan',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 500,
                    child: Text(
                      'Total Plotting : $totOrder',
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
                          PlottingCard(
                            route: widget.route,
                            mode: widget.mode,
                            scrollController: _scrollController,
                            list: snapshot.data ?? [],
                          ),
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