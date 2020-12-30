import 'package:bloc/bloc.dart';

enum ControllerIndexEvents { conjunctive, previous }

class ControllerIndexBloc extends Bloc<ControllerIndexEvents, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(ControllerIndexEvents event) async* {
    switch (event) {
      case ControllerIndexEvents.conjunctive:
        yield 1;
        break;
      case ControllerIndexEvents.previous:
        yield 0;
        break;
    }
  }
}
