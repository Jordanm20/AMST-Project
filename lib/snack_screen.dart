import 'package:flutter/material.dart';

class SnackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snack'),
      ),
      body: Center(
        child: Text('Inventario de productos de snack'),
      ),
    );
  }
}
