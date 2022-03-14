import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_korwil/pages/cost_daily.dart';
import 'package:terra_korwil/pages/cost_daily_insert.dart';
import 'package:terra_korwil/pages/dashboard.dart';
import 'package:terra_korwil/pages/order_list.dart';
import 'package:terra_korwil/pages/pokja_insert.dart';
import 'package:terra_korwil/pages/pokja_list.dart';
import 'package:terra_korwil/pages/login.dart';
import 'package:terra_korwil/pages/splash.dart';
import 'package:terra_korwil/pages/trans_manual.dart';
import 'package:terra_korwil/pages/transaksi_list.dart';
import 'package:terra_korwil/theme/pallete.dart';
// USE FONT POPPINS
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            '/Login': (BuildContext context) => Login(),
            '/Dashboard': (BuildContext context) => const Dashboard(),
            '/FormPokja': (BuildContext context) => const FormPokja(),
            '/ListOrder': (BuildContext context) => const ListOrder(),
            '/ListTransaksi' : (BuildContext context) => const TransaksiList(),
            '/CostDaily' : (BuildContext context) => const CostDaily(),
            '/CostDailyInsert': (BuildContext context) => const CostDailyInsert(),
          },
          title: 'Terra Kordinator Wilayah',
          themeMode: themeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: SplashPage(),
        );
      });
}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}