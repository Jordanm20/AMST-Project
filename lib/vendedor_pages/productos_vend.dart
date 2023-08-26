import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  String _selectedDescription = 'Seleccionar una opción'; // Default value
  List<String> _productDescriptions = ['Seleccionar una opción']; // Include the default option
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? databaseReference;
  Map<dynamic, dynamic>? userData = {};
  Map<dynamic, dynamic>? userData2 = {};
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
              .toList() ?? []);

          cargarDatosProducto(_selectedDescription); // Llamar aquí para cargar los datos iniciales
        });


      } catch (e) {}
    });
  }

  // Método para cargar los datos del producto seleccionado en los controladores
  void cargarDatosProducto(String selectedDescription) {
    if (selectedDescription != 'Seleccionar una opción') {
      // Obtener el dato del producto seleccionado desde userData
      final selectedProductData = userData?.values.firstWhere((productData) =>
      productData['descripcion'] == selectedDescription);
      // Actualizar los controladores con los datos del producto
      _descripcionController.text = selectedProductData['descripcion'];
      _cantidadController.text = selectedProductData['cantidad'].toString();
      _pesoUnidadController.text = selectedProductData['pesoUnidad'].toString();
      _precioUnidadController.text = selectedProductData['precioUnidad'].toString();
    } else {
      // Si se selecciona la opción predeterminada, borra los datos de los controladores
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
                cargarDatosProducto(newValue!); // Cargar los datos cuando se selecciona una opción
              });
            },

            items: _productDescriptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
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
              editarProductoAFirebase();
            },
            child: Text('Editar'),
          ),
          ElevatedButton(
            onPressed: () {
              borrarProductoAFirebase();
            },
            child: Text('Borrar Producto'),
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
