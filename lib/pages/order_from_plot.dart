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

class OrderFromPlot extends StatefulWidget {
  final String list;
  const OrderFromPlot({Key? key, required this.list}) : super(key: key);

  @override
  _OrderFromPlotState createState() => _OrderFromPlotState();
}

class _OrderFromPlotState extends State<OrderFromPlot> {
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
    getMachine();
    addPackage();
    convertlist().then((value) => setValue());
  }

  // CONVERT DATA
  var data;
  Future convertlist() async {
    var tes = jsonDecode(widget.list);
    setState(() {
      data = tes;
    });
  }
  // END CONVERT DATA

  // SET VALUE
  double? initLat;
  double? initLng;
  void setValue() async {
    List koor_polygon = jsonDecode(data['polygon']);
    koor_polygon.forEach((e) {
      polyPoints.add(LatLng(double.parse(e['lat'].toString()),
          double.parse(e['lng'].toString())));
      coordinateToSend.add({'"lat"': e['lat'], '"lng"': e['lng']});
    });
    setState(() {
      initLat = double.parse(koor_polygon[0]['lat'].toString());
      initLng = double.parse(koor_polygon[0]['lng'].toString());
      _drawPolygon(polyPoints);
      Timer(const Duration(milliseconds: 500), () {
        namaLahan.text = data['nama'];
        alamatLahan.text = data['alamat'];
        Timer(const Duration(milliseconds: 500), () {
          getFieldLocation();
          _calculateArea();
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
          zoom: 20.00)));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      // if (_locationSubscription != null) {
      //   _locationSubscription?.cancel();
      // }

      // _locationSubscription =
      //     _locationTracker.onLocationChanged.listen((newLocalData) {
      //   if (_controller != null) {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(location.latitude!, location.longitude!),
          tilt: 0,
          zoom: 18.00)));
      //     updateMarkerAndCircle(newLocalData, imageData);
      //   }
      // });
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
        luasPlot = luasHitungPaket.toStringAsFixed(6);
        estimasiLuas.text = luasHa.toStringAsFixed(3);
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

  // MAP CONFIG END
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

  // PAKET SELECT CONFIG
  String? _stringIDpackage;
  List storedPackage = [];
  List arrayPackage = [];
  void addPackage() async {
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
      // print('IDPOKJA : ${}');
    });
    print('$arrayPackage');
  }



  String? selectedIDpackage;
  double pricePackage = 0;
  void filterPrice(String idPaket) {
    var splitId = idPaket.split("-");
    List data = List.from(arrayPackage);
    List store;
    store = data.where((e) => e['id'] == splitId[0]).toList();
    setState(() {
      pricePackage = double.parse(store[0]['harga']);
      estimasiHarga.text = pricePackage.toString();
      // print('${store[0]['harga']}');
    });
  }
  //PAKET SELECT ENDS

  // TIME PICKERR CONFIG
  DateTime? dateTime;
  String getTextDate() {
    if (dateTime == null) {
      return 'Pilih Tanggal';
    } else {
      return DateFormat('MM/dd/yyyy HH:mm').format(dateTime!);
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
    return Scaffold(
      appBar: CustomAppBar(
        label: 'Order Plotting Lahan ${data['nama']}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
        children: [
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
                  padding: const EdgeInsets.only(left: 20, right: 20),
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
              child: const Text('Waktu Pekerjaan', textAlign: TextAlign.start)),
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
          const SizedBox(height: 10),
          InputTextWhite(
              label: 'Nama Lahan Plotting',
              controller: namaLahan,
              readonly: true),
          Container(
              padding: const EdgeInsets.only(bottom: 5, top: 20),
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
                          iconColor: Colors.white,
                          bgColor: Colors.green,
                          icon: Icons.map), //_onMapTypeButtonPressed
                      const SizedBox(height: 12.0),
                      CircleSmallButton(
                        function: () {
                          _clearAllMarkers();
                        },
                        icon: Icons.location_off,
                        iconColor: Colors.white,
                        bgColor: Colors.green,
                        size: 20,
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
              obscuring: false,
              readonly: true),
          InputTextWhite(
              label: 'Estimasi Harga (Rp)',
              controller: estimasiHarga,
              obscuring: false,
              readonly: true),
          InputTextWhite(label: 'Alamat', controller: alamatLahan),
          InputTextWhite(label: 'Catatan', controller: keteranganNote),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: DefaultButton(
                onPressed: _onpressed,
                height: 40,
                label: loginText,
                labelColor: Colors.white,
                color: Colors.green),
          ),
        ],
      ),
    );
  }

  bool enabled = true;
  void checkerOrder() async {
    if (estimasiHarga.text == '' ||
        estimasiLuas.text == '' ||
        namaLahan.text == '' ||
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
      simpanOrder();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String loginText = 'Buat Jadwal Kerja';
  Future simpanOrder() async {
    var idPokja = data['id_pokja'];
    setState(() {
      loginText = 'Proses';
      print('ID POKJA : $idPokja');
    });
    var idUser = await storageUser.getItem('data_user_login')['data']['id'];
    var split = _stringIDpackage!.split('-');
    var split2 = _stringIDMachine!.split('-');
    final http.Response response = await http.post(apiURI, body: {
      "id_korwil": idUser,
      "id_lahan": data['id_lahan'],
      "id_pokja": idPokja,
      "id_paket": split[0],
      "id_mesin": split2[0],
      "polygon": coordinateToSend.toString(),
      "date": dateTime.toString(),
      "price": estimasiHarga.text,
      "address": alamatLahan.text,
      "note": keteranganNote.text,
      "nama_lahan": namaLahan.text,
      "luas_lahan": estimasiLuas.text,
      "target": "user_korwil",
      "type_submit": "addOrder"
    });
    print("${response.body}");
    if (response.statusCode == 200) {
      var status = jsonDecode(response.body);
      if (status['status'] == 'success') {
        setState(() {
          loginText = 'Buat Jadwal Kerja';
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return const DialogStatus(
                  tipe: 'success', label: 'Berhasil membuat transaksi');
            },
          );
        });
      } else {
        setState(() {
          loginText = 'Buat Jadwal Kerja';
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
        loginText = 'Buat Jadwal Kerja';
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
