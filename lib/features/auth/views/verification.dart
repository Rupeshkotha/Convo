import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Convo/features/auth/domain/auth_service.dart';
import 'package:Convo/features/auth/controllers/verification_controller.dart';
import 'package:Convo/features/auth/views/login.dart';

import 'package:Convo/shared/utils/abc.dart';
import 'package:Convo/shared/utils/snackbars.dart';
import 'package:Convo/theme/theme.dart';

import '../../../shared/models/user.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final Phone phone;

  const VerificationPage({super.key, required this.phone});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationControllerProvider).init(
            context,
            widget.phone.rawNumber,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(verificationCodeProvider, (previous, next) {
      showSnackBar(
        context: context,
        content: 'OTP sent!',
        type: SnacBarType.info,
      );

      ref.read(verificationControllerProvider).updateVerificationCode(next);
      ref.read(resendTimerControllerProvider.notifier).updateTimer();
    });

    final resendTime = ref.watch(resendTimerControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;
    final isTimerActive =
        ref.watch(resendTimerControllerProvider.notifier).isTimerActive;
    final multipleTimesSent =
        ref.read(resendTimerControllerProvider.notifier).resendCount > 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Verifying your number',
          style: TextStyle(color: colorTheme.textColor1),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorTheme.statusBarColor,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: colorTheme.navigationBarColor,
          systemNavigationBarDividerColor: colorTheme.navigationBarColor,
        ),
        actions: [
          Icon(
            Icons.more_vert_rounded,
            color: colorTheme.greyColor,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50.0,
                vertical: 16.0,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    multipleTimesSent
                        ? TextSpan(
                            text: 'You have tried to register ',
                            style: TextStyle(color: colorTheme.textColor1),
                          )
                        : TextSpan(
                            text:
                                'Waiting to automatically detect an SMS sent to ',
                            style: TextStyle(color: colorTheme.textColor1),
                          ),
                    TextSpan(
                      text: '${widget.phone.formattedNumber}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorTheme.textColor1,
                      ),
                    ),
                    if (multipleTimesSent) ...[
                      TextSpan(
                        text:
                            'recently. Wait before requesting an SMS or a call with your code. ',
                        style: TextStyle(color: colorTheme.textColor1),
                      )
                    ],
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                      text: 'Wrong Number?',
                      style: TextStyle(color: colorTheme.blueColor),
                    ),
                  ],
                ),
              ),
            ),
            OTPField(
              onFilled: (value) {
                ref
                    .read(verificationControllerProvider)
                    .onFilled(context, value, widget.phone);
              },
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Enter 6-digit code',
                style: TextStyle(color: colorTheme.greyColor),
              ),
            ),
            InkWell(
              onTap: isTimerActive
                  ? null
                  : () =>
                      ref.read(verificationControllerProvider).onResendPressed(
                            context,
                            widget.phone.rawNumber,
                          ),
              child: Text(
                'Didn\'t receive code?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isTimerActive
                      ? colorTheme.greyColor
                      : colorTheme.greenColor,
                ),
              ),
            ),
            Text(
              isTimerActive
                  ? 'You may request a new code in ${timeFromSeconds(resendTime, true)}'
                  : '',
              style: TextStyle(color: colorTheme.greyColor),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPField extends StatefulWidget {
  const OTPField({
    super.key,
    required this.onFilled,
  });

  final Function(String value) onFilled;

  @override
  // ignore: library_private_types_in_public_api
  _OTPFieldState createState() => _OTPFieldState();
}

class _OTPFieldState extends State<OTPField> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 44,
          height: 44,
          child: TextField(
            controller: _controllers[index],
            textAlign: TextAlign.center, // Center the numbers
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  FocusScope.of(context).nextFocus();
                } else {
                  // When all digits are entered
                  String otp = '';
                  for (var controller in _controllers) {
                    otp += controller.text;
                  }
                  widget.onFilled(otp);
                }
              }
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: _controllers[index].text.isNotEmpty
                  ? Colors.orange
                  : colorTheme.textColor1,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorTheme.greenColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorTheme.greenColor,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorTheme.greenColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
