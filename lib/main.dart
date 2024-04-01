import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Convo/features/auth/data/repositories/auth_repository.dart';
import 'package:Convo/shared/repositories/isar_db.dart';
import 'package:Convo/shared/utils/abc.dart';
import 'package:Convo/shared/utils/shared_pref.dart';
import 'package:Convo/shared/utils/storage_paths.dart';
import 'features/auth/views/welcome.dart';

import 'features/home/views/base.dart';
import 'firebase_options.dart';

import 'package:Convo/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'convo-42414',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SharedPref.init();
  await IsarDb.init();
  await DeviceStorage.init();

  ErrorWidget.builder = (details) => CustomErrorWidget(details: details);
  return runApp(
    const ProviderScope(
      child: Convo(),
    ),
  );
}

class Convo extends ConsumerWidget {
  const Convo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: "Convo",
      initialRoute: '/',
      theme: ref.read(lightThemeProvider),
      darkTheme: ref.read(darkThemeProvider),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<auth.User?>(
        stream: ref.read(authRepositoryProvider).auth.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return const WelcomePage();
          }

          final user = getCurrentUser();
          if (user == null) {
            return const WelcomePage();
          }

          return HomePage(user: user);
        },
      ),
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const CustomErrorWidget({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  color: colorTheme.appBarColor,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[400],
                  size: 50,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorTheme.appBarColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      child: ListView(
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'OOPS!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.red[400],
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            details.toString(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: colorTheme.blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
