import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';

class MachineRealtime extends StatefulWidget {
  final String list;
  const MachineRealtime({Key? key, required this.list}) : super(key: key);

  @override
  _MachineRealtimeState createState() => _MachineRealtimeState();
}

class _MachineRealtimeState extends State<MachineRealtime> {
  ScrollController _scrollController = ScrollController();
  LocalStorage storageUser = LocalStorage('terra_app');
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  MapType _currentMapType = MapType.hybrid;
  List<LatLng> polylineLatLng = [];
  GoogleMapController? _controller;
  Set<Polyline> _polylines = HashSet<Polyline>();
  List<LatLng> polyPoints = [];
  List coordinateToSend = [];

  _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(double.parse(data['last_latitude'].toString()),
              double.parse(data['last_longitude'].toString())),
          zoom: 18),
    ));
    setState(() {
      _markers.add(
        Marker(
          draggable: false,
          markerId: MarkerId(data['no_engine'].toString()),
          position: LatLng(double.parse(data['last_latitude'].toString()),
              double.parse(data['last_longitude'].toString())),
          infoWindow: InfoWindow(title: data['last_location']),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setMapMarker();
    convertlist();
    Timer(const Duration(milliseconds: 1000), () {
      // Navigator.of(context).pop();
    });
  }

  BitmapDescriptor? pinLocationIcon;
  Future setMapMarker() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'assets/tractor40.png');
  }

  // CONVERT DATA
  var data;
  void convertlist() {
    var tes = jsonDecode(widget.list);
    setState(() {
      data = tes;
    });
  }
  // END CONVERT DATA

  Future<bool> backtoDashboard() {
    Navigator.pushNamed(context, '/Dashboard');
    return Future.value(true);
  }

  _onMapTypeButtonPressed() {
    setState(() {
      if (_currentMapType == MapType.hybrid) {
        _currentMapType = MapType.normal;
      } else {
        _currentMapType = MapType.hybrid;
      }
    });
  }

  String tombolRealtime = 'Non-Live Tracking';
  Color warnaTombol = Colors.red;
  String tombolTracking = 'Lihat Riwayat Perjalanan';
  Color warnaTombolTracking = Colors.orange.shade800;
  bool realVisib = false;
  bool visibTrackForm = false;
  Timer? timer;

  @override
  void dispose() {
    if (timer!.isActive) timer!.cancel();
    super.dispose();
  }

  bool statusRT = false;
  Future switchRealtime() async {
    if (statusRT == false) {
      timerStart().then((value) => liveLocation());
      setState(() {
        statusRT = true;
        realVisib = true;
        tombolRealtime = 'Live Tracking';
        warnaTombol = Colors.green;
      });
    } else {
      // super.dispose();
      _onMapCreated(_controller!);
      setState(() {
        timer!.cancel();
        statusRT = false;
        realVisib = false;
        tombolRealtime = 'Non-Live Tracking';
        warnaTombol = Colors.red;
      });
      // super.dispose();
    }
  }

  Future timerStart() async {
    var oMachine = data;

    if (oMachine['last_latitude'] != null ||
        oMachine['last_longitude'] != null) {
      timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        liveLocation();
      });
    } else {
      timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        setState(() {
          Fluttertoast.showToast(
              msg: "Perhatian! Koordinat GPS pada mesin ini tidak ditemukan.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              // timeInSecForIos: 10,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      });
    }
  }

  String statusMesin = 'Mencari...';
  String alamatMesin = 'Mencari...';
  String kecepatanMesin = 'Mencari...';
  void liveLocation() async {
    final GoogleMapController scontroller = await _controller!;
    _markers.clear();
    _polylines.clear();
    hideSlider = false;
    visibTrackForm = false;
    warnaTombolTracking = Colors.orange.shade800;
    tombolTracking = 'Lihat Riwayat Perjalanan';

    var oMachine = data;
    Uri urllive = Uri.parse("https://api.terra-id.com/tracking");
    Map datalive = {
      "id_mesin": oMachine['id'],
      "target": "tracking",
      "type_submit": "lastPositionById"
    };
    final http.Response response = await http.post(urllive, body: datalive);
    var ghg = jsonDecode(response.body);
    print("getMachine: $ghg");
    var key = ghg['data']['key_gps'];
    // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    // String prettyprint = encoder.convert(ghg);
    // log("${ghg['data']['coordinat']}");
    setState(() {
      statusMesin = "${ghg['data']['status_mesin']}";
      alamatMesin = "${ghg['data']['location']}";
      kecepatanMesin =
          "${ghg['data']['raw']['data'][key]['realtime']['speed']} km/jam";
      scontroller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(double.parse(ghg['data']['coordinat']['latitude']),
                double.parse(ghg['data']['coordinat']['longitude'])),
            zoom: 18),
      ));
    });

    _markers.add(
      Marker(
        draggable: false,
        markerId: MarkerId(oMachine['no_engine'].toString()),
        position: LatLng(double.parse(ghg['data']['coordinat']['latitude']),
            double.parse(ghg['data']['coordinat']['longitude'])),
        infoWindow: InfoWindow(title: oMachine['nama_kendaraan']),
        icon: pinLocationIcon!,
      ),
    );

    polylineLatLng.add(LatLng(
        double.parse(ghg['data']['coordinat']['latitude']),
        double.parse(ghg['data']['coordinat']['longitude'])));

    _polylines.add(Polyline(
      polylineId: PolylineId("1"),
      points: polylineLatLng,
      width: 2,
      color: Colors.blue,
    ));
  }

  List rangeSlideArray = [];
  String timeAwal = "Waktu Awal";
  String timeAkhir = "Waktu Akhir";
  double minVal = 0.0;
  double maxVal = 100.0;
  int divRange = 100;
  bool hideSlider = false;
  Color rangeColor = Colors.white12;
  Color rangeColor2 = Colors.white12;
  RangeValues rangeslideV = RangeValues(1, 100);

  Widget textcari = const Text("Lihat riwayat perjalanan");
  Future<void> _getTrack(
      String idMesin, DateTime _dateAwal, DateTime _dateAkhir) async {
    final GoogleMapController controller = await _controller!;

    Map data = {
      "id_mesin": idMesin,
      "waktu_mulai": _dateAwal.toString(),
      "waktu_selesai": _dateAkhir.toString(),
      "submit": "getUnitTrackRecord"
    };
    // log("datasend: $data");
    Uri url = Uri.parse('https://client.terra-id.com/action/v1.php');
    http.post(url, body: data).then((response) {
      print("Response: ${response.body}");

      if (response.body == '[]') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Dialogmodal(
              vartitle: "Info",
              varcontent: "Perjalanan mesin belum ditemukan",
            );
          },
        );
        setState(() {
          textcari = const Text("Lihat riwayat perjalanan");
        });
      } else {
        rangeSlideArray = jsonDecode(response.body);
        polylineLatLng.clear();
        List unlce = jsonDecode(response.body);
        String lati = unlce[0]['LatitudeHistory'];
        String longi = unlce[0]['LongitudeHistory'];
        unlce.forEach((ele) {
          polylineLatLng.add(LatLng(double.parse(ele['LatitudeHistory']),
              double.parse(ele['LongitudeHistory'])));
        });
        setState(() {
          textcari = const Text("Lihat riwayat perjalanan");
          timeAwal = "${rangeSlideArray.first['historyFullDate']}";
          timeAkhir = "${rangeSlideArray.last['historyFullDate']}";

          maxVal = unlce.length.toDouble();
          divRange = unlce.length - 1;
          hideSlider = true;
          rangeslideV = RangeValues(0, maxVal);
          // log("${unlce.length}");
          _polylines.add(Polyline(
            polylineId: PolylineId("0"),
            points: polylineLatLng,
            width: 2,
            color: Colors.redAccent,
          ));
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(lati), double.parse(longi)),
                zoom: 20),
          ));
          // print(storageUser);
          rangeColor = Colors.green.shade700;
          rangeColor2 = Colors.green.shade200;
          Fluttertoast.showToast(
              msg:
                  "Geser tuas ke kiri dan ke kanan untuk melihat pergerakan mesin",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              // timeInSecForIos: 1,
              backgroundColor: Colors.green[300],
              textColor: Colors.white,
              fontSize: 16.0);
        });
        //limit set state
      }
    });
  }

  void polyRangeSlider(int startKey, int endKey) async {
    final GoogleMapController controller = await _controller!;
    polylineLatLng.clear();
    // log("$startKey - $endKey");

    List rangePolyline = endKey == 0
        ? rangeSlideArray.toList()
        : rangeSlideArray.getRange(startKey, endKey).toList();
    String lati = rangePolyline[0]['LatitudeHistory'];
    String longi = rangePolyline[0]['LongitudeHistory'];
    rangePolyline.forEach((elenew) {
      polylineLatLng.add(LatLng(double.parse(elenew['LatitudeHistory']),
          double.parse(elenew['LongitudeHistory'])));
    });
    setState(() {
      timeAwal = "${rangePolyline.first['historyFullDate']}";
      timeAkhir = "${rangePolyline.last['historyFullDate']}";
      // label = RangeLabels("${rangePolyline.first['historyFullDate']}", "${rangePolyline.last['historyFullDate']}");
      // log("${rangePolyline.first['historyFullDate']}");
      // log("${unlce.length}");
      _polylines.add(Polyline(
        polylineId: const PolylineId("1"),
        points: polylineLatLng,
        width: 2,
        color: Colors.orange,
      ));
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(double.parse(lati), double.parse(longi)), zoom: 20),
      ));
    });
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
    var theme = storageUser.getItem('theme_config')['value'];
    return WillPopScope(
        onWillPop: backtoDashboard,
        child: Scaffold(
          body: CustomScrollView(controller: _scrollController, slivers: [
            SliverAppBar(
                backgroundColor:
                    theme == 'light' ? Color(0XFFF3F3F3) : Colors.grey.shade800,
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios,
                        color: _currentMapType == MapType.normal
                            ? Colors.grey.shade800
                            : Color(0XFFF3F3F3))),
                title: Container(
                    child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Text(
                            // ignore: prefer_adjacent_string_concatenation
                            "${data['nama_kendaraan']}",
                            style: TextStyle(
                                color: _currentMapType == MapType.normal
                                    ? Colors.grey.shade800
                                    : Color(0XFFF3F3F3)),
                          ),
                          width: 200,
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            "${data['jenis_kendaraan']}-${data['tipe_kendaraan']}",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _currentMapType == MapType.normal
                                    ? Colors.grey.shade800
                                    : Color(0XFFF3F3F3)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
                expandedHeight: MediaQuery.of(context).size.height * 0.65,
                // pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    child: Stack(children: <Widget>[
                      GoogleMap(
                        zoomControlsEnabled: false,
                        mapType: _currentMapType,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-2.548926, 118.0148634),
                          zoom: 2,
                        ),
                        markers: _markers,
                        polygons: _polygons,
                        polylines: _polylines,
                        onTap: (LatLng latLng) {
                          // _onTapMarkerAdd(latLng);
                        },
                        gestureRecognizers: Set()
                          ..add(Factory<EagerGestureRecognizer>(
                              () => EagerGestureRecognizer())),
                      ),
                      Visibility(
                        visible: hideSlider,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 20),
                            child: Container(
                              decoration: const BoxDecoration(
                                // color: Colors.white10,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                              color: Colors.green),
                                          child: Text(
                                            "$timeAwal",
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          )),
                                      Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                              color: Colors.green),
                                          child: Text(
                                            "$timeAkhir",
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          )),
                                    ],
                                  ),
                                  Container(
                                    // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: RangeSlider(
                                      inactiveColor: rangeColor2,
                                      activeColor: rangeColor,
                                      min: 0,
                                      max: maxVal.toDouble(),
                                      values: rangeslideV,
                                      // labels: label,
                                      onChanged: (range) {
                                        setState(() {
                                          rangeslideV = range;
                                          // print("${rangeslideV}");
                                          polyRangeSlider(
                                              rangeslideV.start.toInt(),
                                              rangeslideV.end.toInt());
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 12.0),
                              CircleSmallButton(
                                size: 20,
                                function: () {
                                  _onMapTypeButtonPressed();
                                },
                                icon: Icons.map,
                                iconColor: Colors.white,
                                bgColor: Colors.green,
                              ), //_onMapTypeButtonPressed
                              const SizedBox(height: 12.0),
                              // CircleSmallButton(
                              //   function: () {
                              //     _clearAllMarkers();
                              //   },
                              //   icon: Icons.location_off,
                              //   size: 20,
                              //   iconColor: Colors.white,
                              //   bgColor: Colors.green,
                              // ), //_clearAllMarkers
                              // const SizedBox(height: 12.0),
                              // CircleSmallButton(
                              //     function: () {
                              //       _calculateArea();
                              //     },
                              //     icon: Icons.calculate,
                              //     iconColor: Colors.white,
                              //     bgColor: Colors.green,
                              //     size: 20), //_calculateArea
                            ],
                          ),
                        ),
                      )
                    ]),
                  ),
                ),
                actions: []),
            SliverList(
                delegate: SliverChildListDelegate(<Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 1,
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  // controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: DefaultButton(
                          onPressed: () {
                            setState(() {
                              if (visibTrackForm == false) {
                                visibTrackForm = true;
                                warnaTombolTracking = Colors.red;
                                tombolTracking = 'Tutup';
                              } else {
                                visibTrackForm = false;
                                warnaTombolTracking = Colors.orange.shade800;
                                tombolTracking = 'Lihat Riwayat Perjalanan';
                              }
                              if (statusRT == true) {
                                switchRealtime();
                              } else {}
                            });
                          },
                          height: 40,
                          label: tombolTracking,
                          labelColor: Colors.white,
                          color: warnaTombolTracking),
                    ),
                    Visibility(
                        visible: visibTrackForm,
                        child: Column(
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 20),
                                width: 500,
                                child: const Text('Waktu Mulai',
                                    textAlign: TextAlign.start)),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  pickDateTime(context);
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
                                child: const Text('Waktu Selesai',
                                    textAlign: TextAlign.start)),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  pickDateTime2(context);
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
                            Container(
                              padding: const EdgeInsets.only(top: 20),
                              child: DefaultButtonWidget(
                                onPressed: () {
                                  if (dateTime == null || dateTime2 == null) {
                                    showDialog(
                                      // barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const DialogStatus(
                                            tipe: 'fail',
                                            label:
                                                'Lengkapi waktu mulai dan selesai');
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      textcari = const Center(
                                          child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ));
                                    });

                                    _getTrack(
                                        data['id'], dateTime!, dateTime2!);
                                  }
                                },
                                height: 40,
                                label: textcari,
                                labelColor: Colors.white,
                                color: Colors.orange.shade300,
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: DefaultButton(
                          onPressed: switchRealtime,
                          height: 40,
                          label: tombolRealtime,
                          labelColor: Colors.white,
                          color: warnaTombol),
                    ),
                    Visibility(
                        visible: realVisib,
                        child: Column(
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 0, top: 10),
                                width: 500,
                                child: const Text('Status Mesin',
                                    textAlign: TextAlign.start)),
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 5),
                                width: 500,
                                child: Text(statusMesin,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ))),
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 0, top: 10),
                                width: 500,
                                child: const Text('Kecepatan',
                                    textAlign: TextAlign.start)),
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 5),
                                width: 500,
                                child: Text(kecepatanMesin,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ))),
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 0, top: 10),
                                width: 500,
                                child: const Text('Lokasi',
                                    textAlign: TextAlign.start)),
                            Container(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 5),
                                width: 500,
                                child: Text(alamatMesin,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ))),
                          ],
                        )),
                    Container(
                        padding: const EdgeInsets.only(bottom: 5, top: 20),
                        width: 500,
                        child: const Text('No Engine',
                            textAlign: TextAlign.start)),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          // pickDateTime(context);
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
                                child: Text(data['no_engine'])),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(bottom: 5, top: 20),
                        width: 500,
                        child: const Text('Tanggal Pasang GPS',
                            textAlign: TextAlign.start)),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          // pickDateTime(context);
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
                                child: Text(data['tanggal_pasang'])),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])),
          ]),
        ));
  }
}
