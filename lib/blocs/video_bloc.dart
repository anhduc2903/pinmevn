import 'package:bloc/bloc.dart';

enum VideoEvents { no, yes }

class VideoBloc extends Bloc<VideoEvents, bool> {
  bool hasVideo = false;

  @override
  bool get initialState => hasVideo;

  @override
  Stream<bool> mapEventToState(VideoEvents event) async* {
    switch (event) {
      case VideoEvents.yes:
        yield true;
        break;
      case VideoEvents.no:
        yield false;
        break;
    }
  }
}
