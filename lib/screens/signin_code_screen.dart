import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../functions/build_function.dart';
import '../widgets/build_widget.dart';
import '../globals/globals.dart' as globals;

class SignInCodeScreen extends StatefulWidget {
  static const routeName = '/signin-code';
  @override
  _SignInCodeScreenState createState() => _SignInCodeScreenState();
}

class _SignInCodeScreenState extends State<SignInCodeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final List<FocusNode> focusNodes = List();
  final List<FocusNode> focusNodeTextFields = List();
  final List<String> textRaisedButtons = [
    'Nhập',
    'Đăng nhập bằng tài khoản',
    'Đăng ký',
  ];
  final List<Color> colorRaisedButtons = [
    Colors.blue,
    Colors.blue,
    Colors.blue,
  ];
  final List<TextEditingController> controllers = List();
  final List<Function> validators = [inputValidator];
  final List<Function> functionRaisedButtons = [
    signIn,
    toSignInEmailScreen,
    toSignUpFirstScreen,
  ];
  final String invalidAccount = 'Code không hợp lệ';
  bool isFirstIn = true;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      FocusNode focus = FocusNode();
      focusNodes.add(focus);
    }
    FocusNode focusTextField = FocusNode();
    focusNodeTextFields.add(focusTextField);
    TextEditingController textEditingController = TextEditingController();
    controllers.add(textEditingController);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    final bool isLandScape = mediaQuery.orientation == Orientation.landscape;
    globals.height = size.height.round();
    globals.width = size.width.round();

    final List<Column> listButtons = List.generate(
      3,
      (index) => Column(children: [
        const SizedBox(height: 30),
        buildRawKeyboard(
          focusNode: focusNodes[index + 2],
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
              focusNodeUp: focusNodes[index + 1],
              focusNodeDown: index != 2 ? focusNodes[index + 3] : null,
              type: index == 0 ? TYPE.signIn : TYPE.changeScreen,
            );
            setState(() {});
          },
          child: buildButton(
            focusNode: focusNodes[index + 2],
            color: colorRaisedButtons[index],
            text: textRaisedButtons[index],
            onPressed: () {
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
                  const SizedBox(height: 30),
                  buildRawKeyboard(
                    focusNode: focusNodes[1],
                    onkey: (RawKeyEvent event) {
                      handleKey(
                        event: event,
                        context: context,
                        focusNodeUp: focusNodes[0],
                        focusNodeCenter: focusNodeTextFields[0],
                        focusNodeDown: focusNodes[2],
                        type: TYPE.focusInput,
                      );
                      setState(() {});
                    },
                    child: const SizedBox(height: 0),
                  ),
                  buildTextField(
                    context: context,
                    controller: controllers[0],
                    validator: validators[0],
                    obscureText: false,
                    hintText: 'Nhập code',
                    focusNodeTextField: focusNodeTextFields[0],
                    focusNodeOnSumitted: focusNodes[2],
                    focusNode: focusNodes[1],
                    isLandScape: isLandScape,
                  ),
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
    for (int i = 0; i < 5; i++) {
      focusNodes[i].dispose();
    }
    focusNodeTextFields[0].dispose();
    controllers[0].dispose();
    super.dispose();
  }
}
