import 'package:flutter/material.dart';
import '../Menu bar/menu_bar.dart';

class ComputerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Computer'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text(
          'This is the Computer Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
