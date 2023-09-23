import 'package:first_priority_app/notifiers/theme_notifier.dart';
import 'package:first_priority_app/widgets/dialogs/select_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            _themeSettingTile(),
          ],
        ).toList(),
      ),
    );
  }

  static const _themes = {
    "light": "Light",
    "dark": "Dark",
  };

  Widget _themeSettingTile() {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) {
        return ListTile(
          leading: Icon(Icons.palette),
          title: Text("Theme"),
          subtitle: Text(_themes[theme.key]),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SelectDialog(
                  title: "Pick Theme",
                  itemCount: _themes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_themes[_themes.keys.toList()[index]]),
                      onTap: () {
                        theme.setTheme(_themes.keys.toList()[index]);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
