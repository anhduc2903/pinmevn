import 'package:bloc/bloc.dart';

enum ImageAdIndexEvents { conjunctive, previous }

class ImageAdIndexBloc extends Bloc<ImageAdIndexEvents, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(ImageAdIndexEvents event) async* {
    switch (event) {
      case ImageAdIndexEvents.conjunctive:
        yield state + 1;
        break;
      case ImageAdIndexEvents.previous:
        yield 0;
        break;
    }
  }
}
