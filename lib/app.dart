import 'package:flutter/material.dart';

import 'crud.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD',
      home: CRUD_APP(),
    );
  }
}