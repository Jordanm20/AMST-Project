import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iot/vendedor_pages/agregar_prod.dart';
import 'package:iot/vendedor_pages/dashboard_vende.dart';
import 'package:iot/vendedor_pages/productos_vend.dart';

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
          _tituloAppbar = "Dashboard";
          print("Resultvendedor ${_tituloAppbar}");

          loadInterfaz();
        });
      } catch (e) {}
    });
  }

  void loadInterfaz() {
    setState(() {
      _pages = [
        DashboardSection(),
        ProductosScreen(), // Use the new ProductosScreen widget
        Agregarprod(), // Make sure Agregarprod is a valid widget
      ];
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          _tituloAppbar = "Dashboard";
          break;
        case 1:
          _tituloAppbar = "Productos";
          break;
        case 2:
          _tituloAppbar = "Agregar producto";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_tituloAppbar),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppbar),
        backgroundColor: Colors.black,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
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
}
