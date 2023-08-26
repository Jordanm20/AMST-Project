import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  String _selectedDescription = 'Seleccionar una opción';
  List<String> _productDescriptions = ['Seleccionar una opción'];
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? databaseReference;
  Map<dynamic, dynamic>? userData = {};
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _cantidadController = TextEditingController();
  TextEditingController _pesoUnidadController = TextEditingController();
  TextEditingController _precioUnidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference = FirebaseDatabase.instance.ref();
        final snapshot =
        await databaseReference!.child('users/vendedores/${user.uid}/productos').get();
        setState(() {
          userData = snapshot.value as Map<dynamic, dynamic>;
          _productDescriptions.addAll(userData?.values
              .map<String>((productData) => productData['descripcion'] as String)
              .toList() ??
              []);

          cargarDatosProducto(_selectedDescription);
        });
      } catch (e) {}
    });
  }

  void cargarDatosProducto(String selectedDescription) {
    if (selectedDescription != 'Seleccionar una opción') {
      final selectedProductData = userData?.values
          .firstWhere((productData) => productData['descripcion'] == selectedDescription);
      _descripcionController.text = selectedProductData['descripcion'];
      _cantidadController.text = selectedProductData['cantidad'].toString();
      _pesoUnidadController.text = selectedProductData['pesoUnidad'].toString();
      _precioUnidadController.text = selectedProductData['precioUnidad'].toString();
    } else {
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          DropdownButton<String>(
            value: _selectedDescription,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDescription = newValue!;
                cargarDatosProducto(newValue!);
              });
            },
            items: _productDescriptions.map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
          ),
          if (_selectedDescription != 'Seleccionar una opción')
            Card(
              color: Colors.blueGrey.shade200,
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(Icons.local_dining, size: 70),
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5.0,
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: _descripcionController.text + '\n',
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          RichText(
                            maxLines: 1,
                            text: TextSpan(
                              text: 'Cantidad: ' + _cantidadController.text + '\n',
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          RichText(
                            maxLines: 1,
                            text: TextSpan(
                              text: 'Peso por Unidad: ' + _pesoUnidadController.text + '\n',
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          RichText(
                            maxLines: 1,
                            text: TextSpan(
                              text: 'Precio por Unidad: \$' + _precioUnidadController.text + '\n',
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedDescription != 'Seleccionar una opción')
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
                    editarProductoAFirebase();
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
                ElevatedButton.icon(
                  onPressed: () {
                    borrarProductoAFirebase();
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
    );
  }



void editarProductoAFirebase() async {
    if (_selectedDescription == 'Seleccionar una opción') {
      // No se seleccionó ningún producto para editar
      return;
    }

    try {
      user = _auth.currentUser!;
      databaseReference = FirebaseDatabase.instance.ref();

      // Obtener la clave (pushId) del producto seleccionado
      final selectedProductKey = userData?.entries.firstWhere((entry) =>
      entry.value['descripcion'] == _selectedDescription).key;

      // Actualizar los datos del producto en Firebase
      await databaseReference!
          .child('users/vendedores/${user!.uid}/productos/$selectedProductKey')
          .update({
        'descripcion': _descripcionController.text,
        'cantidad': int.parse(_cantidadController.text),
        'pesoUnidad': double.parse(_pesoUnidadController.text),
        'precioUnidad': double.parse(_precioUnidadController.text),
      });

      // Actualizar _productDescriptions después de editar
      setState(() {
        _productDescriptions = userData?.values
            .map<String>((productData) => productData['descripcion'] as String)
            .toList() ?? [];
      });

      // Llamar a cargarDatosProducto después de editar
      cargarDatosProducto(_selectedDescription);

      print('Producto editado exitosamente.');
    } catch (e) {
      print('Error al editar el producto: $e');
    }
  }
  void borrarProductoAFirebase() async {
    if (_selectedDescription == 'Seleccionar una opción') {
      // No se seleccionó ningún producto para borrar
      return;
    }

    try {
      user = _auth.currentUser!;
      databaseReference = FirebaseDatabase.instance.ref();

      // Obtener la clave (pushId) del producto seleccionado
      final selectedProductKey = userData?.entries.firstWhere((entry) =>
      entry.value['descripcion'] == _selectedDescription).key;

      // Borrar el producto de Firebase
      await databaseReference!
          .child('users/vendedores/${user!.uid}/productos/$selectedProductKey')
          .remove();

      // Actualizar _productDescriptions después de borrar
      setState(() {
        _productDescriptions.remove(_selectedDescription);
        _selectedDescription = 'Seleccionar una opción';
      });

      // Limpiar los controladores después de borrar
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();

      print('Producto borrado exitosamente.');
    } catch (e) {
      print('Error al borrar el producto: $e');
    }
  }


}
