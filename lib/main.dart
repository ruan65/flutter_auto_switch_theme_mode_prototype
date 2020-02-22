import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const lorem =
    'Mauris efficitur eros non urna tristique dapibus. Cras at nunc sem. Cras maximus libero pellentesque augue scelerisque, a suscipit risus blandit.';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var _prefs = await SharedPreferences.getInstance();
  var _index = _prefs.getInt(AutoDarkMode.THEME_MODE_KEY);
  var _themeMode = ThemeMode.values[_index ?? 0];

  runApp(MyApp(_themeMode));
}

typedef AutoMode = Widget Function(BuildContext context, ThemeMode themeMode);

class AutoDarkMode extends StatefulWidget {
  static const THEME_MODE_KEY = 'theme_mode';
  final AutoMode builder;
  final ThemeMode themeMode;

  AutoDarkMode({@required this.builder, @required this.themeMode});

  @override
  _AutoDarkModeState createState() => _AutoDarkModeState();

  static _AutoDarkModeState of(BuildContext context) {
    return context.findAncestorStateOfType();
  }
}

class _AutoDarkModeState extends State<AutoDarkMode> {
  ThemeMode _themeMode;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    Future.delayed(Duration.zero).then((_) async {
      _prefs = await SharedPreferences.getInstance();
    });
  }

  set themeMode(ThemeMode value) {
    if (mounted) _prefs.setInt(AutoDarkMode.THEME_MODE_KEY, value.index);
    setState(() => _themeMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _themeMode);
  }
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  MyApp(this.themeMode);

  @override
  Widget build(BuildContext context) {
    return AutoDarkMode(
        themeMode: themeMode,
        builder: (context, themeMode) {
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            title: 'Auto Light Dark mode',
            builder: (BuildContext context, Widget child) {
              return Builder(builder: (BuildContext context) {
                return CupertinoTheme(
                  data: CupertinoThemeData(
                      brightness: Theme.of(context).brightness,
                      scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
                        color: CupertinoColors.lightBackgroundGray,
                        darkColor: CupertinoColors.black,
                      )),
                  child: child,
                );
              });
            },
            initialRoute: '/android',
            routes: {
              '/android': (ctx) => FirstScreen(),
              '/ios': (ctx) => SecondScreen(),
            },
          );
        });
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Android'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ios');
                },
                child: Text('iOS screen'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Material text field')),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(lorem),
              ),
              RaisedButton(
                onPressed: () => AutoDarkMode.of(context).themeMode = ThemeMode.light,
                child: Text('Light theme'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () => AutoDarkMode.of(context).themeMode = ThemeMode.dark,
                  child: Text('Dark theme'),
                ),
              ),
              RaisedButton(
                onPressed: () => AutoDarkMode.of(context).themeMode = ThemeMode.system,
                child: Text('System theme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: CupertinoTheme.of(context).textTheme.textStyle,
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Cupertino'),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      decoration: BoxDecoration(color: CupertinoColors.systemGrey6),
                      minLines: 4,
                      maxLines: 10,
                      placeholder: 'Cupertino text field',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(lorem),
                  ),
                  CupertinoButton.filled(
                      child: Text('Light theme'),
                      onPressed: () {
                        AutoDarkMode.of(context).themeMode = ThemeMode.light;
                      }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoButton.filled(
                        child: Text('Dark theme'),
                        onPressed: () {
                          AutoDarkMode.of(context).themeMode = ThemeMode.dark;
                        }),
                  ),
                  CupertinoButton.filled(
                      child: Text('System theme'),
                      onPressed: () {
                        AutoDarkMode.of(context).themeMode = ThemeMode.system;
                      }),
                ],
              ),
            )),
          )),
    );
  }
}