import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/app.dart';

void main() {
  setPathUrlStrategy();
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ERROR => $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };
  runApp(ProviderScope(child: MyApp()));
}
