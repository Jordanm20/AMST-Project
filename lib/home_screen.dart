import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'snack_screen.dart';
import 'pastel_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
//Inicio de estado de HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _pages = [];
  bool _isPesoVisible = true;
  bool _isTemperaturaVisible = true;

  @override
  void initState() {
    super.initState();
    // Cargar datos de ThingSpeak al iniciar la página
    _loadThingSpeakData();
  }

  void _loadThingSpeakData() async {
    final apiKey = 'AVGW5LYQ3QWSF581'; // Reemplaza con tu clave de API
    final channelId = '1625782'; // Reemplaza con el ID de tu canal de ThingSpeak
    final response = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/$channelId/feeds.json?results=1&api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final fieldValue = data['feeds'][0]['field1'];
      final fieldValue2 = data['feeds'][0]['field2'];

      setState(() {
        _pages = [
          Center(
            child: Text(
              'Dashboard',
              style: TextStyle(fontSize: 24.0),
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
                              subtitle: Text('Inventario de productos de pastelerías'),
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
        ];
      });
    } else {
      throw Exception('Error al cargar los datos de ThingSpeak');
    }
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
        ],
      ),
    );
  }
}
