import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot/cliente_pages/carrito_cliente.dart';
import 'package:iot/cliente_pages/vendedores_cliente.dart';
import 'package:iot/login_screen.dart';

class HomeScreen_cliente extends StatefulWidget {
  const HomeScreen_cliente({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen_cliente> {
  StreamSubscription<DatabaseEvent>? subUser;
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? databaseReference;
  Map<dynamic, dynamic>? userData = {};
  String _tituloAppbar = "";
  final GlobalKey _carritoKey = GlobalKey();
  final GlobalKey _vendedoresKey = GlobalKey();

  final List<Widget> _pages = [
    SizedBox(),
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference =
            FirebaseDatabase.instance.ref('users/clientes/${user.uid}');
        subUser = databaseReference?.onValue.listen((DatabaseEvent event) {
          if (!mounted) return;
          setState(() {
            userData = event.snapshot.value as Map<dynamic, dynamic>;
            _pages.clear();
            _pages.add(
              VendedoresPage_cliente(key: _vendedoresKey, user: userData),
            );
            _pages.add(CarritoPage_cliente(key: _carritoKey, user: userData));
            if (_currentIndex == 0) {
              _tituloAppbar =
                  "¡Bienvenido/a, ${userData!['firstName']} ${userData!['lastName']}!";
            }
          });
        });
      } catch (e) {}
    });
    super.initState();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          _tituloAppbar =
              "¡Bienvenido/a, ${userData!['firstName']} ${userData!['lastName']}!";
          break;
        case 1:
          _tituloAppbar = "Carrito";
          break;
      }
    });
  }

  int getCartLength() {
    try {
      return userData!['carrito']['products'].values.toList().length;
    } catch (ex) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppbar),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          (_currentIndex == 0
              ? IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    try {
                      final VendedoresPageState vendedoresPageState =
                          _vendedoresKey.currentState as VendedoresPageState;
                      vendedoresPageState.unsub();
                      subUser?.cancel();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                      _auth.signOut();
                    } catch (error) {}
                  },
                )
              : _currentIndex == 1
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        final CarritoPageState carritoPageState =
                            _carritoKey.currentState as CarritoPageState;
                        carritoPageState.clearCarrito();
                      },
                    )
                  : const SizedBox()),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            //icon: Icon(Icons.shopping_cart),
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      "${getCartLength()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
