import 'package:terra_korwil/theme/pallete.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  final LocalStorage storageUser = LocalStorage('terra_app');
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch.adaptive(
        value: themeProvider.isDarkMode,
        activeColor: Colors.green,
        activeTrackColor: Colors.green.shade700,
        activeThumbImage: const AssetImage('assets/dark.png'),
        inactiveThumbImage: const AssetImage('assets/light.png'),
        onChanged: (val) {
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          provider.toggleTheme(val);
          setState(() {
            if (storageUser.getItem('theme_config')['value'] == 'light') {
              storageUser.setItem('theme_config', {'value': 'dark'});
            } else {
              storageUser.setItem('theme_config', {'value': 'light'});
            }
          });
        });
  }
}

class ThemeSwitcherButton extends StatefulWidget {
  const ThemeSwitcherButton({Key? key}) : super(key: key);

  @override
  _ThemeSwitcherButtonState createState() => _ThemeSwitcherButtonState();
}

class _ThemeSwitcherButtonState extends State<ThemeSwitcherButton> {
  final LocalStorage storageUser = LocalStorage('terra_app');

  @override
  void initState() {
    super.initState();
    setThemeValue();
  }

  Icon iconmode = const Icon(Icons.light_mode);
  void setThemeValue() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    await storageUser.ready.then((value) {
      if (storageUser.getItem('theme_config') == null) {
        storageUser.setItem('theme_config', {'value': 'light'});
        provider.toggleTheme(false);
        setState(() {
          iconmode = const Icon(Icons.light_mode);
        });
      } else {
        if (storageUser.getItem('theme_config')['value'] == 'light') {
          provider.toggleTheme(false);
          setState(() {
            iconmode = const Icon(Icons.light_mode);
          });
        } else {
          provider.toggleTheme(true);
          setState(() {
            iconmode = const Icon(Icons.nightlight);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){ setThemeValue();},
      icon: iconmode,
    );
  }
}
