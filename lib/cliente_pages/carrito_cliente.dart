import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CarritoPage_cliente extends StatefulWidget {
  Map<dynamic, dynamic>? user;
  CarritoPage_cliente({super.key, required this.user});
  @override
  CarritoPageState createState() => CarritoPageState(user);
}

class CarritoPageState extends State<StatefulWidget> {
  StreamSubscription<DatabaseEvent>? subCarrito;
  Map<dynamic, dynamic>? user;
  List<Map<dynamic, dynamic>> carrito = [];

  CarritoPageState(this.user);

  @override
  void initState() {
    super.initState();
    DatabaseReference carritoRef = FirebaseDatabase.instance
        .ref('users/clientes/${user!['carrito']['id']}/carrito/products');
    subCarrito = carritoRef.onValue.listen((DatabaseEvent event) {
      carrito.clear();
      final cartData = event.snapshot.value as Map<dynamic, dynamic>;
      cartData.forEach((key, value) {
        carrito.add(value);
      });
      print(carrito);
    });
  }

  void clearCarrito() {
    print("CLEAR CARRITO");
  }

  @override
  dispose() {
    subCarrito?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text("Carrito"),
    );
  }
}
