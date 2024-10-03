import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'diary/diary_add.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'diary/diary_list_screen.dart'; // 일기 목록 화면
import 'diary/diary_detail_screen.dart'; // 일기 작성/수정 화면
import 'diary/diary_model.dart'; // 프로젝트 경로에 맞게 수정

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: DiaryListScreen.routeName,

          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  // 기존 설정 화면
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);

                  // 기존 샘플 화면
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case SampleItemListView.routeName:
                    return const SampleItemListView();

                  case AddDiaryScreen.routeName:
                    return const AddDiaryScreen();
                  // 새로운 일기 화면 추가
                  case DiaryListScreen.routeName:  // 일기 목록 화면
                    return const DiaryListScreen();
                  case DiaryDetailScreen.routeName: // 일기 작성/수정 화면
                    final entry = routeSettings.arguments as DiaryEntry;
                    return DiaryDetailScreen(entry: entry);

                  // 기본적으로 일기 목록 화면을 첫 화면으로 설정
                  default:
                    return const DiaryListScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
