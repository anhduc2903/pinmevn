import 'package:bloc/bloc.dart';

enum ImageIndexEvents { conjunctive, previous }

class ImageIndexBloc extends Bloc<ImageIndexEvents, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(ImageIndexEvents event) async* {
    switch (event) {
      case ImageIndexEvents.conjunctive:
        yield state + 1;
        break;
      case ImageIndexEvents.previous:
        yield 0;
        break;
    }
  }
}
