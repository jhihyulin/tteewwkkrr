import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tteewwkkrr/widget/scaffold_messenger.dart';

import '../provider/theme.dart';
import '../widget/card.dart';
import '../widget/launch_url.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tteewwkkrr'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Provider.of<ThemeProvider>(context, listen: true).themeMode ==
                    0
                ? const Icon(Icons.brightness_auto)
                : Provider.of<ThemeProvider>(context, listen: true).themeMode ==
                        1
                    ? const Icon(Icons.light_mode)
                    : const Icon(Icons.dark_mode),
            tooltip:
                Provider.of<ThemeProvider>(context, listen: true).themeMode == 0
                    ? '跟随系统'
                    : Provider.of<ThemeProvider>(context, listen: true)
                                .themeMode ==
                            1
                        ? '淺色'
                        : '深色',
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).setThemeMode(
                Provider.of<ThemeProvider>(context, listen: false).themeMode ==
                        0
                    ? 1
                    : Provider.of<ThemeProvider>(context, listen: false)
                                .themeMode ==
                            1
                        ? 2
                        : 0,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '我想要...',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    CustomCard(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            title: const Text('搜尋課程評論'),
                            onTap: () {
                              Navigator.pushNamed(context, '/comment');
                            },
                            trailing: const Icon(Icons.chevron_right),
                          ),
                          ListTile(
                            title: const Text('搜尋加簽資訊'),
                            onTap: () {
                              Navigator.pushNamed(context, '/signable');
                            },
                            trailing: const Icon(Icons.chevron_right),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (BuildContext context,
                            AsyncSnapshot<PackageInfo> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                                'v${snapshot.data!.version}${snapshot.data?.buildNumber == '' ? '' : '+${snapshot.data!.buildNumber}'}');
                          } else {
                            return const Text('Loading...');
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: IconButton(
                      icon: const Icon(FontAwesome.github),
                      onPressed: () {
                        CustomLaunchUrl.launch(
                            context, 'https://github.com/jhihyulin/tteewwkkrr');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
