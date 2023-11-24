import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/drop_down_button_form_input.dart';
import 'package:sleep_tracker/components/text_form_input.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/input_rules.dart' as rules;

@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isInputValid = true;
  late User user;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    user = ref.read(authStateProvider).user!;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _birthdayController =
        TextEditingController(text: user.birth == null ? null : DateFormat("yyyy-MM-dd").format(user.birth!));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _handleOnSaved() async {
    bool valid = _formKey.currentState?.validate() ?? false;
    if (_isInputValid != valid) setState(() => _isInputValid = valid);
    if (_isInputValid) {
      await ref.read(authStateProvider.notifier).setUser(user);
      if (mounted) context.popRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 40,
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
                      if (!DateUtils.isSameDay(date, user.birth)) {
                        setState(() {
                          user = user.copyWith(birth: date);
                          _birthdayController.text = DateFormat("yyyy-MM-dd").format(user.birth!);
                        });
                      }
                    },
                  ),
                  DropdownButtonFormInput(
                    value: user.gender,
                    label: 'Gender',
                    leading: SvgPicture.asset('assets/icons/person.svg',
                        color: Theme.of(context).colorScheme.primary, width: 16, height: 16),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: 'male',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text('Female'),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != user.gender) {
                        setState(() {
                          user = user.copyWith(gender: v);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: Style.spacingXxl),
            ListTile(
              onTap: () => context.pushRoute(const ChangePasswordRoute()),
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
