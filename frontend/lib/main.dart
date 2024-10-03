import 'package:flutter/material.dart';

import 'src/app.dart'; // 수정된 MyApp 포함
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // 설정 컨트롤러 초기화
  final settingsController = SettingsController(SettingsService());

  // 사용자 설정을 불러옴 (예: 테마)
  await settingsController.loadSettings();

  // 앱 실행, 설정 컨트롤러 전달
  runApp(MyApp(settingsController: settingsController));
}
