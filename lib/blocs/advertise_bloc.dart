import 'package:bloc/bloc.dart';

enum AdvertiseEvents { no, yes }

class AdvertiseBloc extends Bloc<AdvertiseEvents, bool> {
  bool hasAdvertise = false;

  @override
  bool get initialState => hasAdvertise;

  @override
  Stream<bool> mapEventToState(AdvertiseEvents event) async* {
    switch (event) {
      case AdvertiseEvents.yes:
        yield true;
        break;
      case AdvertiseEvents.no:
        yield false;
        break;
    }
  }
}
