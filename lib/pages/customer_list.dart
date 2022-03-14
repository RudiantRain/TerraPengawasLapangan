import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';

class CustomerList extends StatefulWidget {
  final String mode;
  final String route;
  final String idPokja;
  const CustomerList({Key? key,required this.idPokja, required this.mode, required this.route})
      : super(key: key);

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataPokja();
  }

  Future<List> getDataPokja() async {
    var cred = await storageUser.getItem('data_user_login');
    var boDY;
    if(widget.idPokja == '0'){
      boDY = {
        'id_korwil': cred['data']['id'],
        'target': 'user_korwil',
        'type_submit': 'getCustomer'
      };
    }else{
      boDY = {
        'id_korwil': cred['data']['id'],
        'id_pokja' : widget.idPokja,
        'target': 'user_korwil',
        'type_submit': 'getCustomer'
      };
    }
    final http.Response response = await http.post(apiURI, body: boDY);
    var status = jsonDecode(response.body);
    _streamController.add(status);
    log('$status');
    return status;
  }


  Future<bool> backtoDashboard() {
    Navigator.pushNamed(context, '/Dashboard');
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backtoDashboard,
      child: Scaffold(
        appBar: CustomAppBar(
          label: widget.mode == 'pilih' ? 'Pilih Customer' : 'Daftar Customer',
          actionlist: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const ListPokja(
                      mode: 'pilih',
                      route: 'customer',
                    ),
                  ));
                },
                icon: const Icon(
                  Icons.add_box,
                  color: Colors.green,
                )),
            const SizedBox(width: 15),
          ],
        ),
        body: ListView(children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder<List>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? Column(
                        children: [
                          CustomerCard(
                            idPokja: widget.idPokja,
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
        ]),
      ),
    );
  }
}
