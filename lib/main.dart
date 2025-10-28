import 'package:flutter/material.dart';

import 'gooey_numbers.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const GooeyNumbersDemo(),
    ),
  );
}
