import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/theme/config.dart';

class CostDailyDetail extends StatefulWidget {
  final String list;
  const CostDailyDetail({Key? key, required this.list}) : super(key: key);

  @override
  _CostDailyDetailState createState() => _CostDailyDetailState();
}

class _CostDailyDetailState extends State<CostDailyDetail> {
  ScrollController _scrollController = ScrollController();
  LocalStorage storageUser = LocalStorage('terra_app');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convertlist();
  }

  var data;
  void convertlist() {
    var tes = jsonDecode(widget.list);
    setState(() {
      data = tes;
    });
  }

  // END CONVERT DATA
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    var nominal = formatter.format(double.parse(data['nominal']));
    return Scaffold(
      body: CustomScrollView(controller: _scrollController, slivers: [
        SliverAppBar(
            backgroundColor:
                theme == 'light' ? Color(0XFFF3F3F3) : Colors.grey.shade800,
            title: Container(
                child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      child: const Text(
                        // ignore: prefer_adjacent_string_concatenation
                        "Rincian Biaya",
                        style: TextStyle(color: Colors.green),
                      ),
                      width: 200,
                    ),
                  ],
                ),
              ],
            )),
            expandedHeight: MediaQuery.of(context).size.height * 0.65,
            // pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: InteractiveViewer(
                panEnabled: false, // Set it to false
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.5,
                maxScale: 2,
                child: Image.network(
                    "https://terra-id.com/dbernardi/ptrutan/upload/biaya/" +
                        data['foto'],
                    scale: 0.2),
              ),
            ),
            actions: []),
        SliverList(
            delegate: SliverChildListDelegate(<Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              // controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              children: [
                Visibility(
                    visible: true,
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(bottom: 0, top: 10),
                            width: 500,
                            child: const Text('Tanggal',
                                textAlign: TextAlign.start)),
                        Container(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            width: 500,
                            child: Text(data['tanggal'],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))),
                        Container(
                            padding: const EdgeInsets.only(bottom: 0, top: 10),
                            width: 500,
                            child: const Text('Tipe Biaya',
                                textAlign: TextAlign.start)),
                        Container(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            width: 500,
                            child: Text(data['nama_biaya'],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))),
                        Container(
                            padding: const EdgeInsets.only(bottom: 0, top: 10),
                            width: 500,
                            child: const Text('Nominal(Rp)',
                                textAlign: TextAlign.start)),
                        Container(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            width: 500,
                            child: Text(nominal.toString(),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))),
                        Container(
                            padding: const EdgeInsets.only(bottom: 0, top: 10),
                            width: 500,
                            child: const Text('Keterangan',
                                textAlign: TextAlign.start)),
                        Container(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            width: 500,
                            child: Text(
                                data['keterangan'] == null
                                    ? ''
                                    : data['keterangan'],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ],
                    )),
              ],
            ),
          ),
        ])),
      ]),
    );
  }
}
