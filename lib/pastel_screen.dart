import 'package:flutter/material.dart';

class PastelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pasteles'),
      ),
      body: Center(
        child: Text('Inventario de productos de pastelerías'),
      ),
    );
  }
}
