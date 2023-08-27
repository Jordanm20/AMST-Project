import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iot/vendedor_pages/agregar_prod.dart';
import 'package:iot/vendedor_pages/dashboard_vende.dart';
import 'package:iot/vendedor_pages/productos_vend.dart';
import 'snack_screen.dart';
import 'pastel_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? databaseReference;
  Map<dynamic, dynamic>? userData = {};
  Map<dynamic, dynamic>? userData2 = {};

  String _tituloAppbar = "";

  int _currentIndex = 0;
  List<Widget> _pages = [];

  List<Map<String, dynamic>> sensorInfoList = [];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference = FirebaseDatabase.instance.ref();
        final snapshot = await databaseReference!
            .child('users/vendedores/${user.uid}')
            .get();
        final snapshot2 = await databaseReference!.child('sensores').get();
        setState(() {
          userData = snapshot.value as Map<dynamic, dynamic>;
          userData2 = snapshot2.value as Map<dynamic, dynamic>;
          userData2?.forEach((sensorKey, sensorData) {
            if (sensorData.containsKey("idVendedor") &&
                sensorData["idVendedor"] == user?.uid) {
              Map<String, dynamic> sensorInfo = {
                sensorKey: {
                  "Peso": sensorData["peso"],
                  "idProduct": sensorData["idProducto"],
                }
              };
              sensorInfoList.add(sensorInfo);
            }
          });

          print(sensorInfoList);

          _tituloAppbar = "¡Bienvenido/a, ${userData!['nombreEncargado']}!";
          print("Resultvendedor ${_tituloAppbar}");

          loadInterfaz();
        });
      } catch (e) {}
    });
  }

  void loadInterfaz() {
    setState(() {
      _pages = [
        Center(
          child: Column(
            children: [
              Container(
                width: 300, // Define the desired width
                height: 600, // Define the desired height
                child: DashboardSection(),
              ), // Correct placement
            ],
          ),
        ),
        ProductosScreen(), // Use the new ProductosScreen widget
        Agregarprod(), // Make sure Agregarprod is a valid widget
      ];
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Monitoreo de inventario y control de calidad'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoreo de inventario y control de calidad'),
        backgroundColor: Colors.black,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Agregar',
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: 1000,
        // Adjust this value to fit your data range
        barGroups: sensorInfoList.map((sensorInfo) {
          final sensorKey = sensorInfo.keys.first;
          final sensorValue = sensorInfo.values.first;
          final peso = sensorValue['Peso'] ?? 0.0;

          final sensorNumber =
              int.parse(sensorKey.split('_').last); // Extract sensor number
          return BarChartGroupData(
            x: sensorNumber, // Convert the extracted sensor number to double
            barRods: [
              BarChartRodData(y: peso.toDouble(), colors: [Colors.cyan]),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value, _) => const TextStyle(
                fontSize: 10), // Add an underscore for the unused argument
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: false),
      ),
    );
  }

  void agregarProductoAFirebase() {
    final user = _auth.currentUser;
    if (user != null) {
      final DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference();
      final ariad = _descripcionController.text;
      print("Before trimming: $ariad");
      final descripcion =
          ariad.replaceAll(' ', ''); // Reemplazar espacio por cadena vacía
      print("After trimming: $descripcion");

      final productoData = {
        {
          'descripcion': _descripcionController.text,
          'cantidad': _cantidadController.text,
          'pesoUnidad': _pesoUnidadController.text,
          'precioUnidad': _precioUnidadController.text,
        }
      };

      final productoPath =
          'users/vendedores/${user.uid}/productos/pushId$descripcion';
      databaseReference.child(productoPath).set(productoData);

      // Limpia los campos del formulario después de agregar el producto
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
    }
  }
=======



>>>>>>> e0f9fddebff78c5521275e1022942b0cf52f5382
}
