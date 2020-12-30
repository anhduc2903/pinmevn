import 'package:bloc/bloc.dart';

enum ImageEvents { no, yes }

class ImageBloc extends Bloc<ImageEvents, bool> {
  bool hasImage = false;

  @override
  bool get initialState => hasImage;

  @override
  Stream<bool> mapEventToState(ImageEvents event) async* {
    switch (event) {
      case ImageEvents.yes:
        yield true;
        break;
      case ImageEvents.no:
        yield false;
        break;
    }
  }
}
