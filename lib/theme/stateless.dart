// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:terra_korwil/pages/cost_daily_detail.dart';
import 'package:terra_korwil/pages/customer_insert.dart';
import 'package:terra_korwil/pages/customer_list.dart';
import 'package:terra_korwil/pages/machine_realtime.dart';
import 'package:terra_korwil/pages/order_detail.dart';
import 'package:terra_korwil/pages/order_from_plot.dart';
import 'package:terra_korwil/pages/order_insert.dart';
import 'package:terra_korwil/pages/pokja_edit.dart';
import 'package:terra_korwil/pages/trans_detail.dart';
import 'package:terra_korwil/pages/trans_manual.dart';
import 'package:terra_korwil/pages/trans_manual_from_plot.dart';
import 'package:terra_korwil/theme/config.dart';
import 'package:terra_korwil/theme/pallete.dart';
import 'package:localstorage/localstorage.dart';

class InputText extends StatelessWidget {
  final bool obscuring;
  final controller;
  final label;
  final icon;
  const InputText({
    required this.obscuring,
    this.controller,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Colors.green)),
        color: Colors.white10,
      ),
      padding: const EdgeInsets.only(left: 10),
      child: TextFormField(
        obscureText: obscuring,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

class TextInputStandart extends StatelessWidget {
  final controller;
  final label;
  const TextInputStandart({
    Key? key,
    this.controller,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white30,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent)),
        ),
      ),
    );
  }
}

class CircleSmallButton extends StatelessWidget {
  final VoidCallback function;
  final icon;
  final iconColor;
  final bgColor;
  final double size;
  const CircleSmallButton(
      {Key? key,
      required this.icon,
      required this.iconColor,
      required this.bgColor,
      required this.size,
      required this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: bgColor,
      child: Icon(
        icon,
        size: size,
        color: iconColor,
      ),
      heroTag: icon.toString(),
    );
    ;
  }
}

class DefaultButton extends StatelessWidget {
  final color;
  final VoidCallback onPressed;
  final label;
  final labelColor;
  final double height;
  const DefaultButton(
      {Key? key,
      this.label,
      this.color,
      this.labelColor,
      required this.height,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          child: Text(label, style: TextStyle(color: labelColor))),
    );
  }
}

class DefaultButtonWidget extends StatelessWidget {
  final color;
  final VoidCallback onPressed;
  final Widget label;
  final labelColor;
  final double height;
  const DefaultButtonWidget(
      {Key? key,
      required this.label,
      this.color,
      this.labelColor,
      required this.height,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          child: label,
        ));
  }
}

class Dialogmodal extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const Dialogmodal({this.vartitle, this.varcontent});
  final vartitle;
  final varcontent;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(vartitle),
      content: Text(varcontent),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text("Tutup"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class DialogYesNo extends StatelessWidget {
  const DialogYesNo(
      {this.vartitle,
      this.varcontent,
      this.textYes,
      required this.funYes,
      this.textNo,
      required this.funNo});
  final vartitle;
  final varcontent;
  final textYes;
  final textNo;
  final VoidCallback funYes;
  final VoidCallback funNo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(vartitle),
      content: Text(varcontent),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: Text(textYes),
          onPressed: funYes,
        ),
        TextButton(
          child: Text(textNo),
          onPressed: funNo,
        ),
      ],
    );
  }
}

class DialogStatus extends StatelessWidget {
  final String tipe;
  final String label;
  const DialogStatus({Key? key, required this.tipe, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Image gambar;
    if (tipe == 'fail') {
      gambar = Image.asset('assets/fail.png');
    } else {
      gambar = Image.asset('assets/success.png');
    }
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        height: 200,
        child: Padding(
          padding: EdgeInsets.fromLTRB(80, 12, 80, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: gambar,
              ),
              Container(
                  child: Text(label,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              TextButton(
                  onPressed: () {
                    if (tipe == 'fail') {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.pushNamed(context, '/Dashboard');
                    }
                  },
                  child: Text("Tutup")),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectboxText extends StatelessWidget {
  final String vale;
  SelectboxText(this.vale);

  @override
  Widget build(BuildContext context) {
    var splitVale = vale.split("-");
    var ghk = splitVale.length - 1;
    var result = ghk == 1 ? splitVale[1] : splitVale[1] + " " + splitVale[2];
    return Text("$result");
  }
}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const RaisedGradientButton({
    required this.child,
    required this.gradient,
    this.width = double.infinity,
    this.height = 20.0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 20.0,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            ),
          ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}

class PokjaList extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  final String mode;
  final String route;

  // ignore: prefer_const_constructors_in_immutables
  PokjaList(
      {required this.list,
      required this.mode,
      required this.route,
      required this.scrollController});
  LocalStorage storageUser = LocalStorage('terra_app');

  Future delPokja(String idPokja, String midUser) async {
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': midUser,
      'id_pokja': idPokja,
      'target': 'user_korwil',
      'type_submit': 'removePokja'
    });
    var status = jsonDecode(response.body);
    log('$status');
    return status;
  }

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            double total_luas = list[i]['total_luas'] == null
                ? 0
                : double.parse(list[i]['total_luas'].toString());
            double total_harga = list[i]['total_harga'] == null
                ? 0
                : double.parse(list[i]['total_harga'].toString());
            return GestureDetector(
              onTap: () {
                if (mode == 'pilih') {
                  if (route == 'order') {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CustomerList(
                          idPokja: list[i]['id'], route: route, mode: mode),
                    ));
                  } else if (route == 'transaksi') {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CustomerList(
                          idPokja: list[i]['id'], route: route, mode: mode),
                    ));
                  } else {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => FormCustomer(
                              idPokja: list[i]['id'],
                            )));
                  }
                } else {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200,
                        color: Colors.white70,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Apa yang akan anda lakukan pada ' +
                                  list[i]['nama'] +
                                  "?"),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ElevatedButton(
                                    //     child: Row(
                                    //       // ignore: prefer_const_literals_to_create_immutables
                                    //       children: [
                                    //         Icon(
                                    //           Icons.library_add_check,
                                    //           size: 14,
                                    //         ),
                                    //         Text(' Jadwalkan'),
                                    //       ],
                                    //     ),
                                    //     onPressed: () {
                                    //       Navigator.pop(context);
                                    //       Navigator.of(context)
                                    //           .push(MaterialPageRoute(
                                    //         builder: (BuildContext context) =>
                                    //             FormOrder(
                                    //                 idCustomer: list[i]['id'],
                                    //                 idPokja: list[i]
                                    //                     ['id_pokja'],
                                    //                 nama: list[i]['nama'],
                                    //                 nohp: list[i]['nohp']),
                                    //       ));
                                    //     }),
                                    Expanded(
                                      child: ElevatedButton(
                                          child: Row(
                                            // ignore: prefer_const_literals_to_create_immutables
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 14,
                                              ),
                                              Text(' Perbarui'),
                                            ],
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  PokjaEdit(
                                                idPokja: list[i]['id'],
                                                nama: list[i]['nama'],
                                                nohp: list[i]['nohp'],
                                                alamat: list[i]['alamat'],
                                                email: list[i]['email'],
                                                foto: list[i]['foto'],
                                              ),
                                            ));
                                          }),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: ElevatedButton(
                                          child: Row(
                                            // ignore: prefer_const_literals_to_create_immutables
                                            children: [
                                              const Icon(
                                                Icons.delete,
                                                size: 14,
                                              ),
                                              Text('Hapus'),
                                            ],
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return DialogYesNo(
                                                    vartitle:
                                                        'Menghapus pokja?',
                                                    varcontent:
                                                        'Anda yakin akan menghapus ${list[i]['nama']}',
                                                    textYes: 'Ya',
                                                    funYes: () {
                                                      delPokja(
                                                              list[i]['id'],
                                                              list[i]
                                                                  ['miduser'])
                                                          .then((value) => Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/Dashboard'));
                                                    },
                                                    textNo: 'Tidak',
                                                    funNo: () => Navigator.pop(
                                                        context, false),
                                                  );
                                                });
                                          }),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            // width: 200,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/no_user.png",
                                  height: 30,
                                  width: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  list[i]['nama'],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                        IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.green,
                              size: 18,
                            ))
                      ],
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Table(
                        children: [
                          const TableRow(children: [
                            TableCell(
                                child: Text('No.Hp',
                                    style: TextStyle(fontSize: 10))),
                            TableCell(
                                child: Text('Alamat',
                                    style: TextStyle(fontSize: 10)))
                          ]),
                          TableRow(children: [
                            TableCell(
                                child: Text(list[i]['nohp'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            TableCell(
                                child: Text(list[i]['alamat'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)))
                          ]),
                          const TableRow(children: [
                            TableCell(
                                child: Text('Klasifikasi',
                                    style: TextStyle(fontSize: 10))),
                            TableCell(
                                child: Text('Transaksi',
                                    style: TextStyle(fontSize: 10)))
                          ]),
                          TableRow(children: [
                            TableCell(
                                child: Text('Kelompok Kerja / Operator',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            TableCell(
                                child: Text(list[i]['qty_transaksi'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)))
                          ]),
                          const TableRow(children: [
                            TableCell(
                                child: Text('Total Nominal (Rp)',
                                    style: TextStyle(fontSize: 10))),
                            TableCell(
                                child: Text('Total Luas',
                                    style: TextStyle(fontSize: 10)))
                          ]),
                          TableRow(children: [
                            TableCell(
                                child: Text(formatter.format(total_harga),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            TableCell(
                                child: Text(formatter.format(total_luas) + " m2",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)))
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: theme == 'light'
                      ? Color(0XFFFFFFFF)
                      : Colors.grey.shade700,
                  border: Border.all(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),
    );
  }
}

class OrderList extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  OrderList({Key? key, required this.scrollController, required this.list})
      : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            var harga =
                formatter.format(double.parse(list[i]['estimasi_harga']));
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      OrderDetail(list: jsonEncode(list[i]).toString()),
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme == 'light'
                      ? Color(0XFFFFFFFF)
                      : Colors.grey.shade700,
                  border: Border.all(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                list[i]['no_order'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              )),
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                list[i]['tanggal'],
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          // width: 200,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            list[i]['nama_pokja'] +
                                '/' +
                                list[i]['nama_customer'],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16,
                            ),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          // width: 200,
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.pin_drop,
                                size: 12,
                              ),
                              Text(list[i]['alamat'],
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.crop_square,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(list[i]['nama_kendaraan'],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.left),
                                ],
                              )),
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.dns,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(list[i]['nama_paket'],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.left),
                                ],
                              )),
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Rp ' + harga.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.left),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class StickerNotif extends StatelessWidget {
  final String tipe;
  final String text;
  const StickerNotif({Key? key, required this.tipe, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
            child: Text(
          text,
          style: TextStyle(color: Colors.black),
        )),
        decoration: BoxDecoration(
            // color: Color(0XFFEF5350),
            color: tipe == 'danger'
                ? Color(0XFFFCDDD2)
                : tipe == 'warning'
                    ? Color(0XFFFFE0B2)
                    : Color(0XFFC8E6C9),
            border: Border.all(
                color: tipe == 'danger'
                    ? Colors.red.shade200
                    : tipe == 'warning'
                        ? Colors.orange.shade200
                        : Colors.greenAccent.shade200,
                width: 1),
            borderRadius: BorderRadius.all(Radius.circular(5))));
  }
}

class InputTextWhite extends StatelessWidget {
  LocalStorage storageUser = LocalStorage('terra_app');

  bool readonly;
  bool obscuring;
  final controller;
  final label;
  final TextInputType inputKeyboard;
  final onchanged;
  InputTextWhite(
      {this.obscuring = false,
      this.controller,
      this.label,
      this.onchanged,
      this.inputKeyboard = TextInputType.text,
      this.readonly = false});

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(width: 500, child: Text(label, textAlign: TextAlign.start)),
          Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color:
                  theme == 'light' ? Color(0XFFEEEEEE) : Colors.grey.shade700,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.only(left: 10),
            child: TextFormField(
              obscureText: obscuring,
              controller: controller,
              readOnly: readonly,
              onEditingComplete: onchanged,
              keyboardType: inputKeyboard,
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              validator: (String? value) {
                return (value != null && value == '')
                    ? 'Mohon lengkapi data tersebut'
                    : null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final actionlist;
  const CustomAppBar({Key? key, required this.label, this.actionlist})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: false,
        leadingWidth: 60,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).secondaryHeaderColor),
        ),
        title: Text(
          label,
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: actionlist);
  }

  @override
  Size get preferredSize => Size.fromHeight(65);
}

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch.adaptive(
        value: themeProvider.isDarkMode,
        onChanged: (val) {
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          print('switch $val');
          provider.toggleTheme(val);
        });
  }
}

class SkeletonOrderCard extends StatelessWidget {
  LocalStorage storageUser = LocalStorage('terra_app');
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme == 'light' ? Color(0XFFFFFFFF) : Colors.grey.shade700,
        border: Border.all(
          color: theme == 'light' ? Color(0XFFFFFFFF) : Colors.grey.shade700,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 150,
                  child: LinearProgressIndicator(
                    minHeight: 25,
                    backgroundColor: Colors.grey[350],
                    valueColor: AlwaysStoppedAnimation<Color>(theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700),
                  ),
                ),
                Container(
                  width: 100,
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    backgroundColor: Colors.grey[350],
                    valueColor: AlwaysStoppedAnimation<Color>(theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
                // width: 200,
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        backgroundColor: Colors.grey[350],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme == 'light'
                                ? Color(0XFFFFFFFF)
                                : Colors.grey.shade700),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 5,
            ),
            Container(
                // width: 200,
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      width: 200,
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        backgroundColor: Colors.grey[350],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme == 'light'
                                ? Color(0XFFFFFFFF)
                                : Colors.grey.shade700),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          child: LinearProgressIndicator(
                            minHeight: 20,
                            backgroundColor: Colors.grey[350],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme == 'light'
                                    ? Color(0XFFFFFFFF)
                                    : Colors.grey.shade700),
                          ),
                        ),
                      ],
                    )),
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          child: LinearProgressIndicator(
                            minHeight: 20,
                            backgroundColor: Colors.grey[350],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme == 'light'
                                    ? Color(0XFFFFFFFF)
                                    : Colors.grey.shade700),
                          ),
                        ),
                      ],
                    )),
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          child: LinearProgressIndicator(
                            minHeight: 20,
                            backgroundColor: Colors.grey[350],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme == 'light'
                                    ? Color(0XFFFFFFFF)
                                    : Colors.grey.shade700),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularIndicatorCard extends StatelessWidget {
  CircularIndicatorCard({Key? key}) : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme == 'light' ? Color(0XFFFFFFFF) : Colors.grey.shade700,
        border: Border.all(
          color: theme == 'light' ? Color(0XFFFFFFFF) : Colors.grey.shade700,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 150,
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey[350],
          valueColor: AlwaysStoppedAnimation<Color>(
              theme == 'light' ? Color(0XFFFFFFFF) : Colors.grey.shade700),
        ),
      ),
    );
  }
}

class PlottingCard extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  final String mode;
  final String route;
  // final String mode;
  PlottingCard({
    Key? key,
    // required this.mode,
    required this.scrollController,
    required this.list,
    required this.mode,
    required this.route,
  }) : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            return GestureDetector(
              onTap: () {
                if (route == 'order') {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        OrderFromPlot(list: jsonEncode(list[i]).toString()),
                  ));
                } else {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        TransFromPlot(list: jsonEncode(list[i]).toString()),
                  ));
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme == 'light'
                      ? Color(0XFFFFFFFF)
                      : Colors.grey.shade700,
                  border: Border.all(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                list[i]['nama'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              )),
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                list[i]['waktu_save'],
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          // width: 200,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            list[i]['nama_pokja'],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16,
                            ),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          // width: 200,
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.pin_drop,
                                size: 12,
                              ),
                              Flexible(
                                child: Text(list[i]['alamat'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.left),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.crop_square,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(list[i]['luas_lahan'] + 'm2',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.left),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class OrderGrid extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  OrderGrid({Key? key, required this.scrollController, required this.list})
      : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          padding: EdgeInsets.zero,
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            double rh = double.parse(list[i]['range_hour'].toString());
            var harga =
                formatter.format(double.parse(list[i]['estimasi_harga']));
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      OrderDetail(list: jsonEncode(list[i]).toString()),
                ));
              },
              child: Stack(children: [
                Container(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          rh < 0
                              ? 'Akan Dikerjakan'
                              : rh < 24
                                  ? 'Dikerjakan'
                                  : 'Sudah Dikerjakan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 1,
                    height: 200,
                    decoration: BoxDecoration(
                        color: rh < 0
                            ? Colors.orange.shade300
                            : rh < 24
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ))),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              list[i]['no_order'],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            // width: 200,
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              list[i]['nama_pokja'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 16,
                              ),
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            // width: 200,
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Icon(Icons.pin_drop,
                                    size: 14, color: Colors.red.shade200),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(list[i]['alamat'],
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.left),
                              ],
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Icon(Icons.crop_square,
                                    size: 14, color: Colors.blue.shade200),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(list[i]['luas_lahan'] + " m2",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.left),
                              ],
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    size: 14, color: Colors.green.shade200),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Rp ' + harga.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.left),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ]),
            );
          }),
    );
  }
}

class TargetGrid extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  TargetGrid({Key? key, required this.scrollController, required this.list})
      : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  List months = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 15),
      height: MediaQuery.of(context).size.height * 0.25,
      child: ListView.builder(
          // gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //     maxCrossAxisExtent: 200,
          //     crossAxisSpacing: 20,
          //     mainAxisSpacing: 5),
          padding: EdgeInsets.zero,
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 12,
          itemBuilder: (BuildContext context, i) {
            double target_kerja =
                double.parse(list[i]['target_kerja'].toString());
            double total_luas = double.parse(list[i]['total_luas'].toString());
            double total_harga =
                double.parse(list[i]['total_harga'].toString());
            double total_biaya =
                double.parse(list[i]['total_biaya'].toString());
            double persentase =
                total_luas == 0 ? 0 : (total_luas / target_kerja) * 100;
            double bulan = double.parse(list[i]['bulan']) - 1;
            return Stack(children: [
              Container(
                  padding: EdgeInsets.only(
                    bottom: 3,
                  ),
                  margin: EdgeInsets.only(left: 15, right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        total_luas > target_kerja ? 'Selamat! ' : 'Semangat! ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  width: 220,
                  height: 150,
                  decoration: BoxDecoration(
                      color: total_luas > target_kerja
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ))),
              Container(
                width: 220,
                height: 130,
                margin: EdgeInsets.only(left: 15, right: 5),
                decoration: BoxDecoration(
                  color: theme == 'light'
                      ? Color(0XFFFFFFFF)
                      : Colors.grey.shade700,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                months[bulan.toInt()],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                persentase.toStringAsFixed(0) + '%',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: total_luas > target_kerja
                                        ? Colors.green.shade300
                                        : Colors.red.shade300,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          // width: 200,
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Icon(Icons.crop_square_rounded,
                                  size: 14, color: Colors.green),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                  formatter.format(total_luas) +
                                      ' / ' +
                                      formatter.format(target_kerja) +
                                      ' m2',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.left),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  size: 14, color: Colors.blue.shade200),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Rp ' + formatter.format(total_harga),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.left),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Icon(Icons.credit_card,
                                  size: 14, color: Colors.red.shade300),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Rp ' + formatter.format(total_biaya),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.left),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ]);
          }),
    );
  }
}

class TransaksiListCard extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  // final String mode;
  TransaksiListCard(
      {Key? key,
      // required this.mode,
      required this.scrollController,
      required this.list})
      : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            double rh = double.parse(list[i]['acc_mitra'].toString());
            var harga = formatter.format(double.parse(list[i]['harga']));
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      TransaksiDetail(list: jsonEncode(list[i]).toString()),
                ));
              },
              child: Stack(children: [
                Container(
                    padding: EdgeInsets.only(bottom: 3),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          rh == 0 ? 'Belum Konfirmasi' : 'Valid',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 1,
                    height: 200,
                    decoration: BoxDecoration(
                        color: rh == 0
                            ? Colors.orange.shade300
                            : Colors.green.shade300,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ))),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 200,
                                  child: Text(
                                    list[i]['id_invoice'],
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  child: Text(
                                    list[i]['nama_pokja'],
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.green,
                                  size: 18,
                                ))
                          ],
                        ),
                        Divider(),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Table(
                            children: [
                              const TableRow(children: [
                                TableCell(
                                    child: Text('Nama Lahan',
                                        style: TextStyle(fontSize: 10))),
                                TableCell(
                                    child: Text('Luas',
                                        style: TextStyle(fontSize: 10)))
                              ]),
                              TableRow(children: [
                                TableCell(
                                    child: Text(
                                        list[i]['nama_lahan'] ?? 'tanpa nama',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600))),
                                TableCell(
                                    child: Text(list[i]['luas_kerja'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)))
                              ]),
                              const TableRow(children: [
                                TableCell(
                                    child: Text('Nama Paket',
                                        style: TextStyle(fontSize: 10))),
                                TableCell(
                                    child: Text('Total Harga',
                                        style: TextStyle(fontSize: 10)))
                              ]),
                              TableRow(children: [
                                TableCell(
                                    child: Text(list[i]['nama_paket'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600))),
                                TableCell(
                                    child: Text(harga.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)))
                              ]),
                              const TableRow(children: [
                                TableCell(
                                    child: Text('Waktu Mulai',
                                        style: TextStyle(fontSize: 10))),
                                TableCell(
                                    child: Text('Waktu Selesai',
                                        style: TextStyle(fontSize: 10)))
                              ]),
                              TableRow(children: [
                                TableCell(
                                    child: Text(list[i]['waktu_mulai'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600))),
                                TableCell(
                                    child: Text(list[i]['waktu_selesai'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)))
                              ])
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            );
          }),
    );
  }
}

class BiayaList extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  BiayaList({Key? key, required this.scrollController, required this.list})
      : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            return Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(bottom: 5, top: 20),
                    width: 500,
                    child: Text(list[i]['nama_biaya'],
                        textAlign: TextAlign.start)),
                Container(
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
                        child: Text(list[i]['nominal'])),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final String idPokja;
  final ScrollController scrollController;
  final List list;
  final String mode;
  final String route;

  // ignore: prefer_const_constructors_in_immutables
  CustomerCard(
      {required this.idPokja,
      required this.list,
      required this.mode,
      required this.route,
      required this.scrollController});
  LocalStorage storageUser = LocalStorage('terra_app');

  Future delCustomer(String idPokja, String midUser) async {
    final http.Response response = await http.post(apiURI, body: {
      'id_korwil': midUser,
      'id_pokja': idPokja,
      'target': 'user_korwil',
      'type_submit': 'removeCustomer'
    });
    var status = jsonDecode(response.body);
    log('$status');
    return status;
  }

  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            double total_luas = list[i]['total_luas'] == null
                ? 0
                : double.parse(list[i]['total_luas'].toString());
            double total_harga = list[i]['total_harga'] == null
                ? 0
                : double.parse(list[i]['total_harga'].toString());
            return GestureDetector(
              onTap: () {
                if (mode == 'pilih') {
                  if (route == 'order') {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => FormOrder(
                          idCustomer: list[i]['id'],
                          idPokja: idPokja,
                          nama: list[i]['nama'],
                          nohp: list[i]['nohp']),
                    ));
                  } else if (route == 'transaksi') {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => TransManual(
                          idPokja: idPokja,
                          idCustomer: list[i]['id'],
                          nama: list[i]['nama'],
                          nohp: list[i]['nohp']),
                    ));
                  } else {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => FormCustomer(
                              idPokja: list[i]['id'],
                            )));
                  }
                } else {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200,
                        color: Colors.white70,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Apa yang akan anda lakukan pada ' +
                                  list[i]['nama'] +
                                  "?"),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ElevatedButton(
                                    //     child: Row(
                                    //       // ignore: prefer_const_literals_to_create_immutables
                                    //       children: [
                                    //         Icon(
                                    //           Icons.library_add_check,
                                    //           size: 14,
                                    //         ),
                                    //         Text(' Jadwalkan'),
                                    //       ],
                                    //     ),
                                    //     onPressed: () {
                                    //       Navigator.pop(context);
                                    //       Navigator.of(context)
                                    //           .push(MaterialPageRoute(
                                    //         builder: (BuildContext context) =>
                                    //             FormOrder(
                                    //                 idCustomer: list[i]['id'],
                                    //                 idPokja: list[i]
                                    //                     ['id_pokja'],
                                    //                 nama: list[i]['nama'],
                                    //                 nohp: list[i]['nohp']),
                                    //       ));
                                    //     }),
                                    Expanded(
                                      child: ElevatedButton(
                                          child: Row(
                                            // ignore: prefer_const_literals_to_create_immutables
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 14,
                                              ),
                                              Text(' Perbarui'),
                                            ],
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  PokjaEdit(
                                                idPokja: list[i]['id'],
                                                nama: list[i]['nama'],
                                                nohp: list[i]['nohp'],
                                                alamat: list[i]['alamat'],
                                                email: list[i]['email'],
                                                foto: list[i]['foto'],
                                              ),
                                            ));
                                          }),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: ElevatedButton(
                                          child: Row(
                                            // ignore: prefer_const_literals_to_create_immutables
                                            children: [
                                              const Icon(
                                                Icons.delete,
                                                size: 14,
                                              ),
                                              Text('Hapus'),
                                            ],
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return DialogYesNo(
                                                    vartitle:
                                                        'Menghapus pokja?',
                                                    varcontent:
                                                        'Anda yakin akan menghapus ${list[i]['nama']}',
                                                    textYes: 'Ya',
                                                    funYes: () {
                                                      delCustomer(
                                                              list[i]['id'],
                                                              list[i]
                                                                  ['miduser'])
                                                          .then((value) => Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/Dashboard'));
                                                    },
                                                    textNo: 'Tidak',
                                                    funNo: () => Navigator.pop(
                                                        context, false),
                                                  );
                                                });
                                          }),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                              // width: 200,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/no_user.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    list[i]['nama'],
                                    overflow: TextOverflow.clip,
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        ),
                        IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.green,
                              size: 18,
                            ))
                      ],
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Table(
                        children: [
                          const TableRow(children: [
                            TableCell(
                                child: Text('No.Hp',
                                    style: TextStyle(fontSize: 10))),
                            TableCell(
                                child: Text('Alamat',
                                    style: TextStyle(fontSize: 10)))
                          ]),
                          TableRow(children: [
                            TableCell(
                                child: Text(list[i]['nohp'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            TableCell(
                                child: Text(list[i]['alamat'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)))
                          ]),
                          const TableRow(children: [
                            TableCell(
                                child: Text('Klasifikasi',
                                    style: TextStyle(fontSize: 10))),
                            TableCell(
                                child: Text('Transaksi',
                                    style: TextStyle(fontSize: 10)))
                          ]),
                          TableRow(children: [
                            TableCell(
                                child: Text(list[i]['klasifikasi'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            TableCell(
                                child: Text(list[i]['qty_transaksi'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)))
                          ]),
                          const TableRow(children: [
                            TableCell(
                                child: Text('Total Nominal (Rp)',
                                    style: TextStyle(fontSize: 10))),
                            TableCell(
                                child: Text('Total Luas',
                                    style: TextStyle(fontSize: 10)))
                          ]),
                          TableRow(children: [
                            TableCell(
                                child: Text(
                                   formatter.format(total_harga),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            TableCell(
                                child: Text(
                                    formatter.format(total_luas) + " m2",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)))
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: theme == 'light'
                      ? Color(0XFFFFFFFF)
                      : Colors.grey.shade700,
                  border: Border.all(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),
    );
  }
}

class MachineCard extends StatelessWidget {
  final ScrollController controller;
  final List list;
  LocalStorage storageUser = LocalStorage('terra_app');
  MachineCard({required this.list, required this.controller});
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];
    return Container(
      margin: const EdgeInsets.only(top: 0),
      height: MediaQuery.of(context).size.height * 0.12,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        controller: controller,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: list == null ? 0 : list.length,
        itemBuilder: (BuildContext context, i) {
          print("$i");
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MachineRealtime(
                          list: jsonEncode(list[i]).toString(),
                        )));
              },
              child: ClipPath(
                clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    // border: Border(
                    //     right: BorderSide(
                    //         width: 8,
                    //         color: Colors.red)), //THIS COLOR ON OF
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    // leading: Container(
                    //   padding: EdgeInsets.only(right: 12.0),
                    //   decoration: const BoxDecoration(
                    //       border: Border(
                    //           right: BorderSide(
                    //               width: 1.0, color: Colors.white))),
                    //   child: list[i]['jenis_kendaraan'] == 'Traktor'
                    //       ? Image.asset(
                    //           'assets/tractor_default.png',
                    //           scale: 1,
                    //         )
                    //       : list[i]['nama_jenis'] == 'Harvester'
                    //           ? Image.asset(
                    //               'assets/combine_default.png',
                    //               scale: 1,
                    //             )
                    //           : Image.asset(
                    //               'assets/combine_default.png',
                    //               scale: 1,
                    //             ),
                    // ),
                    title: Text(
                      "${list[i]['nama_kendaraan']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                    subtitle: Row(
                      children: <Widget>[
                        // Icon(Icons.linear_scale, color: Colors.yellowAccent),
                        Text("${list[i]['jenis_kendaraan']}",
                            style: TextStyle(fontSize: 11)),
                        Text("-"),
                        Text("${list[i]['tipe_kendaraan']}",
                            style: TextStyle(fontSize: 11))
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_right,
                        size: 30,
                      ),
                      onPressed: null,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BiayaCard extends StatelessWidget {
  final ScrollController scrollController;
  final List list;
  BiayaCard({Key? key, required this.list, required this.scrollController})
      : super(key: key);
  LocalStorage storageUser = LocalStorage('terra_app');
  @override
  Widget build(BuildContext context) {
    var theme = storageUser.getItem('theme_config')['value'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (BuildContext context, i) {
            var nominal = formatter.format(double.parse(list[i]['nominal']));
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      CostDailyDetail(list: jsonEncode(list[i]).toString()),
                ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme == 'light'
                      ? Color(0XFFFFFFFF)
                      : Colors.grey.shade700,
                  border: Border.all(
                    color: theme == 'light'
                        ? Color(0XFFFFFFFF)
                        : Colors.grey.shade700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                list[i]['nama_biaya'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              )),
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                list[i]['tanggal'],
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 18,
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          // width: 200,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Rp " + nominal.toString(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16,
                            ),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
