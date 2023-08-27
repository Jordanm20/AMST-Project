import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? databaseReference;
  StreamSubscription<DatabaseEvent>? subProductos;
  int _userProductIndex = 0;
  final List<Map<dynamic, dynamic>> _userProducts = [
    {"descripcion": "Seleccione una opcion"}
  ];
  bool isSelected = false;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _pesoUnidadController = TextEditingController();
  final TextEditingController _precioUnidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference = FirebaseDatabase.instance.ref();
        final snapshot = await databaseReference!
            .child('users/vendedores/${user.uid}/productos')
            .get();

        subProductos = snapshot.ref.onValue.listen((DatabaseEvent event) {
          if (!mounted) return;
          setState(() {
            _userProducts.clear();
            _userProducts.add({"descripcion": "Seleccione una opcion"});
            _userProductIndex = 0;
            if (!event.snapshot.exists) return;
            Map<dynamic, dynamic> userData =
                event.snapshot.value as Map<dynamic, dynamic>;
            userData.forEach((key, value) {
              value['productId'] = key;
              _userProducts.add(value);
            });
            cargarDatosProducto();
          });
        });
      } catch (e) {}
    });
  }

  void cargarDatosProducto() {
    if (_userProductIndex == 0) {
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
      return;
    }
    _descripcionController.text =
        _userProducts[_userProductIndex]['descripcion'];
    _cantidadController.text =
        _userProducts[_userProductIndex]['cantidad'].toString();
    _pesoUnidadController.text =
        _userProducts[_userProductIndex]['pesoUnidad'].toString();
    _precioUnidadController.text =
        (_userProducts[_userProductIndex]['precioUnidad'] / 100).toString();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _cantidadController.dispose();
    _pesoUnidadController.dispose();
    _precioUnidadController.dispose();
    subProductos?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text(_userProducts[_userProductIndex]['descripcion']),
              value: _userProducts[_userProductIndex]['descripcion'],
              onChanged: (String? newValue) {
                setState(() {
                  _userProductIndex = _userProducts.indexWhere(
                      (element) => element['descripcion'] == newValue);
                  if (_userProductIndex == 0) {
                    return;
                  }
                  isSelected = true;
                  cargarDatosProducto();
                });
              },
              items: _userProducts
                  .map((product) => DropdownMenuItem<String>(
                      value: product['descripcion'],
                      child: Text(product['descripcion'])))
                  .toList(),
            ),
            if (_userProductIndex != 0)
              Column(
                children: [
                  TextField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    enabled: false,
                    controller: _cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad (definida por el peso)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _pesoUnidadController,
                    decoration: const InputDecoration(
                      labelText: 'Peso por unidad (en gramos)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _precioUnidadController,
                    decoration: const InputDecoration(
                      labelText: 'Precio por unidad (en dólares)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      editarProductoAFirebase();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    icon: const Icon(Icons.edit, size: 24),
                    label: const Text(
                      'Editar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      borrarProductoAFirebase();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    icon: const Icon(Icons.delete, size: 24),
                    label: const Text(
                      'Borrar Producto',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void editarProductoAFirebase() async {
    if (_userProducts[_userProductIndex]['productId'] == null) {
      return;
    }

    try {
      user = _auth.currentUser!;
      databaseReference = FirebaseDatabase.instance.ref();
      final selectedProductKey = _userProducts[_userProductIndex]['productId'];
      await databaseReference!
          .child('users/vendedores/${user!.uid}/productos/$selectedProductKey')
          .update({
        'descripcion': _descripcionController.text,
        'cantidad': int.parse(_cantidadController.text),
        'pesoUnidad': double.parse(_pesoUnidadController.text),
        'precioUnidad': (double.parse(_precioUnidadController.text) * 100),
      });

      showSnackBar('Producto editado exitosamente.');
    } catch (e) {
      showSnackBar('Error al editar el producto: $e');
    } finally {
      FocusScope.of(context).unfocus();
    }
  }

  void borrarProductoAFirebase() async {
    if (_userProducts[_userProductIndex]['productId'] == null) {
      return;
    }

    try {
      user = _auth.currentUser!;
      databaseReference = FirebaseDatabase.instance.ref();
      final selectedProductKey = _userProducts[_userProductIndex]['productId'];
      final selectedProductSensor =
          _userProducts[_userProductIndex]['sensorId'];
      await databaseReference!
          .child('users/vendedores/${user!.uid}/productos/$selectedProductKey')
          .remove();
      databaseReference =
          FirebaseDatabase.instance.ref('sensores/$selectedProductSensor');
      await databaseReference!.child('idProducto').remove();
      await databaseReference!.child('idVendedor').remove();
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
      showSnackBar("Producto eliminado exitosamente!");
    } catch (e) {
      showSnackBar('Error al borrar el producto: $e');
    } finally {
      FocusScope.of(context).unfocus();
    }
  }

  void showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
