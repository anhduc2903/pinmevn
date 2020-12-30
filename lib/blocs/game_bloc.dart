import 'package:bloc/bloc.dart';

enum GameEvents { no, yes }

class GameBloc extends Bloc<GameEvents, bool> {
  bool hasGame = false;

  @override
  bool get initialState => hasGame;

  @override
  Stream<bool> mapEventToState(GameEvents event) async* {
    switch (event) {
      case GameEvents.yes:
        yield true;
        break;
      case GameEvents.no:
        yield false;
        break;
    }
  }
}
