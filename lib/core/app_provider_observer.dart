import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
PROVIDER UPDATED
${provider.name ?? provider.runtimeType}

NEW VALUE:
$newValue
''');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint('''
PROVIDER FAILED
${provider.name ?? provider.runtimeType}

ERROR:
$error
''');

    debugPrintStack(stackTrace: stackTrace);
  }
}
