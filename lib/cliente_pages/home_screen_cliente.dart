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

//Inicio de estado de HomeScreen
class HomeScreenState extends State<HomeScreen_cliente> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? databaseReference;
  Map<dynamic, dynamic>? userData = {};
  String _tituloAppbar = "";
  final GlobalKey _carritoKey = GlobalKey();

  final List<Widget> _pages = [
    VendedoresPage_cliente(),
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference = FirebaseDatabase.instance.ref();
        final snapshot =
            await databaseReference!.child('users/clientes/${user.uid}').get();
        setState(() {
          userData = snapshot.value as Map<dynamic, dynamic>;
          _pages.add(CarritoPage_cliente(key: _carritoKey, user: userData));
          _tituloAppbar =
              "¡Bienvenido/a, ${userData!['firstName']} ${userData!['lastName']}!";
        });
      } catch (e) {}
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
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
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    try {
                      _auth.signOut();

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
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
                  : SizedBox()),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shop_2),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
