// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:terra_korwil/pages/plotting_list.dart';
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';
import 'package:table_calendar/table_calendar.dart';

class ListOrder extends StatefulWidget {
  const ListOrder({Key? key}) : super(key: key);

  @override
  _ListOrderState createState() => _ListOrderState();
}

class _ListOrderState extends State<ListOrder> {
  LocalStorage storageUser = LocalStorage('terra_app');
  final StreamController<List> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
      selectedEvents = {};
    // TODO: implement initState
    super.initState();
    getDataPokja();
  
  }

   Map<DateTime, List<Event>> selectedEvents  = {};

  List<Event> getEventDate(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  bool loadvisib = true;
  int totOrder = 0;
  Future<List> getDataPokja() async {
    var cred = await storageUser.getItem('data_user_login');
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': cred['data']['id'],
      'target': 'user_korwil',
      'type_submit': 'getOrder'
    });
    var status = jsonDecode(response.body);
    var gOm = List.from(status);
    _streamController.add(status);
    log('ORDERLIST: $status');
    setState(() {
      totOrder = gOm.length;
      loadvisib = false;
      gOm.forEach((ef) {
        selectedEvents[DateTime.parse(ef['tanggal'])] = [Event(title: ef['no_order'])];
        // if(ef['tanggal'] != null){
          // selectedEvents[DateTime.parse(ef['tanggal'])]!.add(Event(title: ef['no_order']));
        // }
      });
      print('$selectedEvents');
    });
    return status;
  }

  _firstStepOrder() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogYesNo(
              vartitle: 'Membuat Jadwal Kerja',
              varcontent: 'Apakah sudah ada plotting lahan?',
              textYes: 'Sudah',
              textNo: 'Belum',
              funYes: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const PlottingList(mode: 'pilih', route: 'order'),
                ));
              },
              funNo: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const ListPokja(mode: 'pilih', route: 'order'),
                ));
              });
        });
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
        // backgroundColor: const Color(0XFFF1F1F1),
        appBar: const CustomAppBar(
          label: 'Order',
          // actionlist: [
          //   IconButton(
          //       onPressed: () => _firstStepOrder(),
          //       icon: const Icon(
          //         Icons.add_box,
          //         color: Colors.green,
          //       )),
          //   const SizedBox(width: 15),
          // ],
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
                        'List Order',
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: 500,
                      child: Text(
                        'Total Order : $totOrder',
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                    ),
                    Visibility(
                        visible: loadvisib,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 10, right: 30),
                              child: SkeletonOrderCard(),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 10, right: 30),
                              child: SkeletonOrderCard(),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 10, right: 30),
                              child: SkeletonOrderCard(),
                            ),
                          ],
                        ))
                  ],
                )),
            Visibility(
              visible: false,
              child: Container(
                child: TableCalendar<Event>(
                  eventLoader: getEventDate,
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(DateTime.now().year - 5),
                  lastDay: DateTime(DateTime.now().year + 5),
                  onDaySelected: (DateTime day, DateTime selected) {},
                  calendarFormat: CalendarFormat.month,
                  // ignore: prefer_const_constructors
                  calendarStyle: CalendarStyle(
                      selectedTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.red),
                      todayTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white)),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  // onDaySelected: (date){},
                  calendarBuilders: CalendarBuilders(
                    singleMarkerBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                    todayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder<List>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? Column(
                          children: [
                            OrderList(
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
      ),
    );
  }
}

class Event {
  final String title;
  Event({required this.title});
  @override
  String toString() => title;
}
