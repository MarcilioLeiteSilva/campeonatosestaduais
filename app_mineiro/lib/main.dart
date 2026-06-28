import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'helpers/helpers.dart';
import 'logic/cubits/setting/setting_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
