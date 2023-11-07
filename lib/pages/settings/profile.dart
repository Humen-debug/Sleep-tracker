import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/drop_down_button_form_input.dart';
import 'package:sleep_tracker/components/text_form_input.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/input_rules.dart' as rules;

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isInputValid = true;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  DateTime? _birthday;
  late final TextEditingController _birthdayController =
      TextEditingController(text: _birthday == null ? null : DateFormat("yyyy-MM-dd").format(_birthday!));

  void _handleOnSaved() {
    bool valid = _formKey.currentState?.validate() ?? false;
    if (_isInputValid != valid) setState(() => _isInputValid = valid);
    if (_isInputValid) {
      context.popRoute();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 40,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _handleOnSaved,
            child: const Text('SAVE'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: Style.spacingXl, horizontal: Style.spacingLg),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(radius: 60, backgroundColor: Style.grey3),
                  Positioned(
                    right: 0,
                    bottom: -5,
                    width: 40,
                    height: 40,
                    child: InkResponse(
                      onTap: () {},
                      radius: 40 / 2 + Style.spacingXs,
                      child: Container(
                          padding: const EdgeInsets.all(Style.spacingXs),
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.tertiary),
                          child: SvgPicture.asset('assets/icons/camera.svg', color: Theme.of(context).primaryColor)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: Style.spacingXxl),
            Form(
              key: _formKey,
              child: OverflowBar(
                overflowSpacing: Style.spacingMd,
                children: [
                  TextFormInput(
                    controller: _nameController,
                    label: 'Username',
                    decoration: const InputDecoration.collapsed(hintText: 'Your Name'),
                    leading: SvgPicture.asset('assets/icons/person.svg',
                        color: Theme.of(context).colorScheme.primary, width: 16, height: 16),
                    validator: rules.required,
                  ),
                  TextFormInput(
                    controller: _emailController,
                    label: 'Email',
                    decoration: const InputDecoration.collapsed(hintText: 'Your Email Address'),
                    leading: SvgPicture.asset('assets/icons/email.svg',
                        color: Theme.of(context).colorScheme.primary, width: 16, height: 16),
                    validator: (value) => rules.required(value) ?? rules.email(value),
                  ),
                  TextFormInput(
                    controller: _birthdayController,
                    label: 'Birth',
                    decoration: const InputDecoration.collapsed(hintText: 'YYYY-MM-DD'),
                    leading: SvgPicture.asset('assets/icons/birthday-cake.svg',
                        color: Theme.of(context).colorScheme.primary, width: 16, height: 16),
                    trailing: SvgPicture.asset('assets/icons/calendar.svg', color: Style.grey1),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 100),
                          lastDate: DateTime.now());
                      if (!DateUtils.isSameDay(date, _birthday)) {
                        setState(() {
                          _birthday = date;
                          _birthdayController.text = DateFormat("yyyy-MM-dd").format(_birthday!);
                        });
                      }
                    },
                  ),
                  DropdownButtonFormInput(
                      value: 'Male',
                      label: 'Gender',
                      leading: SvgPicture.asset('assets/icons/person.svg',
                          color: Theme.of(context).colorScheme.primary, width: 16, height: 16),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'Male',
                          child: Text('Male'),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (v) {}),
                ],
              ),
            ),
            const SizedBox(height: Style.spacingXxl),
            ListTile(
              title: const Text('Change Password'),
              leading: SvgPicture.asset('assets/icons/password.svg',
                  width: 20, height: 20, color: Theme.of(context).primaryColor),
              trailing: SvgPicture.asset('assets/icons/chevron-right.svg', width: 24, height: 24, color: Style.grey1),
            ),
          ],
        ),
      ),
    );
  }
}
