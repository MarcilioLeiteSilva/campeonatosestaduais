import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'helpers/helpers.dart';
import 'logic/cubits/setting/setting_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("🔥 FCM TOKEN: $token");
  } catch (e) {
    print("❌ Erro ao obter FCM Token: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingCubit>(
          create: (BuildContext context) => SettingCubit(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: RouterApp.router,
        title: AppText.appName,
        theme: AppTheme.darTheme(context),
        builder: EasyLoading.init(),
      ),
    );
  }
}
