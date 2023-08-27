import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Agregarprod extends StatefulWidget {
  @override
  _AgregarprodState createState() => _AgregarprodState();
}

class _AgregarprodState extends State<Agregarprod> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _sensorIdController = TextEditingController();
  final TextEditingController _pesoUnidadController = TextEditingController();
  final TextEditingController _precioUnidadController = TextEditingController();

  void agregarProductoAFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (aFieldIsEmpty()) {
      showSnackBar("Rellene todos los campos, por favor.");
      return;
    }
    if (await sensorDoesNotExist(_sensorIdController.text) ||
        await sensorHasAnotherOwner(_sensorIdController.text)) {
      showSnackBar("ID del sensor no válido.");
      return;
    }
    if (await sensorIsMine(_sensorIdController.text)) {
      showSnackBar("ID ya asociado a otro producto tuyo.");
      return;
    }

    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();

    final productoData = {
      'descripcion': _descripcionController.text,
      'cantidad': 0,
      'pesoUnidad': double.parse(_pesoUnidadController.text),
      'precioUnidad': double.parse(_precioUnidadController.text) * 100,
      'sensorId': _sensorIdController.text
    };

    final productoPath = 'users/vendedores/${user.uid}/productos/';
    final orderPush = databaseReference.child(productoPath).push();
    orderPush.set(productoData);

    final sensorPath = 'sensores/${_sensorIdController.text}';
    databaseReference.child(sensorPath).update(
      {'idProducto': orderPush.key, 'idVendedor': user.uid},
    );
    clearForm();
    showSnackBar("¡Producto añadido exitosamente!");
    FocusScope.of(context).unfocus();
  }

  bool aFieldIsEmpty() {
    if (_descripcionController.text == "" ||
        _sensorIdController.text == "" ||
        _pesoUnidadController.text == "" ||
        _precioUnidadController.text == "") {
      return true;
    }
    return false;
  }

  Future<bool> sensorDoesNotExist(String sensorId) async {
    DatabaseReference sensorsRef =
        FirebaseDatabase.instance.ref('sensores/$sensorId');
    final sensorSnapshot = await sensorsRef.get();
    if (!sensorSnapshot.exists) {
      return true;
    }
    return false;
  }

  Future<bool> sensorIsMine(String sensorId) async {
    DatabaseReference sensorsRef =
        FirebaseDatabase.instance.ref('sensores/$sensorId/idVendedor');
    final ownerSnapshot = await sensorsRef.get();
    if (ownerSnapshot.exists) {
      if (ownerSnapshot.value == _auth.currentUser?.uid) {
        return true;
      }
    }
    return false;
  }

  Future<bool> sensorHasAnotherOwner(String sensorId) async {
    DatabaseReference sensorsRef =
        FirebaseDatabase.instance.ref('sensores/$sensorId/idVendedor');
    final ownerSnapshot = await sensorsRef.get();
    if (ownerSnapshot.exists) {
      if (ownerSnapshot.value != _auth.currentUser?.uid) {
        return true;
      }
    }
    return false;
  }

  void showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void clearForm() {
    _descripcionController.clear();
    _sensorIdController.clear();
    _pesoUnidadController.clear();
    _precioUnidadController.clear();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _sensorIdController.dispose();
    _pesoUnidadController.dispose();
    _precioUnidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
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
            const SizedBox(height: 10.0),
            TextField(
              controller: _sensorIdController,
              decoration: const InputDecoration(
                labelText: 'Sensor ID',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                agregarProductoAFirebase();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}
