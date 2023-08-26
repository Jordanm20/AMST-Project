import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Agregarprod extends StatefulWidget {
  @override
  _AgregarprodState createState() => _AgregarprodState();
}

class _AgregarprodState extends State<Agregarprod> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _cantidadController = TextEditingController();
  TextEditingController _pesoUnidadController = TextEditingController();
  TextEditingController _precioUnidadController = TextEditingController();

  void agregarProductoAFirebase() {
    final user = _auth.currentUser;
    if (user != null) {
      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      final ariad = _descripcionController.text;
      print("Before trimming: $ariad");
      final descripcion = ariad.replaceAll(' ', ''); // Reemplazar espacio por cadena vacía
      print("After trimming: $descripcion");

      final productoData = {
        'descripcion': _descripcionController.text,
        'cantidad': _cantidadController.text,
        'pesoUnidad': _pesoUnidadController.text,
        'precioUnidad': _precioUnidadController.text,
      };

      final productoPath = 'users/vendedores/${user.uid}/productos/';
      databaseReference.child(productoPath).push().set(productoData);

      // Limpia los campos del formulario después de agregar el producto
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Agregar',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
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
            ElevatedButton(
              onPressed: () {
                agregarProductoAFirebase();
              },
              child: Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}
