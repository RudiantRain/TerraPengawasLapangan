import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:localstorage/localstorage.dart';

class ThemeProvider extends ChangeNotifier {
  // final LocalStorage storageUser = LocalStorage('terra_app');
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;
  void toggleTheme(bool isOn) async {
    // if(storageUser.getItem('theme_config') == null){
    //   storageUser.setItem('theme_config', {'value' : 'light'});
    // }else{
    //   if(storageUser.getItem('theme_config')['value'] == 'light'){
    //   }else{
    //     storageUser.deleteItem('theme_config').then((val){
    //       storageUser.setItem('theme_config', {'value' : 'dark'});
    //       var aja = storageUser.getItem('theme_config');
    //       print('$aja');
    //     });
    //   }
    // }
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Colors.grey.shade800,
    colorScheme: const ColorScheme.dark(
      primary: Colors.green,
      primaryVariant: Colors.green,
      secondary: Colors.green,
      secondaryVariant: Colors.green,
    ),
    primaryColor: Colors.grey.shade800,
    secondaryHeaderColor: Colors.white,
    focusColor: Colors.green,
    primarySwatch: Colors.green,
  );

  static final lightTheme = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Color(0XFFF3F3F3),
    colorScheme: const ColorScheme.light(
      primary: Colors.green,
      primaryVariant: Colors.green,
      secondary: Colors.green,
      secondaryVariant: Colors.green,
    ),
    primaryColor: Color(0XFFF3F3F3),
    secondaryHeaderColor: Colors.grey.shade800,
    focusColor: Colors.green,
    primarySwatch: Colors.green,
  );
}
