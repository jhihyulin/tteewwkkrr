import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import '../pages/home.dart';
import '../pages/load_failed.dart';
import '../pages/not_found.dart' deferred as not_found;
import '../pages/comment.dart' deferred as comment;
import '../pages/signable.dart' deferred as signable;
import '../pages/loading.dart';
import '../provider/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget Function(BuildContext) loadPage(
      Future<void> Function() loadLibrary, Widget Function(BuildContext) page) {
    return (BuildContext context) => FutureBuilder(
          future: loadLibrary(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return LoadFailedPage(errorMessage: snapshot.error.toString());
              } else {
                return page(context);
              }
            } else {
              return const LoadingPage();
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          Color themeColor = themeProvider.themeColor;
          int themeMode = themeProvider.themeMode;
          return MaterialApp(
            title: 'tteewwkkrr',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: '',
              fontFamilyFallback: const [],
              brightness: Brightness.light,
              colorSchemeSeed: themeColor,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: '',
              fontFamilyFallback: const [],
              brightness: Brightness.dark,
              colorSchemeSeed: themeColor,
            ),
            themeMode: themeMode == 0
                ? ThemeMode.system
                : themeMode == 1
                    ? ThemeMode.light
                    : ThemeMode.dark,
            onGenerateRoute: (RouteSettings settings) {
              String? name = settings.name;
              WidgetBuilder? builder;
              Map<String, String>? parameters;
              // analyze parameters
              if (name!.contains(RegExp(r'.*[?].*[=].*'))) {
                name.split(RegExp(r'[?&]')).forEach((String parameter) {
                  if (RegExp(r'.*[=].*').allMatches(parameter).isNotEmpty) {
                    List<String> parameterList = parameter.split('=');
                    parameters = {
                      ...parameters ?? {},
                      // ignore parameter case
                      parameterList[0].toLowerCase(): parameterList[1]
                    };
                  }
                });
              }
              // ignore all query parameters
              name = name.replaceAll(RegExp(r'[?].*'), '');
              // ignore URL case
              name = name.toLowerCase();
              if (kDebugMode) {
                print('Route Name: $name, Parameters: $parameters');
              }
              switch (name) {
                case '/comment':
                  builder = loadPage(comment.loadLibrary, (context) {
                    return comment.CommentPage();
                  });
                  break;
                case '/signable':
                  builder = loadPage(signable.loadLibrary, (context) {
                    return signable.SignablePage();
                  });
                  break;
                case '/':
                  builder = (context) {
                    return const HomePage();
                  };
                default:
                  builder = loadPage(not_found.loadLibrary, (context) {
                    return not_found.NotFoundPage();
                  });
              }
              return MaterialPageRoute(
                builder: builder,
                settings: settings,
              );
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
