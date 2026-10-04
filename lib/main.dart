import 'package:flutter/material.dart';

import 'pages.dart';
import 'theme.dart';

void main() => runApp(const MtAlchemyApp());

class MtAlchemyApp extends StatelessWidget {
  const MtAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MT Alchemy',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      onGenerateRoute: buildRoute,
    );
  }
}
