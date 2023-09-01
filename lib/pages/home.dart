import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tteewwkkrr/widget/card.dart';

import '../provider/theme.dart';
import '../widget/card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          height:MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '我想要...',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              CustomCard(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('搜尋課程評論'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          Navigator.pushNamed(context, '/comment');
                        },
                      ),
                    ),
                    const ListTile(
                      title: Text('搜尋加簽資訊'),
                      subtitle: Text('開發中'),
                      enabled: false,
                      trailing: IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
