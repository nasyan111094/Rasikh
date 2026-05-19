import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger(
    level: Level.debug,
  );
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.i('${bloc.runtimeType} created');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    /*_logger.f('${bloc.runtimeType} $change');*/
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    /*  _logger.d('transition ${bloc.runtimeType} ${transition.currentState} -> ${transition.nextState}');*/
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    /*_logger.e('${bloc.runtimeType} $error');*/
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    /*_logger.w('${bloc.runtimeType} closed');*/
  }
}
