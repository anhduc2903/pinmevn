import 'package:flutter/material.dart';

import '../functions/build_function.dart';
import '../widgets/build_widget.dart';
import '../globals/globals.dart' as globals;

class SignInEmailScreen extends StatefulWidget {
  static const routeName = '/signin-email';
  @override
  _SignInEmailScreenState createState() => _SignInEmailScreenState();
}

class _SignInEmailScreenState extends State<SignInEmailScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final List<FocusNode> focusNodes = List();
  final List<FocusNode> focusNodeTextFields = List();
  final List<String> hintTextFields = ['Email', 'Mật khẩu'];
  final List<String> textRaisedButtons = [
    'Đăng nhập',
    'Nhập code',
    'Đăng ký',
  ];
  final List<Color> colorRaisedButtons = [
    Colors.blue,
    Colors.blue,
    Colors.blue,
  ];
  final List<TextEditingController> controllers = List();
  final List<Function> validators = [
    emailValidator,
    inputValidator,
  ];
  final List<Function> functionRaisedButtons = [
    signIn,
    toSignInCodeScreen,
    toSignUpFirstScreen,
  ];
  final String invalidAccount = 'Tên đăng nhập hoặc tài khoản không hợp lệ';
  bool isFirstIn = true;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      FocusNode focus = FocusNode();
      focusNodes.add(focus);
    }
    for (int i = 0; i < 2; i++) {
      FocusNode focus = FocusNode();
      focusNodeTextFields.add(focus);
      TextEditingController textEditingController = TextEditingController();
      controllers.add(textEditingController);
    }
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    final bool isLandScape = mediaQuery.orientation == Orientation.landscape;
    globals.height = size.height.round();
    globals.width = size.width.round();

    final List<Column> listTextFields = List.generate(
      2,
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
          child: const SizedBox(height: 0),
        ),
        buildTextField(
          context: context,
          controller: controllers[index],
          validator: validators[index],
          obscureText: index == 1 ? true : false,
          hintText: hintTextFields[index],
          focusNodeTextField: focusNodeTextFields[index],
          focusNodeOnSumitted: focusNodes[index + 2],
          focusNode: focusNodes[index + 1],
          isLandScape: isLandScape,
        ),
      ]),
    );

    final List<Column> listButtons = List.generate(
      3,
      (index) => Column(children: [
        const SizedBox(height: 30),
        buildRawKeyboard(
          focusNode: focusNodes[index + 3],
          onkey: (RawKeyEvent event) {
            handleKey(
              context: context,
              controllers: controllers,
              scaffoldState: scaffoldKey.currentState,
              formState: formKey.currentState,
              invalidAccount: invalidAccount,
              isLandScape: isLandScape,
              event: event,
              onPressedCenter: functionRaisedButtons[index],
              focusNodeUp: focusNodes[index + 2],
              focusNodeDown: index != 2 ? focusNodes[index + 4] : null,
              type: index == 0 ? TYPE.signIn : TYPE.changeScreen,
            );
            setState(() {});
          },
          child: buildButton(
            focusNode: focusNodes[index + 3],
            color: colorRaisedButtons[index],
            text: textRaisedButtons[index],
            onPressed: () async {
              if (index == 0) {
                functionRaisedButtons[index](
                  context: context,
                  controllers: controllers,
                  scaffoldState: scaffoldKey.currentState,
                  formState: formKey.currentState,
                  invalidAccount: invalidAccount,
                  isLandScape: isLandScape,
                );
              } else {
                functionRaisedButtons[index](context);
              }
            },
          ),
        ),
      ]),
    );

    if (isFirstIn) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
      isFirstIn = false;
    }

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          height: size.height - MediaQuery.of(context).padding.top,
          padding: EdgeInsets.all(30),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png',
                    height: size.height * 0.1,
                    width: size.width * 0.4,
                  ),
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
                    child: const SizedBox(height: 0),
                  ),
                  ...listTextFields,
                  ...listButtons,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (int i = 0; i < 6; i++) {
      focusNodes[i].dispose();
    }
    for (int i = 0; i < 2; i++) {
      focusNodeTextFields[i].dispose();
      controllers[i].dispose();
    }
    super.dispose();
  }
}
