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

class TransaksiDetail extends StatefulWidget {
  final String list;
  const TransaksiDetail({Key? key, required this.list}) : super(key: key);

  @override
  _TransaksiDetailState createState() => _TransaksiDetailState();
}

class _TransaksiDetailState extends State<TransaksiDetail> {
  ScrollController _scrollController = ScrollController();
  LocalStorage storageUser = LocalStorage('terra_app');
  TextEditingController estimasiHarga = TextEditingController();
  TextEditingController estimasiLuas = TextEditingController();
  TextEditingController alamatLahan = TextEditingController();
  TextEditingController keteranganNote = TextEditingController();
  TextEditingController namaLahan = TextEditingController();
  TextEditingController namaMesin = TextEditingController();
  String? luasPlot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convertlist();
    Timer(const Duration(milliseconds: 1000), () {
      // Navigator.of(context).pop();
      setValue();
    });
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

  Widget notifRangeHour = Container();
  // CEK NOTIF RANGE_HOUR
  bool visibButton = true;
  rangeHour() {
    double rh = double.parse(data['acc_mitra'].toString());
    // double rh = 13;
    if (rh == 0) {
      setState(() {
        notifRangeHour =
            const StickerNotif(text: "Belum dikonfirmasi", tipe: 'warning');
        visibButton = false;
      });
    } else {
      setState(() {
        notifRangeHour =
            const StickerNotif(text: "Dikonfirmasi", tipe: 'success');
        // BISA DI JADIKAN TRANSAKSI
      });
    }
  }
  //

  // SET VALUE
  double? initLat;
  double? initLng;
  void setValue() async {
    List koor_polygon = jsonDecode(data['koor']);
    koor_polygon.forEach((e) {
      polyPoints.add(LatLng(double.parse(e['lat'].toString()),
          double.parse(e['lng'].toString())));
      coordinateToSend.add({'"lat"': e['lat'], '"lng"': e['lng']});
    });
    setState(() {
      addPackage().then((value) => filterPrice(_stringIDpackage!));
      _stringIDpackage = data['id_paket'] + "-" + data['nama_paket'];
      dateTime = DateTime.parse(data['waktu_mulai']);
      dateTime2 = DateTime.parse(data['waktu_selesai']);
      initLat = double.parse(koor_polygon[0]['lat'].toString());
      initLng = double.parse(koor_polygon[0]['lng'].toString());
      _drawPolygon(polyPoints);
      Timer(const Duration(milliseconds: 500), () {
        rangeHour();
        getFieldLocation();
        _calculateArea();
        // alamatLahan.text = data['alamat'];
        keteranganNote.text = data['keterangan'] ?? '';
        Timer(const Duration(milliseconds: 500), () {
          _getTrack(data['id_mesin'], dateTime!, dateTime2!).then((val) {
            estimasiHarga.text = data['harga'];
            namaLahan.text = data['nama_lahan'];
            namaMesin.text = data['nama_kendaraan'];
            // _calculateArea();
          });
        });
      });
    });
    // print('koor: $coordinateToSend');
  }
  // END SET VALUE

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

  void getFieldLocation() async {
    try {
      // Uint8List imageData = await getMarker();
      // var location = await _locationTracker.getLocation();

      // updateMarkerAndCircle(location, imageData);
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(initLat!, initLng!),
          tilt: 0,
          zoom: 18.00)));
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
        estimasiLuas.text = luasHa.toStringAsFixed(3);
        double hargaDefault = pricePackage;
        double total = luasHitungPaket * hargaDefault;
        estimasiHarga.text = data['harga'];
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
      // log("Response: ${response.body}");

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
      } else {
        // rangeSlideArray = jsonDecode(response.body);
        polylineLatLng.clear();
        List unlce = jsonDecode(response.body);
        String lati = unlce[0]['LatitudeHistory'];
        String longi = unlce[0]['LongitudeHistory'];
        
        unlce.forEach((ele) {
          if (DateTime.parse(ele['historyFullDate'].toString())
                  .isBefore(dateTime!) ||
              DateTime.parse(ele['historyFullDate'].toString())
                  .isAfter(dateTime2!)) {
            // GAK NGAPA2IN
          } else {
            polylineLatLng.add(LatLng(double.parse(ele['LatitudeHistory']),
                double.parse(ele['LongitudeHistory'])));
            rangeSlideArray.add(ele);
          }
        });
        setState(() {
          print(rangeSlideArray);
          timeAwal = "${rangeSlideArray.first['historyFullDate']}";
          timeAkhir = "${rangeSlideArray.last['historyFullDate']}";

          maxVal = rangeSlideArray.length.toDouble();
          divRange = rangeSlideArray.length - 1;
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
                zoom: 18),
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
      if (DateTime.parse(elenew['historyFullDate'].toString())
              .isBefore(dateTime!) ||
          DateTime.parse(elenew['historyFullDate'].toString())
              .isAfter(dateTime2!)) {
        // GAK NGAPA2IN
      } else {
        polylineLatLng.add(LatLng(double.parse(elenew['LatitudeHistory']),
            double.parse(elenew['LongitudeHistory'])));
      }
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
            target: LatLng(double.parse(lati), double.parse(longi)), zoom: 18),
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
    store = arrayPackage.where((e) => e['id'] == data['id_paket']).toList();
    setState(() {
      pricePackage = double.parse(store[0]['harga']);
      estimasiHarga.text = data['harga'];
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

  Future<bool> backtoDashboard() {
    Navigator.pushNamed(context, '/Dashboard');
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    var _onpressed;
    if (enabled) {
      _onpressed = () {
        checkerOrder();
      };
    } else {
      _onpressed = null;
    }
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
                            "${data['id_invoice']}",
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
                            "Pokja: ${data['nama_pokja']}, Customer: ${data['nama_customer']}",
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
                              const SizedBox(height: 12.0),
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
                    Container(child: notifRangeHour),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(bottom: 5),
                            width: 500,
                            child: const Text('Paket Pekerjaan',
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
                                    child: Text(data['nama_paket'])),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        padding: const EdgeInsets.only(bottom: 5, top: 20),
                        width: 500,
                        child: const Text('Waktu Mulai',
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
                                child: Text(getTextDate())),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(bottom: 5, top: 20),
                        width: 500,
                        child: const Text('Waktu Selesai',
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
                                child: Text(getTextDate2())),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputTextWhite(
                      label: 'Nama Mesin',
                      controller: namaMesin,
                      obscuring: false,
                      readonly: true,
                    ),
                    InputTextWhite(
                      label: 'Nama Lahan Plotting',
                      controller: namaLahan,
                      obscuring: false,
                      readonly: true,
                    ),
                    InputTextWhite(
                      label: 'Luas Plotting (Ha)',
                      controller: estimasiLuas,
                      obscuring: false,
                      readonly: true,
                    ),
                    InputTextWhite(
                      label: 'Estimasi Harga (Rp)',
                      controller: estimasiHarga,
                      obscuring: false,
                      readonly: true,
                    ),
                    // InputTextWhite(
                    //     label: 'Alamat',
                    //     controller: alamatLahan,
                    //     obscuring: false),
                    InputTextWhite(
                      label: 'Catatan',
                      controller: keteranganNote,
                      obscuring: false,
                      readonly: true,
                    ),
                    // Visibility(
                    //   visible: visibButton,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 15),
                    //     child: DefaultButton(
                    //         onPressed: _onpressed,
                    //         height: 40,
                    //         label: loginText,
                    //         labelColor: Colors.white,
                    //         color: Colors.green),
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(vertical: 15),
                    //   child: DefaultButton(
                    //     onPressed: () {
                    //       pickDateTime(context)
                    //           .then((value) => confirmReschedule());
                    //     },
                    //     height: 40,
                    //     label: rescheduleText,
                    //     labelColor: Colors.white,
                    //     color: Colors.orange.shade300,
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(vertical: 15),
                    //   child: DefaultButton(
                    //     onPressed: () {
                    //       _confirmCancel();
                    //     },
                    //     height: 40,
                    //     label: cancelText,
                    //     labelColor: Colors.white,
                    //     color: Colors.red,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ])),
          ]),
        ));
  }

  bool enabled = true;
  void checkerOrder() async {
    if (estimasiHarga.text == '' ||
        estimasiLuas.text == '' ||
        // namaLahan.text == '' ||
        dateTime == null ||
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
      simpanTransaksi();
    }
  }

  String rescheduleText = 'Jadwalkan Ulang';
  Future confirmReschedule() async {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Waktu pekerjaan diubah menjadi: '),
                  Text(
                    dateTime.toString().substring(0, 16),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                            reschedule().then((value) =>
                                Navigator.pushNamed(context, '/Dashboard'));
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
              ));
        });
  }

  Future reschedule() async {
    setState(() {
      rescheduleText = 'Proses';
    });
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': idUser,
      'no_order': data['no_order'],
      'date': dateTime.toString(),
      'target': 'user_korwil',
      'type_submit': 'rescheduleOrder'
    });

    if (response.statusCode == 200) {
      var status = jsonDecode(response.body);
      if (status['status'] == 'success') {
        setState(() {
          rescheduleText = 'Jadwalkan Ulang';
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return const DialogStatus(
                  tipe: 'success', label: 'Berhasil mengubah tanggal');
            },
          );
        });
      } else {
        setState(() {
          rescheduleText = 'Jadwalkan Ulang';
        });
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(
                tipe: 'fail', label: 'Order gagal disimpan');
          },
        );
      }
    } else {
      // print("${response.statusCode}");
      setState(() {
        rescheduleText = 'Jadwalkan Ulang';
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

  _confirmCancel() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogYesNo(
              vartitle: 'Membatalkan Jadwal Pekerjaan',
              varcontent: 'Apakah anda sudah sangat yakin?',
              textYes: 'Ya',
              textNo: 'Tidak',
              funYes: () {
                cancelOrder();
              },
              funNo: () {
                Navigator.pop(context);
              });
        });
  }

  String cancelText = 'Batalkan';
  Future cancelOrder() async {
    setState(() {
      cancelText = 'Proses';
    });
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': idUser,
      'no_order': data['no_order'],
      'target': 'user_korwil',
      'type_submit': 'removeOrder'
    });

    if (response.statusCode == 200) {
      var status = jsonDecode(response.body);
      if (status['status'] == 'success') {
        setState(() {
          cancelText = 'Batalkan';
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return const DialogStatus(
                  tipe: 'success', label: 'Jadwal dibatalkan');
            },
          );
          // Navigator.pushNamed(context, '/Dashboard');
        });
      } else {
        setState(() {
          cancelText = 'Batalkan';
        });
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const DialogStatus(
                tipe: 'fail', label: 'Gagal membatalkan.');
          },
        );
      }
    } else {
      // print("${response.statusCode}");
      setState(() {
        cancelText = 'Batalkan';
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

  String loginText = 'Jadikan Transaksi';
  Future simpanTransaksi() async {
    var idPokja = data['id_pokja'];
    setState(() {
      loginText = 'Proses';
      print('POLYCOOR: ${coordinateToSend.toString()}');
    });
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    var split = _stringIDpackage!.split('-');
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idUser,
      "id_pokja": idPokja,
      "id_paket": split[0],
      "no_order": data['no_order'],
      "waktu_mulai": timeAwal.toString(),
      "waktu_selesai": timeAkhir.toString(),
      "polygon": coordinateToSend.toString(),
      "id_mesin": data['id_kendaraan'],
      "luas_area": estimasiLuas.text,
      "harga": estimasiHarga.text,
      "target": "user_korwil",
      "type_submit": "addtransaction"
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
