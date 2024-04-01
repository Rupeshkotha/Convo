import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Convo/features/auth/controllers/login_controller.dart';

import 'package:Convo/shared/utils/shared_pref.dart';
import 'package:Convo/theme/theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool gotKeyboardHeight = false;

  @override
  void initState() {
    ref.read(loginControllerProvider.notifier).init(() async {
      if (gotKeyboardHeight) return;

      double keyboardSize = MediaQuery.of(context).viewInsets.bottom;

      SharedPref.instance.setDouble('keyboardHeight', keyboardSize);

      if (keyboardSize < 300) return;
      gotKeyboardHeight = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedCountry = ref.watch(loginControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorTheme.statusBarColor,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: colorTheme.navigationBarColor,
          systemNavigationBarDividerColor: colorTheme.navigationBarColor,
        ),
        backgroundColor: colorTheme.backgroundColor,
        title: Text(
          'Enter your phone number',
          style: TextStyle(color: colorTheme.textColor1),
        ),
        centerTitle: true,
        actions: [
          Icon(
            Icons.more_vert_rounded,
            color: colorTheme.greyColor,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 29.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: colorTheme.textColor1),
                  children: [
                    const TextSpan(
                      text: 'Convo will need to verify your phone number. ',
                    ),
                    TextSpan(
                      text: 'What\'s my number?',
                      style: TextStyle(color: colorTheme.blueColor),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ref
                  .read(loginControllerProvider.notifier)
                  .showCountryPage(context),
              child: Container(
                padding: const EdgeInsets.only(top: 18.0),
                width: 0.60 * screenWidth,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorTheme.greenColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedCountry.displayNameNoCountryCode,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(loginControllerProvider.notifier)
                          .showCountryPage(context),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: colorTheme.greenColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 0.75 * screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 0.25 * (screenWidth * 0.60),
                    child: TextField(
                      onChanged: (value) {
                        ref
                            .read(loginControllerProvider.notifier)
                            .onPhoneCodeChanged(value);
                      },
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.center,
                      cursorColor: colorTheme.greenColor,
                      controller: ref
                          .read(loginControllerProvider.notifier)
                          .phoneCodeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixText: '+ ',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorTheme.greenColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorTheme.greenColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 0.05 * (screenWidth * 0.60),
                  ),
                  SizedBox(
                    width: 0.70 * (screenWidth * 0.60),
                    child: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      cursorColor: colorTheme.greenColor,
                      controller: ref
                          .read(loginControllerProvider.notifier)
                          .phoneNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: 'Phone number',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorTheme.greenColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorTheme.greenColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Carrier charges may apply.',
                style: TextStyle(color: colorTheme.textColor2),
              ),
            ),
            const SizedBox(height: 24), // Adjusted spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () => ref
                    .read(loginControllerProvider.notifier)
                    .onNextBtnPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Changed button color to orange
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
