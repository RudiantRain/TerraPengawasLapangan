import 'dart:async';
import 'dart:collection';
// import 'dart:developer';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

import 'package:location/location.dart';
import 'package:terra_korwil/pages/trans_cost.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/stateless.dart';

class TransManual extends StatefulWidget {
  final String idPokja;
  final String idCustomer;
  final String nama;
  final String nohp;
  const TransManual({
    Key? key,
    required this.idPokja,
    required this.idCustomer,
    required this.nama,
    required this.nohp,
  }) : super(key: key);

  @override
  _TransManualState createState() => _TransManualState();
}

class _TransManualState extends State<TransManual> {
  LocalStorage storageUser = LocalStorage('terra_app');
  TextEditingController estimasiHarga = TextEditingController();
  TextEditingController estimasiLuas = TextEditingController();
  TextEditingController alamatLahan = TextEditingController();
  TextEditingController keteranganNote = TextEditingController();
  TextEditingController namaLahan = TextEditingController();
  String? luasPlot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    getMachine().then((value) => addPackage());
  }

  // CONVERT DATA
  var data;
  // END CONVERT DATA

  Widget notifRangeHour = Container();

  // SET VALUE
  double? initLat;
  double? initLng;
  // GET MACHINELIST
  String? _stringIDMachine;
  List storedMachine = [];
  List arrayMachine = [];
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
    soMachine.forEach((en) {
      storedMachine.add(en['id'] + "-" + en['nama_kendaraan']);
    });
    setState(() {
      arrayPackage = List.from(status);
      // idMesin = status['id'].toString();
    });
  }
  // GET MACHINE END

  // MAP CONFIG
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
  }

  Position? _currentPosition;
  StreamSubscription? _locationSubscription;
  Marker? marker;
  Circle? circle;
  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/tractor(biru).png");
    return byteData.buffer.asUint8List();
  }

  Location _locationTracker = Location();
  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    setState(() {
      marker = Marker(
          markerId: const MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading!,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: const CircleId("car"),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(location.latitude!, location.longitude!),
          tilt: 0,
          zoom: 20.00)));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  _onTapMarkerAdd(LatLng latLng) {
    setState(() {
      polyPoints.add(latLng);
      _drawPolygon(polyPoints); //ARRAY PLYGON LATLNG DISNI
      _markers.add(
        Marker(
          draggable: true,
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          infoWindow: const InfoWindow(title: 'title', snippet: 'snippet'),
          icon: BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng latLng) {
            print(latLng);
            print(latLng.toString());
          },
        ),
      );
    });
    // _calculateArea();
  }

  _drawPolygon(List<LatLng> listLatLng) {
    var rng = math.Random();
    setState(() {
      _polygons.add(Polygon(
          polygonId: PolygonId("${rng.nextInt(1000)}"),
          points: listLatLng,
          fillColor: Colors.green[200]!.withOpacity(0.9),
          strokeWidth: 3,
          strokeColor: Colors.greenAccent));
    });
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

  _clearAllMarkers() {
    if (polyPoints.length > 2) {
      setState(() {
        _markers.clear();
        _polygons.clear();
        polyPoints.clear();
        coordinateToSend.clear();
      });
    } else {
      Fluttertoast.showToast(
          msg:
              "Anda belum membuat plotting, klik pada peta untuk memulai plotting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // timeInSecForIos: 1,
          backgroundColor: Colors.green[300],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _calculateArea() {
    if (polyPoints.length > 2) {
      polyPoints.add(polyPoints[0]);
      // print(calculatePolygonArea(polyPoints));
      // log("${polyPoints[0].latitude}");
      String lng = '"lng"';
      String lat = '"lat"';
      polyPoints.forEach((ele) {
        coordinateToSend.add({lat: ele.latitude, lng: ele.longitude});
      });
      setState(() {
        double luasHitungPaket = (calculatePolygonArea(polyPoints) / 10000);
        double luasHa = (calculatePolygonArea(polyPoints));
        luasPlot = luasHa.toStringAsFixed(6);
        estimasiLuas.text = luasHa.toStringAsFixed(2);
        double hargaDefault = pricePackage;
        double total = luasHitungPaket * hargaDefault;
        estimasiHarga.text = total.ceil().toStringAsFixed(0);
        // print("$coordinateToSend");
      });
      Fluttertoast.showToast(
          msg: "Luas " +
              calculatePolygonArea(polyPoints).toStringAsFixed(3) +
              " m2",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[300],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg:
              "Anda belum membuat plotting, klik pada peta untuk memulai plotting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // timeInSecForIos: 1,
          backgroundColor: Colors.green[300],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  static double calculatePolygonArea(List coordinates) {
    double area = 0;

    if (coordinates.length > 2) {
      for (var i = 0; i < coordinates.length - 1; i++) {
        var p1 = coordinates[i];
        var p2 = coordinates[i + 1];
        area += convertToRadian(p2.longitude - p1.longitude) *
            (2 +
                math.sin(convertToRadian(p1.latitude)) +
                math.sin(convertToRadian(p2.latitude)));
      }
      area = area * 6378137 * 6378137 / 2;
    }

    return area.abs();
  }

  static double convertToRadian(double input) {
    return input * math.pi / 180;
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

  // MAP CONFIG END

  // PAKET SELECT CONFIG
  String? _stringIDpackage;
  List storedPackage = [];
  List arrayPackage = [];
  Future addPackage() async {
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idUser,
      "target": 'user_korwil',
      "type_submit": 'getPaketPekerjaan'
    });
    var getPket = jsonDecode(response.body);
    List soMachine = List.from(getPket);
    soMachine.forEach((en) {
      storedPackage.add(en['id'] + "-" + en['nama_paket']);
    });
    setState(() {
      arrayPackage = List.from(getPket);
    });
    // print('arraypackage: $arrayPackage');
  }

  String? selectedIDpackage;
  double pricePackage = 0;
  void filterPrice(String idPaket) {
    var splitId = idPaket.split("-");

    List store;
    store = arrayPackage.where((e) => e['id'] == splitId[0]).toList();
    setState(() {
      pricePackage = double.parse(store[0]['harga']);
      estimasiHarga.text = pricePackage.toString();
      // print('store: ${arrayPackage}');
    });
  }
  //PAKET SELECT ENDS

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
    return Scaffold(
      appBar: CustomAppBar(
        label: 'Transaksi Manual',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
        children: [
          Container(child: notifRangeHour),
          const SizedBox(height: 20),
          Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  width: 500,
                  child: const Text('Mesin', textAlign: TextAlign.start)),
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
                      "Pilih Mesin",
                    ),
                    value: _stringIDMachine,
                    items: storedMachine.map((value) {
                      return DropdownMenuItem(
                        child: SelectboxText(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _stringIDMachine = value.toString();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 5, top: 20),
                  width: 500,
                  child: const Text('Paket Pekerjaan',
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
                  padding: const EdgeInsets.only(left: 20),
                  child: DropdownButton(
                    hint: const Text(
                      "Pilih Paket",
                    ),
                    value: _stringIDpackage,
                    items: storedPackage.map((value) {
                      return DropdownMenuItem(
                        child: SelectboxText(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (value) {
                      filterPrice(value.toString());
                      setState(() {
                        _stringIDpackage = value.toString();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
              padding: const EdgeInsets.only(bottom: 5, top: 20),
              width: 500,
              child: const Text('Waktu Mulai', textAlign: TextAlign.start)),
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
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
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
              padding: const EdgeInsets.only(bottom: 5, top: 20),
              width: 500,
              child: const Text('Waktu Selesai', textAlign: TextAlign.start)),
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
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                          label: 'Lengkapi waktu mulai dan selesai');
                    },
                  );
                } else {
                  var split = _stringIDMachine!.split('-');
                  setState(() {
                    textcari = const Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ));
                  });

                  _getTrack(split[0], dateTime!, dateTime2!);
                }
              },
              height: 40,
              label: textcari,
              labelColor: Colors.white,
              color: Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 15),
          InputTextWhite(label: 'Nama Lahan Plotting', controller: namaLahan),
          Container(
              padding: const EdgeInsets.only(bottom: 5, top: 15),
              width: 500,
              child: const Text('Plotting Lahan Pekerjaan',
                  textAlign: TextAlign.start)),
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
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
                  _onTapMarkerAdd(latLng);
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
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: Container(
                      decoration: const BoxDecoration(
                        // color: Colors.white10,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration:
                                      const BoxDecoration(color: Colors.green),
                                  child: Text(
                                    "$timeAwal",
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration:
                                      const BoxDecoration(color: Colors.green),
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
                                  polyRangeSlider(rangeslideV.start.toInt(),
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
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
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
                      CircleSmallButton(
                        function: () {
                          _clearAllMarkers();
                        },
                        icon: Icons.location_off,
                        size: 20,
                        iconColor: Colors.white,
                        bgColor: Colors.green,
                      ), //_clearAllMarkers
                      const SizedBox(height: 12.0),
                      CircleSmallButton(
                          function: () {
                            _calculateArea();
                          },
                          icon: Icons.calculate,
                          iconColor: Colors.white,
                          bgColor: Colors.green,
                          size: 20), //_calculateArea
                    ],
                  ),
                ),
              )
            ]),
          ),
          const SizedBox(height: 10),
          InputTextWhite(
              label: 'Luas Plotting (m2)',
              controller: estimasiLuas,
              obscuring: false),
          InputTextWhite(
              label: 'Estimasi Harga (Rp)',
              controller: estimasiHarga,
              obscuring: false),
          InputTextWhite(
              label: 'Alamat', controller: alamatLahan, obscuring: false),
          InputTextWhite(
              label: 'Catatan', controller: keteranganNote, obscuring: false),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: DefaultButton(
                onPressed: () {
                  if (estimasiHarga.text == '' ||
                      estimasiLuas.text == '' ||
                      namaLahan.text == '' ||
                      dateTime == null ||
                      dateTime2 == null ||
                      _stringIDpackage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi data.'),
                      ),
                    );
                  } else {
                    setState(() {
                      loginText = 'Proses';
                    });
                    inputCost();
                  }
                },
                height: 40,
                label: loginText,
                labelColor: Colors.white,
                color: Colors.green),
          ),
        ],
      ),
    );
  }

  String rescheduleText = 'Jadwalkan Ulang';
  String cancelText = 'Batalkan';
  String loginText = 'Jadikan Transaksi';
  Future simpanTransaksi() async {
    var idPokja = widget.idPokja;
    setState(() {
      loginText = 'Proses';
      print('POLYCOOR: ${coordinateToSend.toString()}');
    });
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    var split = _stringIDpackage!.split('-');
    var split2 = _stringIDMachine!.split('-');
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idUser,
      "id_pokja": idPokja,
      "waktu_mulai": timeAwal.toString(),
      "waktu_selesai": timeAkhir.toString(),
      "harga": estimasiHarga.text,
      "luas_area": estimasiLuas.text,
      "polygon": coordinateToSend.toString(),
      "id_paket": split[0],
      "id_mesin": split2[0],
      "id_lahan": '',
      "address": alamatLahan.text,
      "nama_lahan": namaLahan.text,
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

  Future inputCost() async {
    // _calculateArea();
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    var split = _stringIDpackage!.split('-');
    var split2 = _stringIDMachine!.split('-');
    var idPokja = widget.idPokja;
    var idCustomer = widget.idCustomer;

    if (polylineLatLng.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat perjalanan tidak ditemukan'),
        ),
      );
    } else {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransCost(
            idUser: idUser,
            idPokja: idPokja,
            idCustomer: idCustomer,
            idPaket: split[0],
            namaPaket: split[1],
            waktuMulai: timeAwal.toString(),
            waktuSelesai: timeAkhir.toString(),
            polygon: coordinateToSend.toString(),
            idMesin: split2[0].toString(),
            luasArea: estimasiLuas.text,
            harga: estimasiHarga.text,
            idLahan: '',
            alamatLahan: alamatLahan.text,
            namaLahan: namaLahan.text),
      ));
    }
  }
}
