import 'dart:developer';

import 'package:bloc/bloc.dart';

/// Logs every state change and error from every Bloc and Cubit in the app.
///
/// Installed once in `bootstrap.dart`. Lives in its own file so the coverage
/// gate measures it; `bootstrap.dart` itself holds only the `runApp` wiring.
class AppBlocObserver extends BlocObserver {
  const new();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
