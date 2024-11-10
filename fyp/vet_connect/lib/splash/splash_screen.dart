import 'package:flutter/material.dart';
import 'package:vet_connect/services/splash/splash_services.dart';
import '../login_page.dart';
import '../vet_connect_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashServices _splashServices = SplashServices();

  @override
  void initState() {
    super.initState();
    _splashServices.isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: VetConnectPainter(),
        ),
      ),
    );
  }
}
