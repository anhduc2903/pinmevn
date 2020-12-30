import 'package:flutter/material.dart';

import '../functions/build_function.dart';
import '../widgets/build_widget.dart';

class SignUpFirstScreen extends StatefulWidget {
  static const routeName = '/signup-first';
  @override
  _SignUpFirstScreenState createState() => _SignUpFirstScreenState();
}

class _SignUpFirstScreenState extends State<SignUpFirstScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final List<FocusNode> focusNodes = List();
  final List<FocusNode> focusNodeTextFields = List();
  final List<TextEditingController> controllers = List();
  final List<String> hintTextFields = [
    'Họ tên',
    'Số điện thoại',
    'Email',
    'Mật khẩu'
  ];
  bool isFirstIn = true;
  final String invalidAccount = '';
  final List<String> textRaisedButtons = [
    'Tiếp tục',
    'Đăng nhập',
  ];
  final List<Color> colorRaisedButtons = [
    Colors.blue,
    Colors.blue,
  ];
  final List<Function> functionRaisedButtons = [
    toSignUpSecondScreen,
    toSignInEmailScreen,
  ];
  final List<Function> validators = [
    inputValidator,
    inputValidator,
    emailValidator,
    inputValidator,
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 8; i++) {
      FocusNode focus = FocusNode();
      focusNodes.add(focus);
    }
    for (int i = 0; i < 4; i++) {
      FocusNode focus = FocusNode();
      focusNodeTextFields.add(focus);
      TextEditingController textEditingController = TextEditingController();
      controllers.add(textEditingController);
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 8; i++) {
      focusNodes[i].dispose();
    }
    for (int i = 0; i < 4; i++) {
      focusNodeTextFields[i].dispose();
      controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final bool isLandScape = mediaQuery.orientation == Orientation.landscape;

    List<Column> listTextFields = List.generate(
      4,
      (index) => Column(children: [
        const SizedBox(height: 30),
        buildRawKeyboard(
          focusNode: focusNodes[index + 1],
          onkey: (RawKeyEvent event) {
            handleKey(
              event: event,
              context: context,
              focusNodeUp: focusNodes[index],
              focusNodeCenter: focusNodeTextFields[index],
              focusNodeDown: focusNodes[index + 2],
              type: TYPE.focusInput,
            );
            setState(() {});
          },
          child: SizedBox(height: 0),
        ),
        buildTextField(
          context: context,
          obscureText: index == 3 ? true : false,
          controller: controllers[index],
          isLandScape: true,
          validator: validators[index],
          focusNodeTextField: focusNodeTextFields[index],
          focusNodeOnSumitted: focusNodes[index + 2],
          focusNode: focusNodes[index + 1],
          hintText: hintTextFields[index],
        ),
      ]),
    );

    final List<Column> listButtons = List.generate(
      2,
      (index) => Column(children: [
        const SizedBox(height: 30),
        buildRawKeyboard(
          focusNode: focusNodes[index + 5],
          onkey: (RawKeyEvent event) {
            handleKey(
              context: context,
              controllers: index == 0 ? controllers : null,
              scaffoldState: scaffoldKey.currentState,
              formState: formKey.currentState,
              invalidAccount: invalidAccount,
              isLandScape: isLandScape,
              event: event,
              onPressedCenter: functionRaisedButtons[index],
              focusNodeUp: focusNodes[index + 4],
              focusNodeDown: index != 1 ? focusNodes[index + 6] : null,
              type: index == 0 ? TYPE.nextScreen : TYPE.changeScreen,
            );
            setState(() {});
          },
          child: buildButton(
            focusNode: focusNodes[index + 5],
            color: colorRaisedButtons[index],
            text: textRaisedButtons[index],
            onPressed: () {},
          ),
        ),
      ]),
    );

    if (isFirstIn) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
      isFirstIn = false;
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height - MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
          // padding: EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                buildRawKeyboard(
                  focusNode: focusNodes[0],
                  onkey: (RawKeyEvent event) {
                    handleKey(
                      event: event,
                      context: context,
                      focusNodeCenter: focusNodes[1],
                      focusNodeDown: focusNodes[1],
                    );
                    setState(() {});
                  },
                  child: Text(
                    'PinMe',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...listTextFields,
                ...listButtons,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
