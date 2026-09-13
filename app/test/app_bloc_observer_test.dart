import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keeper/app_bloc_observer.dart';
import 'package:mocktail/mocktail.dart';

class _MockBloc extends Mock implements BlocBase<int>;

void main() {
  group(AppBlocObserver, () {
    late BlocBase<int> bloc;
    late AppBlocObserver observer;

    setUp(() {
      bloc = _MockBloc();
      observer = const AppBlocObserver();
    });

    test('logs a change without throwing', () {
      expect(
        () => observer.onChange(
          bloc,
          const Change<int>(currentState: 0, nextState: 1),
        ),
        returnsNormally,
      );
    });

    test('logs an error without throwing', () {
      expect(
        () => observer.onError(bloc, Exception('boom'), StackTrace.empty),
        returnsNormally,
      );
    });
  });
}
