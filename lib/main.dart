import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/app.dart';
import 'core/app_provider_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ERROR => $error');

    debugPrintStack(stackTrace: stack);

    return true;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint(
      'FLUTTER ERROR => '
      '${details.exception}',
    );

    debugPrintStack(stackTrace: details.stack);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Text('''
${details.exception}

${details.stack}
'''),
      ),
    );
  };

  runApp(ProviderScope(observers: [AppProviderObserver()], child: MyApp()));
}
