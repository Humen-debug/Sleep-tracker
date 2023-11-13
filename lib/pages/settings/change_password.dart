import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/components/text_form_input.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/input_rules.dart' as rules;

@RoutePage()
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  bool _hidePassword = true;
  bool _hideNewPassword = true;

  @override
  void dispose() {
    _pwController.dispose();
    _newPwController.dispose();
    super.dispose();
  }

  void _handleOnSaved() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: Style.spacingXxl, horizontal: Style.spacingXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Style.radiusXs),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormInput(
                          label: 'Password',
                          controller: _pwController,
                          obscureText: _hidePassword,
                          decoration: const InputDecoration(errorMaxLines: 2),
                          trailing: InkResponse(
                            onTap: () => setState(() => _hidePassword = !_hidePassword),
                            child: _hidePassword
                                ? SvgPicture.asset('assets/icons/view-off.svg', color: Style.grey2)
                                : SvgPicture.asset('assets/icons/view.svg', color: Style.grey2),
                          ),
                          validator: (value) => rules.required(value) ?? rules.length(value),
                        ),
                        Divider(color: Theme.of(context).scaffoldBackgroundColor, height: 0),
                        TextFormInput(
                          label: 'New Password',
                          controller: _newPwController,
                          obscureText: _hideNewPassword,
                          decoration: const InputDecoration(errorMaxLines: 2),
                          trailing: InkResponse(
                            onTap: () => setState(() => _hideNewPassword = !_hideNewPassword),
                            child: _hideNewPassword
                                ? SvgPicture.asset('assets/icons/view-off.svg', color: Style.grey2)
                                : SvgPicture.asset('assets/icons/view.svg', color: Style.grey2),
                          ),
                          validator: (value) => rules.same(value, _pwController.text),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Style.spacingXxl),
                Text.rich(
                  TextSpan(text: 'Forget the password? ', children: [
                    TextSpan(
                      text: 'Reset Password',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ]),
                )
              ],
            ),
          )),
          Container(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingMd),
              child: SizedBox(
                  width: double.infinity, child: ElevatedButton(onPressed: _handleOnSaved, child: const Text('Save'))))
        ],
      ),
    );
  }
}
