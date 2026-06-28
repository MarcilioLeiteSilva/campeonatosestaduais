import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:azul_football/services/data_loader.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer? _timer = null;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final startTime = DateTime.now();
    
    // Carrega dados do PocketBase de forma assíncrona
    await DataLoader.loadAllData();
    
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(seconds: 3) - elapsed;
    
    if (remainingDelay.isNegative) {
      if (mounted) Get.offAllNamed('/home');
    } else {
      _timer = Timer(remainingDelay, () {
        if (mounted) Get.offAllNamed('/home');
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/icon_splash.png',
          width: 140.0,
          height: 140.0,
        ),
      ),
    );
  }
}
