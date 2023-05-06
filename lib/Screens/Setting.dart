import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool? dark;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDark();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Settings"),
            backgroundColor: Colors.green,
          ),
          body: FutureBuilder(
            future: getDark(),
            builder: (context, snapshot) => SettingsList(sections: [
              SettingsSection(
                  title: Text(
                    "Appearance",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      initialValue: dark ?? false,
                      leading: Icon(Icons.dark_mode_outlined),
                      title: Text("Dark theme"),
                      onToggle: (value) async {
                        var prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('dark', value);
                        print(dark);
                        setState(() {
                          value
                              ? AdaptiveTheme.of(context).setDark()
                              : AdaptiveTheme.of(context).setLight();
                          dark = value;
                        });
                      },
                    ),
                    SettingsTile(
                      leading: Icon(Icons.display_settings),
                      title: Text('Display'),
                    ),
                  ]),
              SettingsSection(
                  title: Text(
                    "Privacy",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile(
                      leading: Icon(Icons.privacy_tip_outlined),
                      title: Text("Permissions"),
                    ),
                    SettingsTile(
                      leading: Icon(Icons.security_outlined),
                      title: Text('Security'),
                    ),
                  ]),
              SettingsSection(
                  title: Text(
                    "Accounts",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile(
                      leading: Icon(Icons.supervised_user_circle_outlined),
                      title: Text("Multiple Users"),
                    ),
                    SettingsTile(
                      leading: Icon(Icons.feedback_outlined),
                      title: Text('Feedback'),
                    ),
                  ]),
            ]),
          )),
    );
  }

  Future<void> getDark() async {
    var prefs = await SharedPreferences.getInstance();
    dark = prefs.getBool('dark');
    print(dark);
  }
}