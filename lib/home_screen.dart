import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _cantidadController = TextEditingController();
  TextEditingController _pesoUnidadController = TextEditingController();
  TextEditingController _precioUnidadController = TextEditingController();

  String _tituloAppbar = "";

  int _currentIndex = 0;
  List<Widget> _pages = [];
  bool _isPesoVisible = true;
  bool _isTemperaturaVisible = true;
  List<Map<String, dynamic>> sensorInfoList = [];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference = FirebaseDatabase.instance.ref();
        final snapshot =
        await databaseReference!.child('users/vendedores/${user.uid}').get();
        final snapshot2 =
        await databaseReference!.child('sensores').get();
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

          _tituloAppbar =
          "¡Bienvenido/a, ${userData!['nombreEncargado']}!";
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _tituloAppbar,
                style: TextStyle(fontSize: 24.0),
              ),
              Text(
                "Dashboard",
                style: TextStyle(fontSize: 24.0),
              ),
              Expanded(
                child: Container(
                  width: 300,
                  height: 100,
                  child: buildBarChart(),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SnackScreen()),
                  );
                },
                child: Visibility(
                  visible: _isPesoVisible,
                  child: Card(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/snack.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text('Snack'),
                            subtitle: Text('Inventario de productos de snack'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PastelScreen()),
                  );
                },
                child: Visibility(
                  visible: _isTemperaturaVisible,
                  child: Card(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/past.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text('Pasteles'),
                            subtitle: Text(
                                'Inventario de productos de pastelerías'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_isPesoVisible || !_isTemperaturaVisible)
                Center(
                  child: Text(
                    'Mensaje general',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
            ],
          ),
        ),
        Center(
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
        ),
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
            label: 'Vitrinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Agregar',
          ),
        ],
      ),
    );
  }

  Widget buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: 6000,
        // Adjust this value to fit your data range
        barGroups: sensorInfoList.map((sensorInfo) {
          final sensorKey = sensorInfo.keys.first;
          final sensorValue = sensorInfo.values.first;
          final peso = sensorValue['Peso'] ?? 0.0;

          final sensorNumber = int.parse(sensorKey
              .split('_')
              .last); // Extract sensor number
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
            getTextStyles: (value, _) =>
            const TextStyle(
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
      final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      final ariad = _descripcionController.text;
      print("Before trimming: $ariad");
      final descripcion = ariad.replaceAll(' ', ''); // Reemplazar espacio por cadena vacía
      print("After trimming: $descripcion");


      final productoData = {
        {
          'descripcion': _descripcionController.text,
          'cantidad': _cantidadController.text,
          'pesoUnidad': _pesoUnidadController.text,
          'precioUnidad': _precioUnidadController.text,
        }
      };

      final productoPath = 'users/vendedores/${user.uid}/productos/pushId$descripcion';
      databaseReference.child(productoPath).set(productoData);

      // Limpia los campos del formulario después de agregar el producto
      _descripcionController.clear();
      _cantidadController.clear();
      _pesoUnidadController.clear();
      _precioUnidadController.clear();
    }
  }

}
