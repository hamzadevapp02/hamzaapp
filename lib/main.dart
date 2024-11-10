import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/reservation_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation App',
      theme: AppTheme.darkTheme, // Or AppTheme.lightTheme for light mode
      home: Stack(
        children: [
          // Background image as the first child
          Container(
            decoration: AppTheme.getBackgroundDecoration(),
          ),
          // Content of the app (over the background)
          const ReservationForm(),
        ],
      ),
    );
  }
}
