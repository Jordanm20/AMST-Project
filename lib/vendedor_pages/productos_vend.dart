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
  List<Map<dynamic, dynamic>> _userProducts = [
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
            // _productDescriptions.clear();
            //_productDescriptions.add('Seleccionar una opción');
            Map<dynamic, dynamic> userData =
                snapshot.value as Map<dynamic, dynamic>;
            userData.forEach((key, value) {
              value['productId'] = key;
              //_productDescriptions.add(value['descripcion']);
              _userProducts.add(value);
            });
          });
          cargarDatosProducto('Seleccione una opción');
        });
      } catch (e) {}
    });
  }

  void cargarDatosProducto(String selectedDescription) {
    if (selectedDescription != 'Seleccione una opción') {
      final selectedProductData = _userProducts.firstWhere(
          (productData) => productData['descripcion'] == selectedDescription);
      _descripcionController.text = selectedProductData['descripcion'];
      _cantidadController.text = selectedProductData['cantidad'].toString();
      _pesoUnidadController.text = selectedProductData['pesoUnidad'].toString();
      _precioUnidadController.text =
          (selectedProductData['precioUnidad'] / 100).toString();
    } else {
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
    }
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
              hint: const Text('Seleccione una opcion'),
              value: _userProducts[_userProductIndex]['descripcion'],
              onChanged: (String? newValue) {
                setState(() {
                  // _selectedDescription = newValue!;
                  _userProductIndex = _userProducts.indexWhere(
                      (element) => element['descripcion'] == newValue);
                  isSelected = true;
                  //cargarDatosProducto(newValue);
                });
              },
              items: _userProducts
                  .map((product) => DropdownMenuItem<String>(
                      value: product['descripcion'],
                      child: Text(product['descripcion'])))
                  .toList(),
            ),
            Column(
              children: [
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _cantidadController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _pesoUnidadController,
                  decoration: InputDecoration(
                    labelText: 'Peso por unidad',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _precioUnidadController,
                  decoration: InputDecoration(
                    labelText: 'Precio por unidad',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // editarProductoAFirebase();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  icon: Icon(Icons.edit, size: 24),
                  label: Text(
                    'Editar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 10.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // borrarProductoAFirebase();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  icon: Icon(Icons.delete, size: 24),
                  label: Text(
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

  // void editarProductoAFirebase() async {
  //   if (_userProducts[_userProductIndex]['descripcion'] == null) {
  //     return;
  //   }

  //   try {
  //     user = _auth.currentUser!;
  //     databaseReference = FirebaseDatabase.instance.ref();

  //     // Obtener la clave (pushId) del producto seleccionado
  //     final selectedProductKey = _userProducts
  //         .asMap()
  //         .entries
  //         .firstWhere(
  //             (entry) => entry.value['descripcion'] == _selectedDescription)
  //         .key;

  //     await databaseReference!
  //         .child('users/vendedores/${user!.uid}/productos/$selectedProductKey')
  //         .update({
  //       'descripcion': _descripcionController.text,
  //       'cantidad': int.parse(_cantidadController.text),
  //       'pesoUnidad': double.parse(_pesoUnidadController.text),
  //       'precioUnidad': (double.parse(_precioUnidadController.text) * 100),
  //     });

  //     setState(() {
  //       _productDescriptions = _userProducts
  //               .asMap()
  //               .values
  //               .map<String>(
  //                   (productData) => productData['descripcion'] as String)
  //               .toList() ??
  //           [];
  //     });

  //     // Llamar a cargarDatosProducto después de editar
  //     cargarDatosProducto(_selectedDescription);

  //     print('Producto editado exitosamente.');
  //   } catch (e) {
  //     print('Error al editar el producto: $e');
  //   }
  // }

  // void borrarProductoAFirebase() async {
  //   if (_selectedDescription == 'Seleccionar una opción') {
  //     return;
  //   }

  //   try {
  //     user = _auth.currentUser!;
  //     databaseReference = FirebaseDatabase.instance.ref();

  //     final selectedProductKey = _userProducts
  //         .asMap()
  //         .entries
  //         .firstWhere(
  //             (entry) => entry.value['descripcion'] == _selectedDescription)
  //         .key;

  //     await databaseReference!
  //         .child('users/vendedores/${user!.uid}/productos/$selectedProductKey')
  //         .remove();

  //     setState(() {
  //       _productDescriptions.remove(_selectedDescription);
  //       _selectedDescription = 'Seleccionar una opción';
  //     });

  //     databaseReference = FirebaseDatabase.instance.ref('sensores/');

  //     _descripcionController.clear();
  //     _cantidadController.clear();
  //     _pesoUnidadController.clear();
  //     _precioUnidadController.clear();

  //     showSnackBar("Producto eliminado exitosamente!");
  //   } catch (e) {
  //     showSnackBar('Error al borrar el producto: $e');
  //   }
  // }

  void showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
