import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../globals/key_code.dart';

enum TYPE { nextScreen, changeScreen, focusInput, signIn }

Widget buildRawKeyboard({
  FocusNode focusNode,
  Function(RawKeyEvent) onkey,
  Widget child,
}) {
  return RawKeyboardListener(
    focusNode: focusNode,
    onKey: onkey,
    child: child,
  );
}

Future<void> handleKey({
  BuildContext context,
  List<TextEditingController> controllers,
  ScaffoldState scaffoldState,
  FormState formState,
  String invalidAccount,
  bool isLandScape,
  RawKeyEvent event,
  FocusNode focusNodeCenter,
  FocusNode focusNodeUp,
  FocusNode focusNodeDown,
  Function onPressedCenter,
  TYPE type,
}) async {
  print('A');
  if (event is RawKeyDownEvent) {
    RawKeyEventDataAndroid data = event.data;
    print('B');
    switch (data.keyCode) {
      case KEY_CENTER:
        switch (type) {
          case TYPE.changeScreen:
            onPressedCenter(context);
            break;
          case TYPE.nextScreen:
            onPressedCenter(context, controllers);
            break;
          case TYPE.signIn:
            onPressedCenter(
              context: context,
              controllers: controllers,
              scaffoldState: scaffoldState,
              formState: formState,
              invalidAccount: invalidAccount,
              isLandScape: isLandScape,
            );
            break;
          case TYPE.focusInput:
            // await Future.delayed(Duration(milliseconds: 200));
            FocusScope.of(context).requestFocus(focusNodeCenter);
            break;
          default:
            break;
        }

        break;
      case KEY_DOWN:
        if (focusNodeDown != null) {
          FocusScope.of(context).requestFocus(focusNodeDown);
        }
        break;
      case KEY_LEFT:
        break;
      case KEY_RIGHT:
        break;
      default:
        break;
    }
  }
}

Widget buildTextField({
  BuildContext context,
  TextEditingController controller,
  Function(String) validator,
  bool obscureText,
  String hintText,
  FocusNode focusNodeTextField,
  FocusNode focusNodeOnSumitted,
  FocusNode focusNode,
  bool isLandScape,
}) {
  return TextFormField(
    obscureText: obscureText,
    controller: controller,
    validator: validator,
    keyboardType: TextInputType.text,
    onFieldSubmitted: (_) {
      if (isLandScape) FocusScope.of(context).requestFocus(focusNodeOnSumitted);
    },
    focusNode: focusNodeTextField,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: hintText,
      enabledBorder: OutlineInputBorder(
        borderSide: focusNode.hasFocus
            ? BorderSide(color: Colors.pink, width: 2.0)
            : BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: focusNode.hasFocus
            ? BorderSide(color: Colors.pink, width: 2.0)
            : BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
    ),
  );
}

Widget buildMenu({
  Function(String) validator,
  TextEditingController controller,
  FocusNode focusNode,
  String hintText,
  Function onPressed,
}) {
  return TextFormField(
    validator: validator,
    keyboardType: TextInputType.text,
    onFieldSubmitted: (_) {},
    controller: controller,
    decoration: InputDecoration(
      suffix: Icon(Icons.keyboard_arrow_down),
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: hintText,
      enabledBorder: OutlineInputBorder(
        borderSide: focusNode.hasFocus
            ? BorderSide(color: Colors.pink, width: 2.0)
            : BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: focusNode.hasFocus
            ? BorderSide(color: Colors.pink, width: 2.0)
            : BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink, width: 2.0),
        borderRadius: BorderRadius.circular(0),
      ),
    ),
  );
}

Widget buildButton({
  FocusNode focusNode,
  String text,
  Color color,
  Function() onPressed,
}) {
  return GestureDetector(
    child: Container(
      decoration: BoxDecoration(
        color: color,
        border: focusNode.hasFocus
            ? Border.all(color: Colors.pink, width: 2.0)
            : Border.all(color: color, width: 2.0),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    ),
    onTap: onPressed,
  );
}
